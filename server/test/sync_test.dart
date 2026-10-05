import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/security/data_cipher.dart';
import 'package:wealthflow_core/server/pairing.dart';
import 'package:wealthflow_core/storage/data_file.dart';
import 'package:wealthflow_server/wealthflow_server.dart';

final _now = DateTime.utc(2026, 10, 5, 12);

Future<void> _createUser(AppDatabase database, String id) async {
  await database.createUser(
    UsersCompanion.insert(
      id: id,
      email: '$id@example.test',
      displayName: id,
      passwordHash: 'hash',
      passwordSalt: 'salt',
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion.insert(userId: id, updatedAt: _now),
  );
}

Future<void> _createAccount(
  AppDatabase database,
  String userId,
  String id, {
  String label = 'Giro',
}) => database.saveAccount(
  AccountsCompanion.insert(
    id: id,
    userId: userId,
    bankName: 'Bank',
    label: label,
    balance: const Value(1000),
    availableBalance: const Value(1000),
    createdAt: _now,
    updatedAt: _now,
  ),
);

LedgerEntriesCompanion _entry(String id, String userId, String accountId) =>
    LedgerEntriesCompanion.insert(
      id: id,
      userId: userId,
      bookingDate: DateTime(2026, 10, 2),
      amount: 100,
      category: 'Sonstiges',
      accountId: Value(accountId),
      createdAt: _now,
      updatedAt: _now,
    );

Future<Account?> _account(AppDatabase database, String id) => (database.select(
  database.accounts,
)..where((row) => row.id.equals(id))).getSingleOrNull();

/// Sends the data like the app does, through JSON as over the network.
Map<String, Object?> _wire(Map<String, Object?> data) =>
    Map<String, Object?>.from(jsonDecode(jsonEncode(data)) as Map);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase server;
  late AppDatabase phone;
  late AppDatabase laptop;
  late ServerSync sync;
  const context = AccessContext(userId: 'srv', deviceId: 'device');

  setUp(() async {
    server = AppDatabase(NativeDatabase.memory(), writeDataFile: writeDataFile);
    phone = AppDatabase.forTesting(NativeDatabase.memory());
    laptop = AppDatabase.forTesting(NativeDatabase.memory());
    await _createUser(server, 'srv');
    await _createUser(phone, 'phone-user');
    await _createUser(laptop, 'laptop-user');
    sync = ServerSync(server, settings: const ServerSettings());
  });

  tearDown(() async {
    await server.close();
    await phone.close();
    await laptop.close();
  });

  /// One sync round of a device: send its export, merge the answer.
  Future<void> syncDevice(AppDatabase device, String userId) async {
    final result = await sync.sync(
      context,
      _wire(await device.exportUserData(userId)),
    );
    await device.mergeUserData(userId, _wire(result.data));
  }

  test('zwei Geräte sehen nach dem Abgleich dieselben Daten', () async {
    await _createAccount(phone, 'phone-user', 'giro');
    await phone.saveLedgerEntries([_entry('miete', 'phone-user', 'giro')]);

    await syncDevice(phone, 'phone-user');
    await syncDevice(laptop, 'laptop-user');

    final onLaptop = await _account(laptop, 'giro');
    expect(onLaptop, isNotNull);
    expect(onLaptop!.userId, 'laptop-user');
    expect(onLaptop.balance, 900);
    expect((await _account(server, 'giro'))!.balance, 900);

    // A booking made offline on the laptop reaches the phone, and the
    // balance is corrected once on every side.
    await laptop.saveLedgerEntries([_entry('strom', 'laptop-user', 'giro')]);
    expect((await _account(laptop, 'giro'))!.balance, 800);
    await syncDevice(laptop, 'laptop-user');
    await syncDevice(phone, 'phone-user');
    await syncDevice(laptop, 'laptop-user');

    expect((await _account(phone, 'giro'))!.balance, 800);
    expect((await _account(laptop, 'giro'))!.balance, 800);
    expect((await _account(server, 'giro'))!.balance, 800);
  });

  test('neuere Änderung gewinnt, Löschungen kommen an', () async {
    await _createAccount(phone, 'phone-user', 'giro');
    await syncDevice(phone, 'phone-user');
    await syncDevice(laptop, 'laptop-user');

    final renamed = (await _account(laptop, 'giro'))!;
    await laptop
        .update(laptop.accounts)
        .replace(
          renamed.copyWith(
            label: 'Haushalt',
            updatedAt: _now.add(const Duration(hours: 1)),
          ),
        );
    await syncDevice(laptop, 'laptop-user');
    await syncDevice(phone, 'phone-user');
    expect((await _account(phone, 'giro'))!.label, 'Haushalt');

    final current = (await _account(phone, 'giro'))!;
    await phone
        .update(phone.accounts)
        .replace(
          current.copyWith(
            deletedAt: Value(_now.add(const Duration(hours: 2))),
            updatedAt: _now.add(const Duration(hours: 2)),
          ),
        );
    await syncDevice(phone, 'phone-user');
    await syncDevice(laptop, 'laptop-user');
    expect((await _account(laptop, 'giro'))!.deletedAt, isNotNull);
  });

  test('Daten einer anderen Person werden nie überschrieben', () async {
    await _createUser(server, 'other');
    await _createAccount(server, 'other', 'fremd', label: 'Fremdes Konto');
    await _createAccount(phone, 'phone-user', 'fremd', label: 'Übernahme');

    final result = await sync.sync(
      context,
      _wire(await phone.exportUserData('phone-user')),
    );

    final foreign = (await _account(server, 'fremd'))!;
    expect(foreign.userId, 'other');
    expect(foreign.label, 'Fremdes Konto');
    expect(result.data['accounts'], isEmpty);
  });

  group('Datendatei', () {
    late Directory folder;

    setUp(() async {
      folder = await Directory.systemTemp.createTemp('wealthflow-sync');
      sync = ServerSync(
        server,
        settings: ServerSettings(dataFileDirectory: folder.path),
      );
    });

    tearDown(() => folder.delete(recursive: true));

    test('ohne gewählten Ordner wird keine Datei geschrieben', () async {
      sync = ServerSync(server, settings: const ServerSettings());
      final result = await sync.sync(context, {'accounts': []});
      expect(result.dataFile, DataFileResult.off);
    });

    test('ohne Backup-Passwort der App keine Datei', () async {
      final result = await sync.sync(context, {'accounts': []});
      expect(result.dataFile, DataFileResult.needsBackupPassword);
      expect(folder.listSync(), isEmpty);
    });

    test('mit Backup-Passwort lässt sich die Datei überall öffnen', () async {
      await _createAccount(phone, 'phone-user', 'giro');
      final key = await DataCipher.deriveBackupKey('pw', iterations: 1000);

      final result = await sync.sync(
        context,
        _wire(await phone.exportUserData('phone-user')),
        backupKey: BackupKey.fromJson(_wire({'k': key.toJson()})['k']),
      );

      expect(result.dataFile, DataFileResult.written);
      final file = File(
        '${folder.path}${Platform.pathSeparator}wealthflow-srv@example.test.wflow',
      );
      final content = await file.readAsString();
      expect(content, isNot(contains('Giro')));
      final opened = await DataCipher.decryptWithPassword(
        content,
        password: 'pw',
      );
      expect(opened, contains('Giro'));
    });
  });

  group('über /api/sync', () {
    late ServerAccess access;
    late Handler handler;
    late String token;

    setUp(() async {
      access = ServerAccess(
        server,
        certificateFingerprint: 'AA' * 32,
        hasher: const ServerPasswordHasher(memory: 64, iterations: 1),
      );
      await access.initialize();
      handler = buildHandler(database: server, access: access, sync: sync);
      await access.createUser(
        email: 'michael@example.de',
        displayName: 'Michael',
        password: 'richtig-langes-passwort',
      );
      final code = access.startPairing();
      final clientNonce = newPairingNonce();
      final challenge = await access.pairingChallenge(clientNonce);
      final session = await access.completePairing(
        clientNonce: clientNonce,
        clientProof: await pairingProof(
          code: code,
          role: 'client',
          fingerprint: 'AA' * 32,
          clientNonce: clientNonce,
          serverNonce: challenge['serverNonce']!,
        ),
        email: 'michael@example.de',
        password: 'richtig-langes-passwort',
        deviceName: 'Handy',
      );
      token = session.accessToken;
    });

    Future<(int, Map<String, Object?>)> post(Map<String, Object?> body) async {
      final response = await handler(
        Request(
          'POST',
          Uri.parse('https://localhost:8443/api/sync'),
          body: jsonEncode(body),
          headers: {'authorization': 'Bearer $token'},
        ),
      );
      final decoded = jsonDecode(await response.readAsString());
      return (response.statusCode, Map<String, Object?>.from(decoded as Map));
    }

    test('gleicht ab und meldet den Stand der Datendatei', () async {
      await _createAccount(phone, 'phone-user', 'giro');
      final (status, body) = await post({
        'schemaVersion': server.schemaVersion,
        'data': _wire(await phone.exportUserData('phone-user')),
      });
      expect(status, 200);
      expect(body['dataFile'], 'off');
      final data = body['data']! as Map;
      expect(data['accounts'], hasLength(1));
    });

    test('lehnt eine andere Datenbank-Version ab', () async {
      final (status, body) = await post({
        'schemaVersion': server.schemaVersion - 1,
        'data': <String, Object?>{},
      });
      expect(status, 409);
      expect(body['error'], contains('Versionen'));
    });

    test('ohne Anmeldung kein Abgleich', () async {
      token = 'falsch';
      final (status, _) = await post({
        'schemaVersion': server.schemaVersion,
        'data': <String, Object?>{},
      });
      expect(status, 401);
    });
  });
}
