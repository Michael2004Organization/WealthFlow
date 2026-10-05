import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'access.dart';

/// Keys typed into the server window: pairing codes, accounts, devices.
final class ServerConsole {
  ServerConsole(this._access, {Stdin? input, IOSink? output})
    : _input = input ?? stdin,
      _output = output ?? stdout;

  final ServerAccess _access;
  final Stdin _input;
  final IOSink _output;
  StreamSubscription<String>? _lines;
  final List<DeviceInfo> _listedDevices = [];
  _Prompt? _prompt;

  bool get _interactive => _input.hasTerminal;

  /// Asks for the admin account when the server has none yet.
  Future<void> createFirstUser() async {
    if (!_interactive) {
      _output.writeln(
        'Noch kein Konto vorhanden. Bitte den Server einmal per start.cmd '
        'starten, um das erste Konto anzulegen.',
      );
      return;
    }
    _output
      ..writeln('')
      ..writeln('Noch kein Konto auf dem Server. Lege jetzt dein Konto an.');
    while (true) {
      final email = _readLine('E-Mail: ');
      final name = _readLine('Name: ');
      final password = _readPassword('Passwort (mind. 10 Zeichen): ');
      final repeated = _readPassword('Passwort wiederholen: ');
      if (password != repeated) {
        _output.writeln('Die Passwörter stimmen nicht überein.\n');
        continue;
      }
      try {
        await _access.createUser(
          email: email,
          displayName: name,
          password: password,
        );
        _output.writeln('Konto für $email angelegt.\n');
        return;
      } on AccessDenied catch (denied) {
        _output.writeln('$denied\n');
      }
    }
  }

  /// Listens for commands in the window.
  void start() {
    if (!_interactive) return;
    _printHelp();
    _lines = _input
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => unawaited(_handle(line.trim())));
  }

  Future<void> stop() async => _lines?.cancel();

  void _printHelp() {
    _output
      ..writeln('')
      ..writeln('Befehle (eintippen und Enter):')
      ..writeln('  Enter     neuen Kopplungscode für ein Gerät anzeigen')
      ..writeln('  b         weiteres Benutzerkonto anlegen')
      ..writeln('  g         gekoppelte Geräte anzeigen')
      ..writeln('  e <Nr>    Gerät entfernen (muss neu gekoppelt werden)')
      ..writeln('  h         diese Hilfe');
  }

  Future<void> _handle(String line) async {
    // A running multi-step prompt (new account) gets the line first.
    final prompt = _prompt;
    if (prompt != null) {
      await prompt.answer(line);
      return;
    }
    final command = line.toLowerCase();
    if (command.isEmpty) {
      final code = _access.startPairing();
      _output
        ..writeln('')
        ..writeln('Kopplungscode: $code')
        ..writeln(
          'In der App unter Einstellungen > Server im Heimnetz eingeben. '
          'Gültig ${ServerAccess.pairingLifetime.inMinutes} Minuten für '
          'ein Gerät.',
        );
    } else if (command == 'b') {
      _startNewUserPrompt();
    } else if (command == 'g') {
      await _printDevices();
    } else if (command.startsWith('e ')) {
      await _removeDevice(command.substring(2).trim());
    } else {
      _printHelp();
    }
  }

  void _startNewUserPrompt() {
    const questions = [
      ('E-Mail: ', false),
      ('Name: ', false),
      ('Passwort (mind. 10 Zeichen): ', true),
      ('Passwort wiederholen: ', true),
    ];
    final answers = <String>[];
    void ask() {
      final (question, secret) = questions[answers.length];
      _output.write(question);
      _input.echoMode = !secret;
    }

    ask();
    _prompt = _Prompt((line) async {
      if (questions[answers.length].$2) _output.writeln('');
      answers.add(line);
      if (answers.length < questions.length) {
        ask();
        return;
      }
      _input.echoMode = true;
      _prompt = null;
      if (answers[2] != answers[3]) {
        _output.writeln('Die Passwörter stimmen nicht überein.');
        return;
      }
      try {
        await _access.createUser(
          email: answers[0],
          displayName: answers[1],
          password: answers[2],
        );
        _output.writeln('Konto für ${answers[0]} angelegt.');
      } on AccessDenied catch (denied) {
        _output.writeln(denied.message);
      }
    });
  }

  Future<void> _printDevices() async {
    final devices = (await _access.devices()).where((d) => !d.revoked);
    _listedDevices
      ..clear()
      ..addAll(devices);
    if (_listedDevices.isEmpty) {
      _output.writeln('Noch keine Geräte gekoppelt.');
      return;
    }
    for (var i = 0; i < _listedDevices.length; i++) {
      final device = _listedDevices[i];
      final seen = device.lastSeenAt.toLocal().toString().substring(0, 16);
      _output.writeln(
        '  ${i + 1}. ${device.name} (${device.userEmail}), zuletzt $seen',
      );
    }
  }

  Future<void> _removeDevice(String number) async {
    final index = (int.tryParse(number) ?? 0) - 1;
    if (index < 0 || index >= _listedDevices.length) {
      _output.writeln('Bitte zuerst "g" eingeben und dann "e <Nr>".');
      return;
    }
    final device = _listedDevices.removeAt(index);
    await _access.revokeDevice(device.id);
    _output.writeln('${device.name} entfernt.');
  }

  String _readLine(String question) {
    _output.write(question);
    return _input.readLineSync(encoding: utf8)?.trim() ?? '';
  }

  String _readPassword(String question) {
    _output.write(question);
    final echo = _input.echoMode;
    try {
      _input.echoMode = false;
      return _input.readLineSync(encoding: utf8) ?? '';
    } finally {
      _input.echoMode = echo;
      _output.writeln('');
    }
  }
}

final class _Prompt {
  _Prompt(this.answer);

  final Future<void> Function(String line) answer;
}
