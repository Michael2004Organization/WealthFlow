part of '../app_database.dart';

/// Haushaltsbuch, Erinnerungen, Stammdaten und Fahrzeuge.
extension HouseholdQueries on AppDatabase {
  Stream<List<LedgerEntry>> watchLedgerEntries(String userId) =>
      (select(ledgerEntries)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Stream<List<MasterDataData>> watchMasterData(String userId) =>
      (select(masterData)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.kind),
              (row) => OrderingTerm.asc(row.value),
            ]))
          .watch();

  Stream<List<AppReminder>> watchReminders(String userId) =>
      (select(reminders)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
          .watch();

  Future<void> saveReminder(RemindersCompanion value) async {
    await into(reminders).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteReminder(String id, String userId) async {
    await (update(
      reminders,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      RemindersCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Future<void> saveMasterDatum(MasterDataCompanion value) async {
    await into(masterData).insert(value, mode: InsertMode.insertOrIgnore);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteMasterDatum(String id, String userId) async {
    await (update(
      masterData,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      MasterDataCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  /// Replaces all master data of [kind] by [values]. Rows are revived
  /// instead of inserted again, because (user, kind, value) is unique.
  Future<void> replaceMasterData(
    String userId,
    String kind,
    Set<String> values,
  ) async {
    final now = DateTime.now().toUtc();
    final rows = await (select(
      masterData,
    )..where((row) => row.userId.equals(userId) & row.kind.equals(kind))).get();
    await transaction(() async {
      for (final row in rows) {
        final keep = values.contains(row.value);
        if (keep == (row.deletedAt == null)) continue;
        await (update(masterData)..where((r) => r.id.equals(row.id))).write(
          MasterDataCompanion(
            deletedAt: Value(keep ? null : now),
            updatedAt: Value(now),
          ),
        );
      }
      final known = {for (final row in rows) row.value};
      for (final value in values.difference(known)) {
        await into(masterData).insert(
          MasterDataCompanion.insert(
            id: AppDatabase._uuid.v4(),
            userId: userId,
            kind: kind,
            value: value,
            createdAt: now,
            updatedAt: Value(now),
          ),
        );
      }
    });
    _schedulePersist(userId);
  }

  Future<void> saveLedgerEntry(LedgerEntriesCompanion value) =>
      saveLedgerEntries([value]);

  Future<void> saveLedgerEntries(
    Iterable<LedgerEntriesCompanion> values,
  ) async {
    final entriesToSave = values.toList();
    await transaction(() async {
      for (final value in entriesToSave) {
        final accountId = value.accountId.present ? value.accountId.value : '';
        if (accountId.isNotEmpty) {
          final userId = value.userId.value;
          if (!await accountCanBeUsed(userId, accountId, 'household')) {
            throw StateError(
              'Das Konto ist bereits einem Portfolio oder anderen Daten zugeordnet.',
            );
          }
          await (update(accounts)..where(
                (row) => row.id.equals(accountId) & row.userId.equals(userId),
              ))
              .write(
                AccountsCompanion(
                  usageType: const Value('household'),
                  updatedAt: Value(DateTime.now().toUtc()),
                ),
              );
          final preference = await preferencesFor(userId);
          if (preference.selectedHouseholdAccountId.isEmpty) {
            await into(userPreferences).insertOnConflictUpdate(
              preference
                  .toCompanion(false)
                  .copyWith(
                    selectedHouseholdAccountId: Value(accountId),
                    updatedAt: Value(DateTime.now().toUtc()),
                  ),
            );
          }
        }
        final old = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingleOrNull();
        if (old != null) await _applyLedgerToAccount(old, reverse: true);
        await into(ledgerEntries).insertOnConflictUpdate(value);
        final saved = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(value.id.value))).getSingle();
        await _applyLedgerToAccount(saved);
        final linkedCostId = 'ledger:${saved.id}';
        if (saved.vehicleId.isNotEmpty &&
            !saved.isIncome &&
            saved.sourceType != 'vehicle') {
          await into(vehicleCosts).insertOnConflictUpdate(
            VehicleCostsCompanion.insert(
              id: linkedCostId,
              userId: saved.userId,
              vehicleId: saved.vehicleId,
              bookingDate: saved.bookingDate,
              category: saved.category,
              amount: saved.amount,
              notes: Value(
                saved.description.isNotEmpty
                    ? saved.description
                    : saved.merchant,
              ),
              createdAt: old?.createdAt ?? saved.createdAt,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        } else {
          await (update(
            vehicleCosts,
          )..where((row) => row.id.equals(linkedCostId))).write(
            VehicleCostsCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      }
    });
    for (final userId in entriesToSave.map((e) => e.userId.value).toSet()) {
      await captureNetWorth(userId);
    }
  }

  /// Applies [template] to every entry of a monthly series.
  ///
  /// Transfers and savings keep both legs: entries on the other side of
  /// [edited] (the incoming or outgoing counterpart) only take over amount
  /// and texts and keep their own account, direction and category. Every
  /// entry keeps its own link to its counterpart.
  Future<void> updateLedgerSeries(
    String recurrenceId,
    String userId,
    LedgerEntriesCompanion template, {
    LedgerEntry? edited,
  }) async {
    if (recurrenceId.isEmpty) return;
    final existing =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.recurrenceId.equals(recurrenceId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final now = DateTime.now().toUtc();
    final editedIsIncome =
        edited?.isIncome ??
        (template.isIncome.present ? template.isIncome.value : false);
    final replacements = existing.map((entry) {
      if (_isLinkedLedgerEntry(entry) && entry.isIncome != editedIsIncome) {
        return _counterpartUpdate(entry, template, now, keepDate: true);
      }
      return template.copyWith(
        id: Value(entry.id),
        userId: Value(entry.userId),
        bookingDate: Value(entry.bookingDate),
        budgetMonth: Value(entry.budgetMonth),
        recurrenceId: Value(entry.recurrenceId),
        sourceType: Value(entry.sourceType),
        sourceId: Value(entry.sourceId),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(now),
      );
    }).toList();
    await saveLedgerEntries(replacements);
  }

  /// Saves an edited entry. For transfers and savings the other leg follows
  /// amount, date and texts, so both account balances stay consistent.
  Future<void> saveLedgerEntryWithCounterpart(
    LedgerEntriesCompanion value,
  ) async {
    final sourceType = value.sourceType.present ? value.sourceType.value : '';
    final sourceId = value.sourceId.present ? value.sourceId.value : '';
    if ((sourceType != 'transfer' && sourceType != 'saving') ||
        sourceId.isEmpty) {
      return saveLedgerEntries([value]);
    }
    final counterparts =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.sourceId.equals(sourceId) &
                  row.userId.equals(value.userId.value) &
                  row.id.equals(value.id.value).not() &
                  row.deletedAt.isNull(),
            ))
            .get();
    final now = DateTime.now().toUtc();
    await saveLedgerEntries([
      value,
      for (final counterpart in counterparts)
        _counterpartUpdate(counterpart, value, now, keepDate: false),
    ]);
  }

  bool _isLinkedLedgerEntry(LedgerEntry entry) =>
      (entry.sourceType == 'transfer' || entry.sourceType == 'saving') &&
      entry.sourceId.isNotEmpty;

  LedgerEntriesCompanion _counterpartUpdate(
    LedgerEntry counterpart,
    LedgerEntriesCompanion source,
    DateTime now, {
    required bool keepDate,
  }) {
    final companion = counterpart.toCompanion(false);
    return companion.copyWith(
      amount: source.amount.present ? source.amount : companion.amount,
      bookingDate: !keepDate && source.bookingDate.present
          ? source.bookingDate
          : companion.bookingDate,
      budgetMonth: !keepDate && source.budgetMonth.present
          ? source.budgetMonth
          : companion.budgetMonth,
      merchant: source.merchant.present ? source.merchant : companion.merchant,
      description: source.description.present
          ? source.description
          : companion.description,
      paymentMethod: source.paymentMethod.present
          ? source.paymentMethod
          : companion.paymentMethod,
      // Left out so saveLedgerEntries reverses and re-applies the leg.
      accountApplied: const Value.absent(),
      updatedAt: Value(now),
    );
  }

  Future<void> deleteLedgerEntry(String id, String userId) async {
    await transaction(() async {
      final entry =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.id.equals(id) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (entry == null) return;
      await _applyLedgerToAccount(entry, reverse: true);
      await (update(
        ledgerEntries,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        LedgerEntriesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      final linkedCostIds = [
        'ledger:${entry.id}',
        if (entry.sourceType == 'vehicle' && entry.sourceId.isNotEmpty)
          entry.sourceId,
      ];
      await (update(vehicleCosts)..where(
            (row) => row.id.isIn(linkedCostIds) & row.userId.equals(userId),
          ))
          .write(
            VehicleCostsCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteLinkedLedgerEntries(String sourceId, String userId) async {
    if (sourceId.isEmpty) return;
    await transaction(() async {
      final entries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.sourceId.equals(sourceId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in entries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(ledgerEntries)..where(
            (row) =>
                row.sourceId.equals(sourceId) &
                row.userId.equals(userId) &
                row.deletedAt.isNull(),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  /// Restores previously deleted ledger entries, e.g. after "Rückgängig".
  ///
  /// The entries are saved as new so their account effect is applied again.
  Future<void> restoreLedgerEntries(Iterable<LedgerEntry> entries) {
    final now = DateTime.now().toUtc();
    return saveLedgerEntries(
      entries.map(
        (entry) => entry
            .toCompanion(false)
            .copyWith(
              deletedAt: const Value(null),
              accountApplied: const Value(false),
              updatedAt: Value(now),
            ),
      ),
    );
  }

  Future<void> deleteLedgerSeries(String recurrenceId, String userId) async {
    await transaction(() async {
      final entries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.recurrenceId.equals(recurrenceId) &
                    row.userId.equals(userId) &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in entries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(ledgerEntries)..where(
            (row) =>
                row.recurrenceId.equals(recurrenceId) &
                row.userId.equals(userId),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Future<void> _applyLedgerToAccount(
    LedgerEntry entry, {
    bool reverse = false,
  }) async {
    if (entry.accountId.isEmpty || entry.deletedAt != null) return;
    if (reverse && !entry.accountApplied) return;
    if (!reverse && entry.accountApplied) return;
    final now = DateTime.now();
    final bookingDay = ledgerEffectiveDate(
      entry.bookingDate,
      entry.budgetMonth,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (bookingDay.isAfter(today)) return;
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(entry.accountId) &
                  row.userId.equals(entry.userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) return;
    var delta = entry.isIncome ? entry.amount : -entry.amount;
    if (reverse) delta = -delta;
    await (update(accounts)..where((row) => row.id.equals(account.id))).write(
      AccountsCompanion(
        balance: Value(account.balance + delta),
        availableBalance: Value(account.availableBalance + delta),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await (update(ledgerEntries)..where((row) => row.id.equals(entry.id)))
        .write(LedgerEntriesCompanion(accountApplied: Value(!reverse)));
  }

  Future<bool> _applyDueLedgerEntries(String userId) => transaction(() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final due =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNull() &
                  row.accountApplied.equals(false) &
                  row.accountId.isNotValue('') &
                  row.bookingDate.isSmallerThanValue(tomorrow),
            ))
            .get();
    for (final entry in due) {
      await _applyLedgerToAccount(entry);
    }
    return due.isNotEmpty;
  });

  Stream<List<Vehicle>> watchVehicles(String userId) =>
      (select(vehicles)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.make)]))
          .watch();

  Future<void> saveVehicle(VehiclesCompanion value) async {
    await into(vehicles).insertOnConflictUpdate(value);
    await captureNetWorth(value.userId.value);
  }

  Future<void> deleteVehicle(String id, String userId) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
      final linkedEntries =
          await (select(ledgerEntries)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.vehicleId.equals(id) &
                    row.sourceType.equals('vehicle') &
                    row.deletedAt.isNull(),
              ))
              .get();
      for (final entry in linkedEntries) {
        await _applyLedgerToAccount(entry, reverse: true);
      }
      await (update(
        vehicles,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        VehiclesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (update(vehicleCosts)..where(
            (row) => row.vehicleId.equals(id) & row.userId.equals(userId),
          ))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      await (update(ledgerEntries)..where(
            (row) =>
                row.userId.equals(userId) &
                row.vehicleId.equals(id) &
                row.sourceType.equals('vehicle'),
          ))
          .write(
            LedgerEntriesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    });
    await captureNetWorth(userId);
  }

  Stream<List<VehicleCost>> watchVehicleCosts(String userId) =>
      (select(vehicleCosts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.bookingDate)]))
          .watch();

  Future<void> saveVehicleCostWithLedger(
    VehicleCostsCompanion cost,
    LedgerEntriesCompanion ledger,
  ) async {
    final preference = await preferencesFor(cost.userId.value);
    final accountId =
        ledger.accountId.present && ledger.accountId.value.isNotEmpty
        ? ledger.accountId.value
        : preference.selectedHouseholdAccountId;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(cost.userId.value, accountId, 'household')) {
      throw StateError(
        'Vor dem Erfassen von Fahrzeugkosten muss ein Haushaltskonto gewählt werden.',
      );
    }
    // When an existing cost is edited, its booking is updated in place so
    // the old amount is taken back from the account first.
    final existingLedger = await vehicleCostLedgerEntry(
      cost.userId.value,
      cost.id.value,
    );
    await into(vehicleCosts).insertOnConflictUpdate(cost);
    await saveLedgerEntry(
      ledger.copyWith(
        id: existingLedger == null ? null : Value(existingLedger.id),
        createdAt: existingLedger == null
            ? null
            : Value(existingLedger.createdAt),
        accountId: Value(accountId),
      ),
    );
  }

  Future<LedgerEntry?> vehicleCostLedgerEntry(String userId, String costId) =>
      (select(ledgerEntries)
            ..limit(1)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.sourceType.equals('vehicle') &
                  row.sourceId.equals(costId) &
                  row.deletedAt.isNull(),
            ))
          .getSingleOrNull();

  /// Deletes a vehicle cost together with its household booking and gives
  /// the amount back to the account.
  Future<void> deleteVehicleCost(String costId, String userId) async {
    if (costId.startsWith('ledger:')) {
      // Created in the household book: the booking owns the cost.
      final entryId = costId.substring('ledger:'.length);
      await deleteLedgerEntry(entryId, userId);
      final now = DateTime.now().toUtc();
      await (update(vehicleCosts)
            ..where((row) => row.id.equals(costId) & row.userId.equals(userId)))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      _schedulePersist(userId);
      return;
    }
    final entry = await vehicleCostLedgerEntry(userId, costId);
    if (entry != null) {
      await deleteLedgerEntry(entry.id, userId);
    } else {
      final now = DateTime.now().toUtc();
      await (update(vehicleCosts)
            ..where((row) => row.id.equals(costId) & row.userId.equals(userId)))
          .write(
            VehicleCostsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    }
    _schedulePersist(userId);
  }
}
