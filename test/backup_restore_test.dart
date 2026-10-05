import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/storage/data_export_native.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/security/data_cipher.dart';

final _now = DateTime.utc(2026, 9, 1);

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
  double balance = 1000,
}) => database.saveAccount(
  AccountsCompanion.insert(
    id: id,
    userId: userId,
    bankName: 'Bank',
    label: id,
    balance: Value(balance),
    availableBalance: Value(balance),
    createdAt: _now,
    updatedAt: _now,
  ),
);

LedgerEntriesCompanion _entry(
  String id,
  String userId,
  String accountId, {
  double amount = 100,
  bool isIncome = false,
  DateTime? date,
  String recurrenceId = '',
  String sourceType = 'manual',
  String sourceId = '',
  DateTime? updatedAt,
}) => LedgerEntriesCompanion.insert(
  id: id,
  userId: userId,
  bookingDate: date ?? DateTime(2026, 9, 2),
  amount: amount,
  isIncome: Value(isIncome),
  category: 'Sonstiges',
  accountId: Value(accountId),
  recurrenceId: Value(recurrenceId),
  sourceType: Value(sourceType),
  sourceId: Value(sourceId),
  createdAt: _now,
  updatedAt: updatedAt ?? _now,
);

Future<double> _balance(AppDatabase database, String accountId) async =>
    (await (database.select(
      database.accounts,
    )..where((row) => row.id.equals(accountId))).getSingle()).balance;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Backup-Passwort', () {
    test('opens the file with the password on another device', () async {
      final key = await DataCipher.deriveBackupKey(
        'geheimes Passwort',
        iterations: 1000,
      );
      final file = await DataCipher.encrypt(
        'Kontodaten',
        List<int>.filled(32, 9),
        backupKey: key,
      );

      expect(DataCipher.isPasswordProtected(file), isTrue);
      expect(file, isNot(contains('Kontodaten')));
      // Same device: the stored key matches the salt in the file.
      expect(
        await DataCipher.decryptWithPassword(file, stored: key),
        'Kontodaten',
      );
      // New device: only the password is known.
      expect(
        await DataCipher.decryptWithPassword(
          file,
          password: 'geheimes Passwort',
        ),
        'Kontodaten',
      );
      await expectLater(
        DataCipher.decryptWithPassword(file),
        throwsA(isA<BackupPasswordRequired>()),
      );
      await expectLater(
        DataCipher.decryptWithPassword(file, password: 'falsch'),
        throwsA(anything),
      );
    });
  });

  group('Wiederherstellung', () {
    late AppDatabase oldDevice;
    late AppDatabase newDevice;

    setUp(() {
      oldDevice = AppDatabase.forTesting(NativeDatabase.memory());
      newDevice = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await oldDevice.close();
      await newDevice.close();
    });

    test('restores a backup into a newly registered account', () async {
      await _createUser(oldDevice, 'old-user');
      await _createAccount(oldDevice, 'old-user', 'giro');
      await oldDevice.saveLedgerEntries([_entry('rent', 'old-user', 'giro')]);
      expect(await _balance(oldDevice, 'giro'), 900);
      final key = await DataCipher.deriveBackupKey('pw', iterations: 1000);
      oldDevice
        ..setDataFileKey('old-user', List<int>.filled(32, 1))
        ..setBackupKey('old-user', key);
      final file = await DataCipher.encrypt(
        jsonEncode(await oldDevice.exportUserData('old-user')),
        List<int>.filled(32, 1),
        backupKey: key,
      );

      await _createUser(newDevice, 'new-user');
      newDevice.setDataFileKey('new-user', List<int>.filled(32, 2));
      await expectLater(
        newDevice.decodeUserDataFile('new-user', file),
        throwsA(isA<BackupPasswordRequired>()),
      );
      final data = await newDevice.decodeUserDataFile(
        'new-user',
        file,
        password: 'pw',
      );
      await newDevice.mergeUserData('new-user', data);

      final accounts = await newDevice.watchAccounts('new-user').first;
      expect(accounts.single.id, 'giro');
      expect(accounts.single.balance, 900);
      final entries = await newDevice.watchLedgerEntries('new-user').first;
      expect(entries.single.id, 'rent');
    });

    test('corrects the kept balance when a newer booking arrives', () async {
      await _createUser(oldDevice, 'user');
      await _createAccount(oldDevice, 'user', 'giro');
      await oldDevice.saveLedgerEntries([_entry('food', 'user', 'giro')]);
      final exported = await oldDevice.exportUserData('user');

      // Same data on the new device, but the booking was changed there later
      // and the account was edited afterwards locally.
      await newDevice.close();
      newDevice = AppDatabase.forTesting(NativeDatabase.memory());
      await _createUser(newDevice, 'user');
      await newDevice.mergeUserData('user', exported);
      expect(await _balance(newDevice, 'giro'), 900);
      await newDevice.saveLedgerEntries([
        _entry('food', 'user', 'giro', amount: 50, updatedAt: _now),
      ]);
      expect(await _balance(newDevice, 'giro'), 950);
      await (newDevice.update(
        newDevice.accounts,
      )..where((row) => row.id.equals('giro'))).write(
        AccountsCompanion(updatedAt: Value(DateTime.utc(2099))),
      );

      // The file now carries a newer version of the booking (amount 250)
      // while the local account stays the newer one.
      final changed = await oldDevice.exportUserData('user');
      final rows = (changed['ledgerEntries'] as List)
          .cast<Map<String, dynamic>>();
      rows.single['amount'] = 250.0;
      rows.single['updatedAt'] = DateTime.utc(2098).millisecondsSinceEpoch;
      await newDevice.mergeUserData('user', _roundTrip(changed));

      expect(await _balance(newDevice, 'giro'), 750);
    });
  });

  group('Umbuchungen', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await _createUser(database, 'user');
      await _createAccount(database, 'user', 'giro');
      await _createAccount(database, 'user', 'savings', balance: 0);
    });

    tearDown(() => database.close());

    test('editing one side also updates the other side', () async {
      await database.saveLedgerEntries([
        _entry(
          'out',
          'user',
          'giro',
          sourceType: 'transfer',
          sourceId: 't1',
        ),
        _entry(
          'in',
          'user',
          'savings',
          isIncome: true,
          sourceType: 'transfer',
          sourceId: 't1',
        ),
      ]);
      expect(await _balance(database, 'giro'), 900);
      expect(await _balance(database, 'savings'), 100);

      await database.saveLedgerEntryWithCounterpart(
        _entry(
          'out',
          'user',
          'giro',
          amount: 150,
          sourceType: 'transfer',
          sourceId: 't1',
        ),
      );

      expect(await _balance(database, 'giro'), 850);
      expect(await _balance(database, 'savings'), 150);
    });

    test('editing a series keeps the incoming legs', () async {
      final entries = <LedgerEntriesCompanion>[];
      for (var month = 0; month < 3; month++) {
        final date = DateTime(2026, 7 + month, 2);
        entries
          ..add(
            _entry(
              'out-$month',
              'user',
              'giro',
              date: date,
              recurrenceId: 'series',
              sourceType: 'transfer',
              sourceId: 't$month',
            ),
          )
          ..add(
            _entry(
              'in-$month',
              'user',
              'savings',
              isIncome: true,
              date: date,
              recurrenceId: 'series',
              sourceType: 'transfer',
              sourceId: 't$month',
            ),
          );
      }
      await database.saveLedgerEntries(entries);
      expect(await _balance(database, 'giro'), 700);
      expect(await _balance(database, 'savings'), 300);
      final edited = (await database.watchLedgerEntries(
        'user',
      ).first).firstWhere((entry) => entry.id == 'out-0');

      await database.updateLedgerSeries(
        'series',
        'user',
        _entry(
          'out-0',
          'user',
          'giro',
          amount: 200,
          recurrenceId: 'series',
          sourceType: 'transfer',
          sourceId: 't0',
        ),
        edited: edited,
      );

      expect(await _balance(database, 'giro'), 400);
      expect(await _balance(database, 'savings'), 600);
      final saved = await database.watchLedgerEntries('user').first;
      final incoming = saved.where((entry) => entry.id.startsWith('in-'));
      expect(incoming.map((entry) => entry.accountId).toSet(), {'savings'});
      expect(incoming.every((entry) => entry.isIncome), isTrue);
      expect(saved.map((entry) => entry.sourceId).toSet(), {'t0', 't1', 't2'});
    });
  });

  group('Datendatei', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('wealthflow-test');
    });

    tearDown(() => directory.delete(recursive: true));

    test('replaces the file and keeps dated daily copies', () async {
      final path = '${directory.path}${Platform.pathSeparator}data.wflow';
      await writeDataFile('first', path);
      expect(await File(path).readAsString(), 'first');

      for (var day = 1; day <= 9; day++) {
        await File(path).setLastModified(DateTime(2026, 9, day, 12));
        await writeDataFile('day $day', path);
      }

      expect(await File(path).readAsString(), 'day 9');
      expect(File('$path.tmp').existsSync(), isFalse);
      final copies =
          directory
              .listSync()
              .map((entry) => entry.uri.pathSegments.last)
              .where((name) => name != 'data.wflow')
              .toList()
            ..sort();
      expect(copies, hasLength(dataFileGenerations));
      expect(copies.last, 'data.2026-09-09.wflow');
      expect(copies.first, 'data.2026-09-03.wflow');
    });
  });
}

Map<String, dynamic> _roundTrip(Map<String, Object?> data) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);
