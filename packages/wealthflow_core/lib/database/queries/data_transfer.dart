part of '../app_database.dart';

/// Export, Import und verschlüsselte Datendatei.
extension DataTransferQueries on AppDatabase {
  Future<Map<String, Object?>> exportUserData(String userId) async {
    final user = await userById(userId);
    final accountRows = await (select(
      accounts,
    )..where((r) => r.userId.equals(userId))).get();
    final accountHistoryRows = await (select(
      accountBalanceHistories,
    )..where((r) => r.userId.equals(userId))).get();
    final investmentRows = await (select(
      investments,
    )..where((r) => r.userId.equals(userId))).get();
    final physicalAssetRows = await (select(
      physicalAssets,
    )..where((r) => r.userId.equals(userId))).get();
    final purchaseRows = await (select(
      investmentPurchases,
    )..where((r) => r.userId.equals(userId))).get();
    final saleRows = await (select(
      portfolioSales,
    )..where((r) => r.userId.equals(userId))).get();
    final auditRows = await (select(
      portfolioAuditLogs,
    )..where((r) => r.userId.equals(userId))).get();
    final dividendRows = await (select(
      dividendSchedules,
    )..where((r) => r.userId.equals(userId))).get();
    final ledgerRows = await (select(
      ledgerEntries,
    )..where((r) => r.userId.equals(userId))).get();
    final vehicleRows = await (select(
      vehicles,
    )..where((r) => r.userId.equals(userId))).get();
    final costRows = await (select(
      vehicleCosts,
    )..where((r) => r.userId.equals(userId))).get();
    final masterRows = await (select(
      masterData,
    )..where((r) => r.userId.equals(userId))).get();
    final reminderRows = await (select(
      reminders,
    )..where((r) => r.userId.equals(userId))).get();
    final snapshotRows = await (select(
      netWorthSnapshots,
    )..where((r) => r.userId.equals(userId))).get();
    final preferences = await (select(
      userPreferences,
    )..where((r) => r.userId.equals(userId))).getSingleOrNull();
    final stockIds = investmentRows
        .map((row) => row.stockId)
        .whereType<String>()
        .toSet();
    final stockRows = stockIds.isEmpty
        ? const <StockMaster>[]
        : await (select(stockMasters)..where((r) => r.id.isIn(stockIds))).get();
    return {
      'format': 'WealthFlow readonly export',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'user': user == null
          ? null
          : {
              'id': user.id,
              'email': user.email,
              'displayName': user.displayName,
            },
      'accounts': accountRows.map((e) => e.toJson()).toList(),
      'accountBalanceHistories': accountHistoryRows
          .map((e) => e.toJson())
          .toList(),
      'investments': investmentRows.map((e) => e.toJson()).toList(),
      'physicalAssets': physicalAssetRows.map((e) => e.toJson()).toList(),
      'investmentPurchases': purchaseRows.map((e) => e.toJson()).toList(),
      'portfolioSales': saleRows.map((e) => e.toJson()).toList(),
      'portfolioAuditLogs': auditRows.map((e) => e.toJson()).toList(),
      'dividendSchedules': dividendRows.map((e) => e.toJson()).toList(),
      'ledgerEntries': ledgerRows.map((e) => e.toJson()).toList(),
      'vehicles': vehicleRows.map((e) => e.toJson()).toList(),
      'vehicleCosts': costRows.map((e) => e.toJson()).toList(),
      'masterData': masterRows.map((e) => e.toJson()).toList(),
      'reminders': reminderRows.map((e) => e.toJson()).toList(),
      'netWorthSnapshots': snapshotRows.map((e) => e.toJson()).toList(),
      // Catalogue entries the positions refer to, so a restore on a fresh
      // device does not leave investments pointing at missing master data.
      'stockMasters': stockRows.map((e) => e.toJson()).toList(),
      'preferences': preferences?.toJson(),
    };
  }

  /// Merges an exported data file into the account of [userId].
  ///
  /// Rows are always assigned to [userId], so a backup made under another
  /// account (for example before a reinstall) can be restored. Afterwards the
  /// account balances are corrected by every booking, sale and purchase whose
  /// cash effect differs from the version the kept balance was based on.
  Future<void> mergeUserData(String userId, Map<String, dynamic> data) async {
    List<Map<String, dynamic>> rows(String key) =>
        (data[key] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((row) => {...Map<String, dynamic>.from(row), 'userId': userId})
            .toList();

    final stockIdReplacements = <String, String>{};
    for (final json in data['stockMasters'] as List<dynamic>? ?? const []) {
      if (json is! Map) continue;
      final remote = StockMaster.fromJson(Map<String, dynamic>.from(json));
      final existing = await (select(
        stockMasters,
      )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
      if (existing != null) continue;
      final match = await _matchingStockMaster(remote.toCompanion(false));
      if (match != null) {
        stockIdReplacements[remote.id] = match.id;
      } else {
        await into(
          stockMasters,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
    }

    final localAccounts = {
      for (final row in await (select(
        accounts,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localEntries = {
      for (final row in await (select(
        ledgerEntries,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localSales = {
      for (final row in await (select(
        portfolioSales,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final localPurchases = {
      for (final row in await (select(
        investmentPurchases,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final remoteEntries = {
      for (final json in rows('ledgerEntries'))
        json['id'] as String: LedgerEntry.fromJson(json),
    };
    final remoteSales = <String, PortfolioSale>{};
    final remotePurchases = <String, InvestmentPurchase>{};
    final balanceFromFile = <String>{};

    await transaction(() async {
      for (final json in rows('accounts')) {
        final remote = Account.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          accounts,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          balanceFromFile.add(remote.id);
          await into(
            accounts,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('accountBalanceHistories')) {
        final remote = AccountBalanceHistory.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          accountBalanceHistories,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        // History rows carry no change time; a deletion on either side wins
        // so an older copy cannot bring a deleted entry back.
        if (local?.deletedAt != null && remote.deletedAt == null) continue;
        await into(
          accountBalanceHistories,
        ).insertOnConflictUpdate(remote.toCompanion(false));
      }
      for (final json in rows('investments')) {
        final stockId = json['stockId'];
        final remote = Investment.fromJson({
          ...json,
          'stockId': stockIdReplacements[stockId] ?? stockId,
        });
        if (remote.userId != userId) continue;
        final local = await (select(
          investments,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            investments,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('physicalAssets')) {
        final remote = PhysicalAsset.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          physicalAssets,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            physicalAssets,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('investmentPurchases')) {
        final remote = InvestmentPurchase.fromJson({
          'cashApplied': false,
          'exchangeRate': 1.0,
          ...json,
        });
        if (remote.userId != userId) continue;
        remotePurchases[remote.id] = remote;
        final local = await (select(
          investmentPurchases,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        // Without a change time (older files) the incoming row wins, as
        // before; otherwise the newer change is kept.
        final remoteChanged = remote.updatedAt;
        final localChanged = local?.updatedAt;
        if (local == null ||
            remoteChanged == null ||
            localChanged == null ||
            remoteChanged.isAfter(localChanged)) {
          await into(
            investmentPurchases,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('portfolioSales')) {
        final remote = PortfolioSale.fromJson({
          'accountCredited': true,
          'sourceCurrency': 'EUR',
          'exchangeRate': 1,
          ...json,
        });
        if (remote.userId != userId) continue;
        remoteSales[remote.id] = remote;
        await into(
          portfolioSales,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      for (final json in rows('portfolioAuditLogs')) {
        final remote = PortfolioAuditLog.fromJson(json);
        if (remote.userId != userId) continue;
        await into(
          portfolioAuditLogs,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      for (final json in rows('dividendSchedules')) {
        final remote = DividendSchedule.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          dividendSchedules,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            dividendSchedules,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('ledgerEntries')) {
        final remote = LedgerEntry.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          ledgerEntries,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            ledgerEntries,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('masterData')) {
        final remote = MasterDataData.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          masterData,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        final remoteChanged = remote.updatedAt ?? remote.createdAt;
        if (local == null) {
          // Every device seeds the same default values under its own ids.
          // Values are referenced by text, so the existing row with the same
          // kind and value takes over the newer deletion state instead of a
          // second row that would break the unique key.
          final twin =
              await (select(masterData)..where(
                    (row) =>
                        row.userId.equals(userId) &
                        row.kind.equals(remote.kind) &
                        row.value.equals(remote.value),
                  ))
                  .getSingleOrNull();
          if (twin == null) {
            await into(masterData).insert(remote.toCompanion(false));
          } else if (remoteChanged.isAfter(twin.updatedAt ?? twin.createdAt)) {
            await (update(
              masterData,
            )..where((row) => row.id.equals(twin.id))).write(
              MasterDataCompanion(
                deletedAt: Value(remote.deletedAt),
                updatedAt: Value(remoteChanged),
              ),
            );
          }
          continue;
        }
        final localChanged = local.updatedAt ?? local.createdAt;
        if (remoteChanged.isAfter(localChanged)) {
          await into(
            masterData,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('reminders')) {
        final remote = AppReminder.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          reminders,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            reminders,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('vehicles')) {
        final remote = Vehicle.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          vehicles,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            vehicles,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('vehicleCosts')) {
        final remote = VehicleCost.fromJson(json);
        if (remote.userId != userId) continue;
        final local = await (select(
          vehicleCosts,
        )..where((row) => row.id.equals(remote.id))).getSingleOrNull();
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await into(
            vehicleCosts,
          ).insertOnConflictUpdate(remote.toCompanion(false));
        }
      }
      for (final json in rows('netWorthSnapshots')) {
        final remote = NetWorthSnapshot.fromJson({
          ...json,
          'vehicleValue': json['vehicleValue'] ?? 0,
        });
        if (remote.userId != userId) continue;
        await into(
          netWorthSnapshots,
        ).insert(remote.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }
      await _correctBalancesAfterMerge(
        userId: userId,
        balanceFromFile: balanceFromFile,
        localAccounts: localAccounts,
        localEntries: localEntries,
        remoteEntries: remoteEntries,
        localSales: localSales,
        remoteSales: remoteSales,
        localPurchases: localPurchases,
        remotePurchases: remotePurchases,
      );
    });
    await _applyDueLedgerEntries(userId);
    await captureNetWorth(userId);
  }

  /// Each kept balance already contains the cash effects of the side it came
  /// from (this device or the file). The difference to the merged rows is
  /// booked on top, so no booking is lost or counted twice.
  Future<void> _correctBalancesAfterMerge({
    required String userId,
    required Set<String> balanceFromFile,
    required Map<String, Account> localAccounts,
    required Map<String, LedgerEntry> localEntries,
    required Map<String, LedgerEntry> remoteEntries,
    required Map<String, PortfolioSale> localSales,
    required Map<String, PortfolioSale> remoteSales,
    required Map<String, InvestmentPurchase> localPurchases,
    required Map<String, InvestmentPurchase> remotePurchases,
  }) async {
    final mergedAccounts = await (select(
      accounts,
    )..where((r) => r.userId.equals(userId))).get();
    final mergedEntries = {
      for (final row in await (select(
        ledgerEntries,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final mergedSales = {
      for (final row in await (select(
        portfolioSales,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final mergedPurchases = {
      for (final row in await (select(
        investmentPurchases,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row,
    };
    final investmentAccounts = {
      for (final row in await (select(
        investments,
      )..where((r) => r.userId.equals(userId))).get())
        row.id: row.accountId,
    };

    double ledgerEffect(LedgerEntry? entry, String accountId) =>
        entry == null ||
            entry.accountId != accountId ||
            !entry.accountApplied ||
            entry.deletedAt != null
        ? 0
        : entry.isIncome
        ? entry.amount
        : -entry.amount;
    double saleEffect(PortfolioSale? sale, String accountId) {
      if (sale == null) return 0;
      final credited =
          sale.destinationAccountId ??
          (sale.accountCredited ? sale.accountId : null);
      return credited == accountId ? sale.proceeds : 0;
    }

    double purchaseEffect(InvestmentPurchase? purchase, String accountId) =>
        purchase == null ||
            !purchase.cashApplied ||
            purchase.deletedAt != null ||
            investmentAccounts[purchase.investmentId] != accountId
        ? 0
        : -purchase.cashAmount;

    for (final account in mergedAccounts) {
      final fromFile = balanceFromFile.contains(account.id);
      // A balance that existed on neither side has nothing to correct.
      if (!fromFile && !localAccounts.containsKey(account.id)) continue;
      final keptEntries = fromFile ? remoteEntries : localEntries;
      final keptSales = fromFile ? remoteSales : localSales;
      final keptPurchases = fromFile ? remotePurchases : localPurchases;
      var ledgerDelta = 0.0;
      for (final id in {...mergedEntries.keys, ...keptEntries.keys}) {
        ledgerDelta +=
            ledgerEffect(mergedEntries[id], account.id) -
            ledgerEffect(keptEntries[id], account.id);
      }
      var cashDelta = 0.0;
      for (final id in {...mergedSales.keys, ...keptSales.keys}) {
        cashDelta +=
            saleEffect(mergedSales[id], account.id) -
            saleEffect(keptSales[id], account.id);
      }
      for (final id in {...mergedPurchases.keys, ...keptPurchases.keys}) {
        cashDelta +=
            purchaseEffect(mergedPurchases[id], account.id) -
            purchaseEffect(keptPurchases[id], account.id);
      }
      if (ledgerDelta.abs() < 0.000001 && cashDelta.abs() < 0.000001) {
        continue;
      }
      await (update(accounts)..where((row) => row.id.equals(account.id))).write(
        AccountsCompanion(
          balance: Value(account.balance + ledgerDelta + cashDelta),
          availableBalance: Value(
            account.availableBalance + ledgerDelta + cashDelta,
          ),
        ),
      );
    }
  }

  Future<bool> persistUserFile(String userId) async {
    final preference = await (select(
      userPreferences,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    final path = preference?.dataFilePath ?? '';
    final key = _dataFileKeys[userId];
    if (path.isEmpty || key == null) return false;
    try {
      final data = await exportUserData(userId);
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final encrypted = await DataCipher.encrypt(
        json,
        key,
        backupKey: _backupKeys[userId],
      );
      final writer = writeDataFile;
      final written = writer != null && await writer(encrypted, path);
      _setBackupStatus(
        userId,
        written
            ? BackupStatus.success(DateTime.now())
            : BackupStatus.failure('Der Speicherort ist nicht beschreibbar.'),
      );
      return written;
    } catch (error, stackTrace) {
      // Local database writes must never fail just because an external backup
      // location is temporarily unavailable, but the user has to learn that
      // the data file is no longer up to date.
      _setBackupStatus(
        userId,
        const BackupStatus.failure(
          'Die Datendatei konnte nicht geschrieben werden.',
        ),
      );
      await logError(
        userId: userId,
        source: 'Datendatei',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _setBackupStatus(String userId, BackupStatus status) {
    _backupStatus[userId] = status;
    _backupStatusChanges.add(userId);
  }

  Future<void> seedDefaultMasterData(String userId) async {
    const defaults = <String, List<String>>{
      'category': [
        'Einkaufen',
        'Wohnen',
        'Auto',
        'Motorrad',
        'Tanken',
        'Laden',
        'Streaming',
        'Versicherungen',
        'Freizeit',
        'Urlaub',
        'Gesundheit',
        'Gehalt',
        'Dividende',
        'Sonstiges',
      ],
      'paymentMethod': ['Lastschrift', 'Überweisung', 'Karte', 'Bar'],
      'country': [
        'Deutschland',
        'Österreich',
        'Schweiz',
        'Frankreich',
        'Niederlande',
        'Vereinigtes Königreich',
        'USA',
        'Kanada',
        'Japan',
        'China',
        'Australien',
      ],
      'sector': [
        'Technologie',
        'Finanzen',
        'Gesundheit',
        'Industrie',
        'Basiskonsumgüter',
        'Nicht-Basiskonsumgüter',
        'Energie',
        'Versorger',
        'Immobilien',
        'Kommunikation',
      ],
    };
    final now = DateTime.now().toUtc();
    await batch((batch) {
      for (final kind in defaults.entries) {
        for (final value in kind.value) {
          batch.insert(
            masterData,
            MasterDataCompanion.insert(
              id: AppDatabase._uuid.v5(
                Namespace.url.value,
                '$userId:${kind.key}:$value',
              ),
              userId: userId,
              kind: kind.key,
              value: value,
              createdAt: now,
              updatedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }
}
