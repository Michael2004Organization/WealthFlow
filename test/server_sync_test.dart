import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/security/secure_session_store.dart';
import 'package:wealthflow/core/server/server_connection.dart';
import 'package:wealthflow/core/server/server_sync.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/security/data_cipher.dart';
import 'package:wealthflow_core/server/pairing.dart';

import 'support/fake_server.dart';

final _now = DateTime.utc(2026, 10, 5, 12);

Future<AppDatabase> _device(String userId) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await database.createUser(
    UsersCompanion.insert(
      id: userId,
      email: '$userId@example.test',
      displayName: userId,
      passwordHash: 'hash',
      passwordSalt: 'salt',
      createdAt: _now,
      updatedAt: _now,
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion.insert(userId: userId, updatedAt: _now),
  );
  return database;
}

Future<void> _createAccount(AppDatabase database, String userId) =>
    database.saveAccount(
      AccountsCompanion.insert(
        id: 'giro',
        userId: userId,
        bankName: 'Bank',
        label: 'Giro',
        balance: const Value(1000),
        availableBalance: const Value(1000),
        createdAt: _now,
        updatedAt: _now,
      ),
    );

Future<double?> _balance(AppDatabase database) async => (await (database.select(
  database.accounts,
)..where((row) => row.id.equals('giro'))).getSingleOrNull())?.balance;

Future<void> _waitFor(bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(() => HttpOverrides.global = null);

  late FakeServer server;
  late AppDatabase serverDatabase;
  late AppDatabase phone;
  late AppDatabase laptop;
  final controllers = <ServerSyncController>[];

  setUp(() async {
    final code = newPairingCode();
    server = await FakeServer.start(knownCode: code);
    serverDatabase = await _device('server-user');
    server.syncDatabase = serverDatabase;
    phone = await _device('phone');
    laptop = await _device('laptop');
  });

  tearDown(() async {
    for (final controller in controllers) {
      await controller.idle;
      controller.dispose();
    }
    controllers.clear();
    await server.close();
    await serverDatabase.close();
    await phone.close();
    await laptop.close();
  });

  Future<ServerSyncController> connect(
    AppDatabase database,
    String userId, {
    Duration debounce = const Duration(seconds: 30),
  }) async {
    final connection = ServerConnectionController(
      userId: userId,
      sessionStore: SecureSessionStore(),
    );
    final ok = await connection.pair(
      address: server.address,
      code: server.knownCode,
      email: 'michael@example.de',
      password: 'geheimes-passwort',
    );
    expect(ok, isTrue, reason: connection.state.error);
    final sync = ServerSyncController(
      database: database,
      userId: userId,
      connection: connection,
      interval: const Duration(hours: 1),
      debounce: debounce,
    );
    controllers.add(sync);
    return sync;
  }

  test('Buchung vom Handy erscheint auf dem Laptop', () async {
    await _createAccount(phone, 'phone');
    await phone.saveLedgerEntries([
      LedgerEntriesCompanion.insert(
        id: 'miete',
        userId: 'phone',
        bookingDate: DateTime(2026, 10, 2),
        amount: 100,
        category: 'Wohnen',
        accountId: const Value('giro'),
        createdAt: _now,
        updatedAt: _now,
      ),
    ]);

    final phoneSync = await connect(phone, 'phone');
    expect(await phoneSync.syncNow(), isTrue, reason: phoneSync.state.error);
    final laptopSync = await connect(laptop, 'laptop');
    expect(await laptopSync.syncNow(), isTrue);

    expect(await _balance(serverDatabase), 900);
    expect(await _balance(laptop), 900);
    expect(laptopSync.state.lastSyncAt, isNotNull);
    expect(laptopSync.state.dataFile, ServerDataFile.needsBackupPassword);
    final preference = await laptop.preferencesFor('laptop');
    expect(preference.serverMode, isTrue);
    expect(preference.lastSyncAt, isNotNull);
  });

  test('schickt das Backup-Passwort für die Datendatei mit', () async {
    phone.setBackupKey(
      'phone',
      await DataCipher.deriveBackupKey('pw', iterations: 1000),
    );
    final sync = await connect(phone, 'phone');
    expect(await sync.syncNow(), isTrue);
    expect(server.received['/api/sync']!['backupKey'], isA<Map>());
    expect(sync.state.dataFile, ServerDataFile.written);
  });

  test('gleicht nach einer Änderung von selbst ab, ohne Schleife', () async {
    final sync = await connect(
      phone,
      'phone',
      debounce: const Duration(milliseconds: 50),
    );
    await _waitFor(() => server.syncCalls == 1 && !sync.state.isRunning);
    // The sync's own writes (merge, sync time) do not start another one.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(server.syncCalls, 1);

    await _createAccount(phone, 'phone');
    await _waitFor(() => server.syncCalls == 2);
    expect(server.syncCalls, 2);
    await _waitFor(() => !sync.state.isRunning);
    expect(await _balance(serverDatabase), 1000);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(server.syncCalls, 2);
  });

  test('PC aus: Meldung, lokale Daten bleiben', () async {
    final sync = await connect(phone, 'phone');
    await sync.syncNow();
    await server.close();
    await _createAccount(phone, 'phone');

    expect(await sync.syncNow(), isFalse);
    expect(sync.state.error, contains('start.cmd'));
    expect(await _balance(phone), 1000);
  });
}
