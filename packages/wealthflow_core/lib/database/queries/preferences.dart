part of '../app_database.dart';

/// Benutzereinstellungen und Serverstatus.
extension PreferenceQueries on AppDatabase {
  Stream<UserPreference?> watchPreferences(String userId) => (select(
    userPreferences,
  )..where((row) => row.userId.equals(userId))).watchSingleOrNull();

  Future<UserPreference> preferencesFor(String userId) async {
    final current = await (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    if (current != null) return current;
    final now = DateTime.now().toUtc();
    await into(
      userPreferences,
    ).insert(UserPreferencesCompanion.insert(userId: userId, updatedAt: now));
    return (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingle();
  }

  /// Stores the server connection state shown in the settings.
  Future<void> saveServerState(
    String userId, {
    required bool connected,
    String serverUrl = '',
    String serverUsername = '',
    DateTime? lastSyncAt,
  }) async {
    await preferencesFor(userId);
    await (update(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).write(
      UserPreferencesCompanion(
        serverMode: Value(connected),
        serverUrl: Value(serverUrl),
        serverUsername: Value(serverUsername),
        lastSyncAt: Value(lastSyncAt),
      ),
    );
  }

  /// Sets where the data file of [userId] is written; empty turns it off.
  Future<void> setDataFilePath(String userId, String path) async {
    await preferencesFor(userId);
    await (update(userPreferences)..where((row) => row.userId.equals(userId)))
        .write(UserPreferencesCompanion(dataFilePath: Value(path)));
  }

  /// Sets the colour scheme: 'system', 'light' or 'dark'.
  Future<void> setThemeMode(String userId, String themeMode) async {
    await preferencesFor(userId);
    await (update(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).write(
      UserPreferencesCompanion(
        themeMode: Value(themeMode),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Future<void> savePreferences(UserPreferencesCompanion value) async {
    if (value.taxAllowance.present) {
      final maximum = (await appConfiguration()).maximumTaxAllowance;
      if (value.taxAllowance.value < 0 || value.taxAllowance.value > maximum) {
        throw StateError(
          'Der Freistellungsauftrag darf höchstens ${maximum.toStringAsFixed(2)} € betragen.',
        );
      }
    }
    await into(userPreferences).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  /// Updates only the saved inputs of the financial freedom calculator.
  Future<void> saveFreedomCalculator(
    String userId, {
    required double age,
    required double startCapital,
    required bool usePortfolio,
  }) async {
    await (update(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).write(
      UserPreferencesCompanion(
        freedomAge: Value(age),
        freedomStartCapital: Value(startCapital),
        freedomUsePortfolio: Value(usePortfolio),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }
}
