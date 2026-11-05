part of '../app_database.dart';

/// Konten, Kontostände und Kontonutzung.
extension AccountQueries on AppDatabase {
  /// Books entries whose date has arrived since the app was opened.
  Future<void> applyDueLedgerEntries(String userId) async {
    if (await _applyDueLedgerEntries(userId)) {
      await captureNetWorth(userId);
    }
  }

  Stream<List<Account>> watchAccounts(String userId) async* {
    if (await _applyDueLedgerEntries(userId)) {
      await captureNetWorth(userId);
    }
    yield* (select(accounts)
          ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
          ..orderBy([
            (row) => OrderingTerm.asc(row.displayOrder),
            (row) => OrderingTerm.asc(row.label),
          ]))
        .watch();
  }

  Stream<List<AccountBalanceHistory>> watchAccountBalanceHistories(
    String userId,
  ) =>
      (select(accountBalanceHistories)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.effectiveAt)]))
          .watch();

  Future<void> saveAccount(
    AccountsCompanion value, {
    DateTime? balanceEffectiveAt,
  }) async {
    final old = await (select(
      accounts,
    )..where((row) => row.id.equals(value.id.value))).getSingleOrNull();
    if (old != null && value.usageType.present) {
      final requested = value.usageType.value;
      if (old.usageType != 'unassigned' && requested != old.usageType) {
        throw StateError(
          'Die Verwendung eines bereits zugeordneten Kontos kann nicht geändert werden.',
        );
      }
      if (requested != 'unassigned' &&
          !await accountCanBeUsed(old.userId, old.id, requested)) {
        throw StateError('Das Konto enthält Daten aus einem anderen Modul.');
      }
    }
    var valueToSave = value;
    if (old == null && !value.displayOrder.present) {
      final siblings =
          await (select(accounts)..where(
                (row) =>
                    row.userId.equals(value.userId.value) &
                    row.deletedAt.isNull(),
              ))
              .get();
      final nextOrder =
          siblings.fold<int>(
            0,
            (maximum, account) =>
                account.displayOrder > maximum ? account.displayOrder : maximum,
          ) +
          1;
      valueToSave = value.copyWith(displayOrder: Value(nextOrder));
    }
    await transaction(() async {
      await into(accounts).insertOnConflictUpdate(valueToSave);
      if (balanceEffectiveAt != null) {
        final saved = await (select(
          accounts,
        )..where((row) => row.id.equals(value.id.value))).getSingle();
        await into(accountBalanceHistories).insert(
          AccountBalanceHistoriesCompanion.insert(
            id: AppDatabase._uuid.v4(),
            userId: saved.userId,
            accountId: saved.id,
            effectiveAt: balanceEffectiveAt,
            balance: saved.balance,
            availableBalance: saved.availableBalance,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
    });
    await captureNetWorth(value.userId.value);
  }

  Future<void> saveAccountBalanceHistory({
    required String userId,
    required String accountId,
    required DateTime effectiveAt,
    required double balance,
    required double availableBalance,
  }) async {
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Konto wurde nicht gefunden.');
    await transaction(() async {
      await into(accountBalanceHistories).insert(
        AccountBalanceHistoriesCompanion.insert(
          id: AppDatabase._uuid.v4(),
          userId: userId,
          accountId: accountId,
          effectiveAt: effectiveAt,
          balance: balance,
          availableBalance: availableBalance,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      if (!effectiveAt.isAfter(DateTime.now())) {
        await (update(
          accounts,
        )..where((row) => row.id.equals(accountId))).write(
          AccountsCompanion(
            balance: Value(balance),
            availableBalance: Value(availableBalance),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteAccountBalanceHistory(String id, String userId) async {
    await (update(
      accountBalanceHistories,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      AccountBalanceHistoriesCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> reorderAccounts(String userId, List<String> accountIds) async {
    await transaction(() async {
      for (final indexed in accountIds.indexed) {
        await (update(accounts)..where(
              (row) => row.id.equals(indexed.$2) & row.userId.equals(userId),
            ))
            .write(
              AccountsCompanion(
                displayOrder: Value(indexed.$1 + 1),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
    _schedulePersist(userId);
  }

  Future<void> selectAccountForUsage({
    required String userId,
    required String accountId,
    required String usageType,
  }) async {
    if (!const {'household', 'portfolio'}.contains(usageType)) {
      throw ArgumentError.value(usageType, 'usageType');
    }
    await transaction(() async {
      final account =
          await (select(accounts)..where(
                (row) =>
                    row.id.equals(accountId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (account == null) throw StateError('Das Konto ist nicht verfügbar.');
      if (account.usageType != 'unassigned' && account.usageType != usageType) {
        throw StateError(
          'Das Konto wird bereits in einem anderen Modul verwendet.',
        );
      }
      final hasLedger =
          await (select(ledgerEntries)
                ..limit(1)
                ..where(
                  (row) =>
                      row.userId.equals(userId) &
                      row.accountId.equals(accountId) &
                      row.deletedAt.isNull(),
                ))
              .getSingleOrNull() !=
          null;
      final hasPortfolio =
          await (select(investments)
                    ..limit(1)
                    ..where(
                      (row) =>
                          row.userId.equals(userId) &
                          row.accountId.equals(accountId) &
                          row.deletedAt.isNull(),
                    ))
                  .getSingleOrNull() !=
              null ||
          await (select(physicalAssets)
                    ..limit(1)
                    ..where(
                      (row) =>
                          row.userId.equals(userId) &
                          row.accountId.equals(accountId) &
                          row.deletedAt.isNull(),
                    ))
                  .getSingleOrNull() !=
              null;
      if (usageType == 'portfolio' && hasLedger) {
        throw StateError(
          'Konten mit Haushaltsbuchungen können keinem Portfolio zugeordnet werden.',
        );
      }
      if (usageType == 'household' && hasPortfolio) {
        throw StateError(
          'Konten mit Portfolio-Daten können keinem Haushaltsbuch zugeordnet werden.',
        );
      }
      await (update(accounts)..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          usageType: Value(usageType),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      if (usageType == 'portfolio') {
        await (update(investments)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.accountId.equals('') &
                  row.deletedAt.isNull(),
            ))
            .write(InvestmentsCompanion(accountId: Value(accountId)));
        await (update(physicalAssets)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.accountId.equals('') &
                  row.deletedAt.isNull(),
            ))
            .write(PhysicalAssetsCompanion(accountId: Value(accountId)));
      }
      final preference = await preferencesFor(userId);
      await into(userPreferences).insertOnConflictUpdate(
        preference
            .toCompanion(false)
            .copyWith(
              selectedHouseholdAccountId: usageType == 'household'
                  ? Value(accountId)
                  : null,
              selectedPortfolioAccountId: usageType == 'portfolio'
                  ? Value(accountId)
                  : null,
              updatedAt: Value(DateTime.now().toUtc()),
            ),
      );
    });
    _schedulePersist(userId);
  }

  Future<bool> accountCanBeUsed(
    String userId,
    String accountId,
    String usageType,
  ) async {
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null ||
        (account.usageType != 'unassigned' && account.usageType != usageType)) {
      return false;
    }
    if (usageType == 'portfolio') {
      return await (select(ledgerEntries)
                ..limit(1)
                ..where(
                  (row) =>
                      row.userId.equals(userId) &
                      row.accountId.equals(accountId) &
                      row.deletedAt.isNull(),
                ))
              .getSingleOrNull() ==
          null;
    }
    return await (select(investments)
                  ..limit(1)
                  ..where(
                    (row) =>
                        row.userId.equals(userId) &
                        row.accountId.equals(accountId) &
                        row.deletedAt.isNull(),
                  ))
                .getSingleOrNull() ==
            null &&
        await (select(physicalAssets)
                  ..limit(1)
                  ..where(
                    (row) =>
                        row.userId.equals(userId) &
                        row.accountId.equals(accountId) &
                        row.deletedAt.isNull(),
                  ))
                .getSingleOrNull() ==
            null;
  }

  Future<void> deleteAccount(String id, String userId) async {
    final heldPositions =
        await (select(investments)
              ..where(
                (row) =>
                    row.accountId.equals(id) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              )
              ..limit(1))
            .get();
    final heldAssets =
        await (select(physicalAssets)
              ..where(
                (row) =>
                    row.accountId.equals(id) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              )
              ..limit(1))
            .get();
    if (heldPositions.isNotEmpty || heldAssets.isNotEmpty) {
      throw StateError(
        'Auf diesem Konto liegen noch Positionen. Bitte sie zuerst verkaufen '
        'oder löschen.',
      );
    }
    await (update(
      accounts,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      AccountsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }
}
