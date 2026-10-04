import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:wealthflow/core/database/app_database.dart';
import 'package:wealthflow/core/providers.dart';
import 'package:wealthflow/core/storage/import_preview.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_DE'));

  test('German month names work once date formats are loaded', () {
    expect(DateFormat.MMMM('de_DE').format(DateTime(2026, 3)), 'März');
    expect(DateFormat.Hm('de_DE').format(DateTime(2026, 3, 1, 14, 5)), '14:05');
  });

  test('import preview describes the backup date in German', () {
    final preview = ImportPreview.fromData({
      'exportedAt': DateTime(2026, 10, 4, 9, 30).toIso8601String(),
      'user': {'displayName': 'Test'},
    });

    expect(preview.describe(), contains('Gesichert am 04.10.2026 09:30'));
  });

  test('the system theme setting follows the device', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 10, 1);
    await database.createUser(
      UsersCompanion.insert(
        id: 'theme-user',
        email: 'theme@example.test',
        displayName: 'Theme',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.savePreferences(
      UserPreferencesCompanion.insert(
        userId: 'theme-user',
        themeMode: const Value('system'),
        updatedAt: now,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentUserIdProvider.overrideWithValue('theme-user'),
      ],
    );
    addTearDown(container.dispose);

    await container.read(preferencesProvider.future);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
