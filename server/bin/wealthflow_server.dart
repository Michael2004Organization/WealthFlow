import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:wealthflow_server/src/server_console.dart';
import 'package:wealthflow_server/wealthflow_server.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('port', defaultsTo: '8443', help: 'HTTPS-Port im Heimnetz.')
    ..addOption('daten', help: 'Datenordner (Standard: daten neben start.cmd).')
    ..addMultiOption(
      'name',
      help: 'Zusätzlicher Rechnername für das Zertifikat.',
    )
    ..addFlag('hilfe', abbr: 'h', negatable: false);
  final ArgResults options;
  try {
    options = parser.parse(arguments);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }
  if (options.flag('hilfe')) {
    stdout.writeln('WealthFlow-Server\n\n${parser.usage}');
    return;
  }
  final port = int.tryParse(options.option('port')!);
  if (port == null || port < 1 || port > 65535) {
    stderr.writeln('Ungültiger Port: ${options.option('port')}');
    exitCode = 64;
    return;
  }

  final dataOption = options.option('daten');
  final paths = ServerPaths(
    dataOption == null ? ServerPaths.defaultRoot() : Directory(dataOption),
  );
  await paths.root.create(recursive: true);

  final settings =
      await ServerSettings.load(paths.settings) ?? await _firstStart(paths);

  final hostName = Platform.localHostname;
  final certificate = await ServerCertificate.loadOrCreate(
    paths.certificates,
    hostNames: [
      hostName,
      '$hostName.fritz.box',
      '$hostName.local',
      'localhost',
      ...options.multiOption('name'),
    ],
  );

  final database = openServerDatabase(paths.database);
  // Opens the file and runs migrations before the first request arrives.
  await database.customSelect('SELECT 1').get();
  final access = ServerAccess(
    database,
    certificateFingerprint: certificate.fingerprint,
  );
  await access.initialize();
  final console = ServerConsole(access);
  if (!await access.hasUsers()) await console.createFirstUser();

  final server = await shelf_io.serve(
    buildHandler(
      database: database,
      access: access,
      sync: ServerSync(database, settings: settings),
    ),
    InternetAddress.anyIPv4,
    port,
    securityContext: certificate.securityContext(),
  );

  await _printBanner(
    port: server.port,
    hostName: hostName,
    certificate: certificate,
    paths: paths,
    settings: settings,
  );

  console.start();

  final stopped = Completer<void>();
  Future<void> stop() async {
    if (stopped.isCompleted) return;
    stdout.writeln('\nServer wird beendet ...');
    await console.stop();
    await server.close(force: true);
    await database.close();
    stopped.complete();
  }

  ProcessSignal.sigint.watch().listen((_) => stop());
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => stop());
  }
  await stopped.future;
}

Future<ServerSettings> _firstStart(ServerPaths paths) async {
  var directory = '';
  if (stdin.hasTerminal) {
    stdout
      ..writeln('Erster Start des WealthFlow-Servers.')
      ..writeln(
        'In welchen Ordner soll zusätzlich die verschlüsselte Datendatei '
        'geschrieben werden?',
      )
      ..write('Ordner (leer lassen für keinen): ');
    directory = stdin.readLineSync()?.trim() ?? '';
    if (directory.isNotEmpty) {
      await Directory(directory).create(recursive: true);
    }
  }
  final settings = ServerSettings(dataFileDirectory: directory);
  await settings.save(paths.settings);
  return settings;
}

Future<void> _printBanner({
  required int port,
  required String hostName,
  required ServerCertificate certificate,
  required ServerPaths paths,
  required ServerSettings settings,
}) async {
  final addresses = await NetworkInterface.list(type: InternetAddressType.IPv4);
  stdout
    ..writeln('')
    ..writeln('WealthFlow-Server läuft (Version $serverVersion).')
    ..writeln('Fenster schließen oder Strg+C beendet den Server.')
    ..writeln('')
    ..writeln('Erreichbar im Heimnetz unter:')
    ..writeln('  https://$hostName:$port');
  for (final interface in addresses) {
    for (final address in interface.addresses) {
      if (!address.isLoopback) {
        stdout.writeln('  https://${address.address}:$port');
      }
    }
  }
  stdout
    ..writeln('')
    ..writeln('Fingerabdruck des Zertifikats (zum Vergleichen beim Koppeln):')
    ..writeln('  ${certificate.readableFingerprint}')
    ..writeln('')
    ..writeln('Datenbank: ${paths.database.path}')
    ..writeln(
      'Datendatei: ${settings.dataFileDirectory.isEmpty ? 'keine' : settings.dataFileDirectory}',
    );
}
