part of '../app_database.dart';

/// Depot: Positionen, Käufe, Verkäufe, Sachwerte, Dividenden und Vermögensverlauf.
extension PortfolioQueries on AppDatabase {
  Stream<List<Investment>> watchInvestments(String userId) =>
      (select(investments)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNull() &
                  row.accountId.isNotInQuery(
                    selectOnly(accounts)
                      ..addColumns([accounts.id])
                      ..where(accounts.deletedAt.isNotNull()),
                  ),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Stream<List<Investment>> watchAllInvestments(String userId) =>
      (select(investments)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Stream<List<Investment>> watchDeletedInvestments(String userId) =>
      (select(investments)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.quantity.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .watch();

  Future<List<Investment>> deletedInvestmentsFor(String userId) =>
      (select(investments)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.quantity.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .get();

  Stream<List<InvestmentPurchase>> watchInvestmentPurchases(String userId) =>
      (select(investmentPurchases)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.purchaseDate)]))
          .watch();

  Stream<List<PortfolioSale>> watchPortfolioSales(String userId) =>
      (select(portfolioSales)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.desc(row.soldAt)]))
          .watch();

  Stream<List<PortfolioAuditLog>> watchPortfolioAuditLogs(String userId) =>
      (select(portfolioAuditLogs)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.desc(row.occurredAt)]))
          .watch();

  Future<void> saveInvestmentPurchase(
    InvestmentPurchasesCompanion value,
  ) async {
    final stamped = value.copyWith(updatedAt: Value(DateTime.now().toUtc()));
    await into(investmentPurchases).insertOnConflictUpdate(stamped);
    _schedulePersist(value.userId.value);
  }

  Future<CurrencyConverter> _converterFor(String userId) async =>
      CurrencyConverter.fromRates(
        (await preferencesFor(userId)).currency,
        await select(countryTaxRates).get(),
      );

  Future<Account> _liveAccount(String accountId, String userId) async {
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) {
      throw StateError('Das Konto der Position ist nicht mehr vorhanden.');
    }
    return account;
  }

  /// Units of [account]'s currency for one unit of [investment]'s currency.
  Future<double> _instrumentToAccountRate(
    String userId,
    Investment investment,
    Account account,
  ) async {
    final converter = await _converterFor(userId);
    final instrument = investment.instrumentCurrency.isEmpty
        ? converter.baseCurrency
        : investment.instrumentCurrency;
    return converter.convert(1, instrument, account.currency);
  }

  /// Records a purchase of an existing position. With [buy] the price plus
  /// fees is converted into the account currency and taken from the
  /// position's account; the rate is kept so a later correction or deletion
  /// gives back exactly what was taken.
  Future<void> recordInvestmentPurchase({
    required String userId,
    required String investmentId,
    required DateTime purchaseDate,
    required double purchasePrice,
    required double quantity,
    required double fees,
    required bool buy,
    String? id,
  }) async {
    if (purchasePrice < 0 || quantity <= 0 || fees < 0) {
      throw ArgumentError('Kaufkurs, Stückzahl und Gebühren sind ungültig.');
    }
    final investment =
        await (select(investments)..where(
              (row) => row.id.equals(investmentId) & row.userId.equals(userId),
            ))
            .getSingleOrNull();
    if (investment == null) throw StateError('Die Position fehlt.');
    final account = await _liveAccount(investment.accountId, userId);
    final rate = await _instrumentToAccountRate(userId, investment, account);
    final now = DateTime.now().toUtc();
    final purchase = InvestmentPurchase(
      id: id ?? AppDatabase._uuid.v4(),
      userId: userId,
      investmentId: investmentId,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      quantity: quantity,
      fees: fees,
      cashApplied: buy,
      exchangeRate: rate,
      createdAt: now,
      updatedAt: now,
    );
    await transaction(() async {
      await into(investmentPurchases).insert(purchase);
      if (buy) {
        await _changePortfolioCash(
          userId: userId,
          accountId: account.id,
          delta: -purchase.cashAmount,
        );
        await _writePortfolioAudit(
          userId: userId,
          action: 'purchase_cash',
          entityType: 'account',
          entityId: account.id,
          entityName: account.label,
          details:
              '${purchaseDate.toIso8601String()} · ${purchase.cashAmount.toStringAsFixed(2)} ${account.currency}',
        );
      }
      await _recalculateInvestmentFromPurchases(investmentId, userId);
    });
    await captureNetWorth(userId);
  }

  Future<void> updateInvestmentPurchase({
    required String userId,
    required String purchaseId,
    required DateTime purchaseDate,
    required double purchasePrice,
    required double quantity,
    required double fees,
    double? exchangeRate,
  }) async {
    if (purchasePrice < 0 ||
        quantity <= 0 ||
        fees < 0 ||
        (exchangeRate != null && exchangeRate <= 0)) {
      throw ArgumentError(
        'Kaufkurs, Stückzahl, Gebühren oder Wechselkurs sind ungültig.',
      );
    }
    final purchase =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.id.equals(purchaseId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (purchase == null) throw StateError('Der Kauf wurde nicht gefunden.');
    final changed = purchase.copyWith(
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      quantity: quantity,
      fees: fees,
      exchangeRate: exchangeRate ?? purchase.exchangeRate,
    );
    final investment = await (select(
      investments,
    )..where((row) => row.id.equals(purchase.investmentId))).getSingleOrNull();
    await transaction(() async {
      await (update(
        investmentPurchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        InvestmentPurchasesCompanion(
          purchaseDate: Value(purchaseDate),
          purchasePrice: Value(purchasePrice),
          quantity: Value(quantity),
          fees: Value(fees),
          exchangeRate: Value(changed.exchangeRate),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      final delta = purchase.cashAmount - changed.cashAmount;
      if (purchase.cashApplied && investment != null && delta.abs() > 1e-9) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: delta,
        );
      }
      await _recalculateInvestmentFromPurchases(purchase.investmentId, userId);
    });
    await captureNetWorth(userId);
  }

  Future<void> deleteInvestmentPurchase(
    String purchaseId,
    String userId,
  ) async {
    final purchase =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.id.equals(purchaseId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (purchase == null) return;
    final investment =
        await (select(investments)..where(
              (row) =>
                  row.id.equals(purchase.investmentId) &
                  row.userId.equals(userId),
            ))
            .getSingleOrNull();
    await transaction(() async {
      await (update(
        investmentPurchases,
      )..where((row) => row.id.equals(purchaseId))).write(
        InvestmentPurchasesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      if (purchase.cashApplied && investment != null) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: purchase.cashAmount,
        );
      }
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'purchase',
        entityId: purchaseId,
        entityName: investment?.name ?? 'Kauf',
        details:
            '${purchase.quantity} Stück zu ${purchase.purchasePrice.toStringAsFixed(2)}'
            '${purchase.cashApplied ? ' · ${purchase.cashAmount.toStringAsFixed(2)} zurückgebucht' : ''}',
      );
      await _recalculateInvestmentFromPurchases(purchase.investmentId, userId);
    });
    await captureNetWorth(userId);
  }

  Future<void> _recalculateInvestmentFromPurchases(
    String investmentId,
    String userId,
  ) async {
    final rows =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final purchasedQuantity = rows.fold<double>(
      0,
      (sum, row) => sum + row.quantity,
    );
    final soldRows =
        await (select(portfolioSales)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId),
            ))
            .get();
    final soldQuantity = soldRows.fold<double>(
      0,
      (sum, row) => sum + row.quantity,
    );
    if (soldQuantity > purchasedQuantity + 1e-9) {
      throw StateError(
        'Der Kauf kann nicht geändert werden, weil bereits mehr Stück verkauft wurden.',
      );
    }
    final quantity = AppDatabase._roundQuantity(
      purchasedQuantity - soldQuantity,
    );
    // What is still held comes from the newest purchases (FIFO), so the
    // purchase price and fees describe exactly those pieces.
    final lots = AppDatabase.remainingLots(rows, soldQuantity);
    final remainingValue = lots.fold<double>(
      0,
      (sum, lot) => sum + lot.quantity * lot.purchase.purchasePrice,
    );
    final remainingFees = lots.fold<double>(
      0,
      (sum, lot) =>
          sum +
          (lot.purchase.quantity == 0
              ? 0
              : lot.purchase.fees * lot.quantity / lot.purchase.quantity),
    );
    final earliest = rows.isEmpty
        ? null
        : rows.reduce(
            (a, b) => a.purchaseDate.isBefore(b.purchaseDate) ? a : b,
          );
    final allValue = rows.fold<double>(
      0,
      (sum, row) => sum + row.quantity * row.purchasePrice,
    );
    await (update(investments)..where(
          (row) => row.id.equals(investmentId) & row.userId.equals(userId),
        ))
        .write(
          InvestmentsCompanion(
            quantity: Value(quantity),
            purchasePrice: Value(
              quantity > 0
                  ? remainingValue / quantity
                  : (purchasedQuantity == 0 ? 0 : allValue / purchasedQuantity),
            ),
            fees: Value(remainingFees),
            purchaseDate: Value(earliest?.purchaseDate ?? DateTime.now()),
            deletedAt: Value(quantity == 0 ? DateTime.now().toUtc() : null),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<double> _dividendAllowanceUsedThrough({
    required String userId,
    required DateTime through,
    required double allowance,
    required double salesAllowanceUsed,
  }) async {
    final holdings = await (select(
      investments,
    )..where((row) => row.userId.equals(userId))).get();
    final purchases =
        await (select(investmentPurchases)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final sales =
        await (select(portfolioSales)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.soldAt.isSmallerOrEqualValue(through),
            ))
            .get();
    final schedules =
        await (select(dividendSchedules)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final events =
        <
          ({Investment investment, DividendSchedule? schedule, DateTime date})
        >[];
    for (final holding in holdings) {
      final exactMonths = <int>{};
      for (final schedule in schedules.where(
        (row) =>
            row.investmentId == holding.id &&
            (row.paymentYear == through.year ||
                (row.paymentYear == 0 && through.year == DateTime.now().year)),
      )) {
        final date =
            schedule.paymentDate ??
            DateTime(through.year, schedule.paymentMonth);
        if (!date.isAfter(through)) {
          exactMonths.add(schedule.paymentMonth);
          events.add((investment: holding, schedule: schedule, date: date));
        }
      }
      for (final month in dividendPaymentMonths(
        holding.dividendFrequency,
        holding.dividendStartMonth,
      )) {
        final date = DateTime(through.year, month);
        if (!exactMonths.contains(month) &&
            holding.annualDividend > 0 &&
            !date.isAfter(through)) {
          events.add((investment: holding, schedule: null, date: date));
        }
      }
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    var remaining = (allowance - salesAllowanceUsed)
        .clamp(0, double.infinity)
        .toDouble();
    var used = 0.0;
    for (final event in events) {
      final holdingPurchases = purchases
          .where((row) => row.investmentId == event.investment.id)
          .toList();
      final holdingSales = sales
          .where((row) => row.investmentId == event.investment.id)
          .toList();
      final purchased = holdingPurchases.isEmpty
          ? (event.date.isBefore(event.investment.purchaseDate)
                ? 0.0
                : event.investment.quantity +
                      holdingSales.fold<double>(
                        0,
                        (sum, sale) => sum + sale.quantity,
                      ))
          : holdingPurchases
                .where((row) => !row.purchaseDate.isAfter(event.date))
                .fold<double>(0, (sum, row) => sum + row.quantity);
      final sold = holdingSales
          .where((row) => !row.soldAt.isAfter(event.date))
          .fold<double>(0, (sum, row) => sum + row.quantity);
      final quantity = (purchased - sold).clamp(0, double.infinity);
      if (quantity <= 0) continue;
      final schedule = event.schedule;
      final tax = calculateGermanDividendTax(
        grossAmount:
            (schedule?.amountPerShare ?? event.investment.annualDividend) *
            quantity,
        exchangeRate:
            schedule?.exchangeRate ?? event.investment.dividendExchangeRate,
        withholdingTaxRate:
            schedule?.withholdingTaxRate ??
            event.investment.dividendWithholdingTaxRate,
        allowanceRemaining: remaining,
      );
      used += tax.allowanceUsed;
      remaining = tax.allowanceRemaining;
    }
    return used;
  }

  Future<void> sellInvestment({
    required String userId,
    required String investmentId,
    required double quantity,
    required double pricePerUnit,
    required double fees,
    required DateTime soldAt,
  }) async {
    if (quantity <= 0 || pricePerUnit < 0 || fees < 0) {
      throw ArgumentError('Verkaufsdaten sind ungültig.');
    }
    final investment =
        await (select(investments)..where(
              (row) =>
                  row.id.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (investment == null || quantity > investment.quantity + 1e-9) {
      throw StateError('Die Verkaufsmenge übersteigt den Bestand.');
    }
    final cashAccount = await _liveAccount(investment.accountId, userId);
    // Price and fees are entered in the instrument currency; the proceeds
    // are booked to the account in its own currency.
    final saleRate = await _instrumentToAccountRate(
      userId,
      investment,
      cashAccount,
    );
    final preference = await preferencesFor(userId);
    final yearStart = DateTime(soldAt.year);
    final yearEnd = DateTime(soldAt.year + 1);
    final priorSales =
        await (select(portfolioSales)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.soldAt.isBiggerOrEqualValue(yearStart) &
                  row.soldAt.isSmallerThanValue(yearEnd),
            ))
            .get();
    final dividendAllowanceUsed = await _dividendAllowanceUsedThrough(
      userId: userId,
      through: soldAt,
      allowance: preference.taxAllowance,
      salesAllowanceUsed: priorSales.fold<double>(
        0,
        (sum, row) => sum + row.allowanceUsed,
      ),
    );
    final alreadyUsed =
        priorSales.fold<double>(0, (sum, row) => sum + row.allowanceUsed) +
        dividendAllowanceUsed;
    final grossProceeds = quantity * pricePerUnit * saleRate;
    final proceedsBeforeTax = (grossProceeds - fees * saleRate).clamp(
      0,
      double.infinity,
    );
    final costBasis = await _fifoCostBasis(
      userId: userId,
      investment: investment,
      quantity: quantity,
      fallbackRate: saleRate,
    );
    final realizedGain = proceedsBeforeTax - costBasis;
    final allowanceAvailable = (preference.taxAllowance - alreadyUsed)
        .clamp(0, double.infinity)
        .toDouble();
    final soldInvestments = {
      for (final row in await (select(
        investments,
      )..where((row) => row.userId.equals(userId))).get())
        row.id: row,
    };
    final earlierSales =
        priorSales
            .where(
              (row) =>
                  row.assetKind == 'security' && !row.soldAt.isAfter(soldAt),
            )
            .toList()
          ..sort((a, b) => a.soldAt.compareTo(b.soldAt));
    final tax = saleTax(
      assetType: investment.assetType,
      name: investment.name,
      realizedGain: realizedGain,
      allowanceAvailable: allowanceAvailable,
      priorSales: [
        for (final sale in earlierSales)
          PriorSale(
            assetType: soldInvestments[sale.investmentId]?.assetType ?? '',
            name: soldInvestments[sale.investmentId]?.name ?? sale.assetName,
            realizedGain: sale.realizedGain,
          ),
      ],
    );
    final allowanceUsed = tax.allowanceUsed;
    final taxPaid = tax.taxPaid;
    final proceeds = ((proceedsBeforeTax - taxPaid) * 100).round() / 100;
    final consistent = await _purchasesMatchHolding(investment, userId);
    await transaction(() async {
      await into(portfolioSales).insert(
        PortfolioSalesCompanion.insert(
          id: AppDatabase._uuid.v4(),
          userId: userId,
          accountId: investment.accountId,
          investmentId: Value(investment.id),
          assetName: investment.name,
          assetKind: 'security',
          sourceCurrency: Value(
            investment.instrumentCurrency.isEmpty
                ? cashAccount.currency
                : investment.instrumentCurrency,
          ),
          exchangeRate: Value(saleRate),
          quantity: quantity,
          unit: 'Stück',
          pricePerUnit: pricePerUnit,
          fees: Value(fees),
          proceeds: proceeds,
          costBasis: Value(costBasis),
          realizedGain: Value(realizedGain),
          allowanceUsed: Value(allowanceUsed),
          taxPaid: Value(taxPaid),
          soldAt: soldAt,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      if (consistent) {
        await _recalculateInvestmentFromPurchases(investment.id, userId);
      } else {
        final remainingQuantity = AppDatabase._roundQuantity(
          investment.quantity - quantity,
        );
        await (update(
          investments,
        )..where((row) => row.id.equals(investment.id))).write(
          InvestmentsCompanion(
            quantity: Value(remainingQuantity),
            fees: Value(
              investment.quantity == 0
                  ? 0
                  : investment.fees * remainingQuantity / investment.quantity,
            ),
            deletedAt: Value(
              remainingQuantity <= 0 ? DateTime.now().toUtc() : null,
            ),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
      await _changePortfolioCash(
        userId: userId,
        accountId: cashAccount.id,
        delta: proceeds,
      );
    });
    await captureNetWorth(userId);
  }

  /// Whether the recorded purchases minus the sales give the held quantity;
  /// older positions edited by hand may not, then the average price is used.
  Future<bool> _purchasesMatchHolding(
    Investment investment,
    String userId,
  ) async {
    final purchases =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    if (purchases.isEmpty) return false;
    final sales =
        await (select(portfolioSales)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.userId.equals(userId),
            ))
            .get();
    final held =
        purchases.fold<double>(0, (sum, row) => sum + row.quantity) -
        sales.fold<double>(0, (sum, row) => sum + row.quantity);
    return (held - investment.quantity).abs() < 1e-6;
  }

  /// Cost of [quantity] pieces in the account currency, taken from the
  /// oldest purchases still held (first in, first out), each at the rate of
  /// its own purchase.
  Future<double> _fifoCostBasis({
    required String userId,
    required Investment investment,
    required double quantity,
    required double fallbackRate,
  }) async {
    if (!await _purchasesMatchHolding(investment, userId)) {
      return (quantity * investment.purchasePrice +
              (investment.quantity == 0
                  ? 0
                  : investment.fees * quantity / investment.quantity)) *
          fallbackRate;
    }
    final purchases =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final sold =
        (await (select(portfolioSales)..where(
                  (row) =>
                      row.investmentId.equals(investment.id) &
                      row.userId.equals(userId),
                ))
                .get())
            .fold<double>(0, (sum, row) => sum + row.quantity);
    var left = quantity;
    var cost = 0.0;
    for (final lot in AppDatabase.remainingLots(purchases, sold)) {
      if (left <= 1e-12) break;
      final taken = lot.quantity < left ? lot.quantity : left;
      final purchase = lot.purchase;
      final feeShare = purchase.quantity == 0
          ? 0.0
          : purchase.fees * taken / purchase.quantity;
      cost +=
          (taken * purchase.purchasePrice + feeShare) * purchase.exchangeRate;
      left -= taken;
    }
    return cost;
  }

  Future<void> sellPhysicalAsset({
    required String userId,
    required String assetId,
    required double grams,
    required double pricePerGram,
    required double fees,
    required DateTime soldAt,
    String? destinationAccountId,
  }) async {
    if (grams <= 0 || pricePerGram < 0 || fees < 0) {
      throw ArgumentError('Verkaufsdaten sind ungültig.');
    }
    final asset =
        await (select(physicalAssets)..where(
              (row) =>
                  row.id.equals(assetId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (asset == null || grams > asset.weightGrams) {
      throw StateError('Die Verkaufsmenge übersteigt den Bestand.');
    }
    final proceedsBeforeTax = (grams * pricePerGram - fees).clamp(
      0,
      double.infinity,
    );
    final costBasis = asset.weightGrams == 0
        ? 0.0
        : asset.purchasePrice * grams / asset.weightGrams;
    final realizedGain = proceedsBeforeTax - costBasis;
    final preference = await preferencesFor(userId);
    var allowanceUsed = 0.0;
    var taxPaid = 0.0;
    if (preference.includePhysicalAssetsInTaxAllowance && realizedGain > 0) {
      final yearStart = DateTime(soldAt.year);
      final yearEnd = DateTime(soldAt.year + 1);
      final priorSales =
          await (select(portfolioSales)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.soldAt.isBiggerOrEqualValue(yearStart) &
                    row.soldAt.isSmallerThanValue(yearEnd),
              ))
              .get();
      final dividendAllowanceUsed = await _dividendAllowanceUsedThrough(
        userId: userId,
        through: soldAt,
        allowance: preference.taxAllowance,
        salesAllowanceUsed: priorSales.fold<double>(
          0,
          (sum, row) => sum + row.allowanceUsed,
        ),
      );
      final alreadyUsed =
          priorSales.fold<double>(0, (sum, row) => sum + row.allowanceUsed) +
          dividendAllowanceUsed;
      final available = (preference.taxAllowance - alreadyUsed).clamp(
        0,
        double.infinity,
      );
      allowanceUsed = realizedGain.clamp(0, available).toDouble();
      final taxable = (realizedGain - allowanceUsed).clamp(0, double.infinity);
      final capitalTax = taxable * .25;
      taxPaid = ((capitalTax + capitalTax * .055) * 100).round() / 100;
    }
    final proceeds = ((proceedsBeforeTax - taxPaid) * 100).round() / 100;
    final remainingGrams =
        ((asset.weightGrams - grams) * 1000000).round() / 1000000;
    await transaction(() async {
      await into(portfolioSales).insert(
        PortfolioSalesCompanion.insert(
          id: AppDatabase._uuid.v4(),
          userId: userId,
          accountId: asset.accountId,
          destinationAccountId: Value(destinationAccountId),
          accountCredited: Value(destinationAccountId != null),
          physicalAssetId: Value(asset.id),
          assetName: asset.name,
          assetKind: 'physical',
          quantity: grams,
          unit: 'g',
          pricePerUnit: pricePerGram,
          fees: Value(fees),
          proceeds: proceeds,
          costBasis: Value(costBasis),
          realizedGain: Value(realizedGain),
          allowanceUsed: Value(allowanceUsed),
          taxPaid: Value(taxPaid),
          soldAt: soldAt,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await (update(
        physicalAssets,
      )..where((row) => row.id.equals(asset.id))).write(
        PhysicalAssetsCompanion(
          weightGrams: Value(remainingGrams),
          purchasePrice: Value(
            (asset.purchasePrice - costBasis).clamp(0, double.infinity),
          ),
          currentValue: Value(remainingGrams * asset.currentPricePerGram),
          deletedAt: Value(remainingGrams <= 0 ? DateTime.now().toUtc() : null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      if (destinationAccountId != null) {
        final account =
            await (select(accounts)..where(
                  (row) =>
                      row.id.equals(destinationAccountId) &
                      row.userId.equals(userId) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (account == null) {
          throw StateError('Das Zielkonto ist nicht verfügbar.');
        }
        await (update(
          accounts,
        )..where((row) => row.id.equals(destinationAccountId))).write(
          AccountsCompanion(
            balance: Value(account.balance + proceeds),
            availableBalance: Value(account.availableBalance + proceeds),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
    await captureNetWorth(userId);
  }

  Future<void> _writePortfolioAudit({
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    required String entityName,
    String details = '',
  }) => into(portfolioAuditLogs).insert(
    PortfolioAuditLogsCompanion.insert(
      id: AppDatabase._uuid.v4(),
      userId: userId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      displayName: entityName,
      details: Value(details),
      occurredAt: DateTime.now().toUtc(),
    ),
  );

  Future<void> saveInvestment(InvestmentsCompanion value) async {
    final accountId = value.accountId.value;
    final userId = value.userId.value;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(userId, accountId, 'portfolio')) {
      throw StateError(
        'Für Portfolio-Positionen ist ein freies Portfolio-Konto erforderlich.',
      );
    }
    await (update(
          accounts,
        )..where((row) => row.id.equals(accountId) & row.userId.equals(userId)))
        .write(
          AccountsCompanion(
            usageType: const Value('portfolio'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await into(investments).insertOnConflictUpdate(value);
    await captureNetWorth(userId);
  }

  Future<void> deleteInvestment(String id, String userId) async {
    final investment =
        await (select(investments)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (investment == null || investment.deletedAt != null) return;
    final refundable = await _cashAppliedPurchaseTotal(id, userId);
    await transaction(() async {
      if (refundable > 0) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: refundable,
        );
      }
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'investment',
        entityId: id,
        entityName: investment.name,
        details:
            '${investment.quantity} Stück · ${refundable.toStringAsFixed(2)} Kontoguthaben freigegeben',
      );
      await (update(
        investments,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        InvestmentsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    });
    await captureNetWorth(userId);
  }

  Future<void> restoreInvestment(String id, String userId) async {
    final investment =
        await (select(investments)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (investment == null || investment.deletedAt == null) return;
    final purchaseCash = await _cashAppliedPurchaseTotal(id, userId);
    await transaction(() async {
      if (purchaseCash > 0) {
        await _changePortfolioCash(
          userId: userId,
          accountId: investment.accountId,
          delta: -purchaseCash,
        );
      }
      await (update(
        investments,
      )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
        InvestmentsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _writePortfolioAudit(
        userId: userId,
        action: 'restored',
        entityType: 'investment',
        entityId: id,
        entityName: investment.name,
        details:
            '${purchaseCash.toStringAsFixed(2)} Kontoguthaben wieder gebunden',
      );
    });
    await captureNetWorth(userId);
  }

  Future<double> _cashAppliedPurchaseTotal(
    String investmentId,
    String userId,
  ) async {
    final rows =
        await (select(investmentPurchases)..where(
              (row) =>
                  row.investmentId.equals(investmentId) &
                  row.userId.equals(userId) &
                  row.cashApplied.equals(true) &
                  row.deletedAt.isNull(),
            ))
            .get();
    return rows.fold<double>(0, (sum, row) => sum + row.cashAmount);
  }

  Future<void> _changePortfolioCash({
    required String userId,
    required String accountId,
    required double delta,
  }) async {
    final account =
        await (select(accounts)..where(
              (row) => row.id.equals(accountId) & row.userId.equals(userId),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Portfolio-Konto fehlt.');
    await (update(accounts)..where((row) => row.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(account.balance + delta),
        availableBalance: Value(account.availableBalance + delta),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> updateInvestmentCurrentPrice({
    required String id,
    required String userId,
    required double currentPrice,
  }) async {
    if (currentPrice < 0) {
      throw ArgumentError('Der Kurs darf nicht negativ sein.');
    }
    await (update(
      investments,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      InvestmentsCompanion(
        currentPrice: Value(currentPrice),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> updateInvestmentDividend({
    required String id,
    required String userId,
    required double dividendPerShare,
  }) async {
    if (dividendPerShare < 0) throw ArgumentError('Ungültige Dividende.');
    await (update(
      investments,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      InvestmentsCompanion(
        annualDividend: Value(dividendPerShare),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<PhysicalAsset>> watchPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNull() &
                  row.accountId.isNotInQuery(
                    selectOnly(accounts)
                      ..addColumns([accounts.id])
                      ..where(accounts.deletedAt.isNotNull()),
                  ),
            )
            ..orderBy([
              (row) => OrderingTerm.asc(row.category),
              (row) => OrderingTerm.asc(row.name),
            ]))
          .watch();

  Stream<List<PhysicalAsset>> watchAllPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([
              (row) => OrderingTerm.asc(row.category),
              (row) => OrderingTerm.asc(row.name),
            ]))
          .watch();

  Stream<List<PhysicalAsset>> watchDeletedPhysicalAssets(String userId) =>
      (select(physicalAssets)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.weightGrams.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .watch();

  Future<List<PhysicalAsset>> deletedPhysicalAssetsFor(String userId) =>
      (select(physicalAssets)
            ..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.deletedAt.isNotNull() &
                  row.weightGrams.isBiggerThanValue(0),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
          .get();

  Future<void> savePhysicalAsset(PhysicalAssetsCompanion value) async {
    final accountId = value.accountId.value;
    final userId = value.userId.value;
    if (accountId.isEmpty ||
        !await accountCanBeUsed(userId, accountId, 'portfolio')) {
      throw StateError(
        'Für physische Werte ist ein freies Portfolio-Konto erforderlich.',
      );
    }
    await (update(
          accounts,
        )..where((row) => row.id.equals(accountId) & row.userId.equals(userId)))
        .write(
          AccountsCompanion(
            usageType: const Value('portfolio'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
    await into(physicalAssets).insertOnConflictUpdate(value);
    await captureNetWorth(userId);
  }

  Future<void> deletePhysicalAsset(String id, String userId) async {
    final asset =
        await (select(physicalAssets)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (asset != null) {
      await _writePortfolioAudit(
        userId: userId,
        action: 'deleted',
        entityType: 'physical',
        entityId: id,
        entityName: asset.name,
        details: '${asset.weightGrams} g',
      );
    }
    await (update(
      physicalAssets,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      PhysicalAssetsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await captureNetWorth(userId);
  }

  Future<void> restorePhysicalAsset(String id, String userId) async {
    final asset =
        await (select(physicalAssets)
              ..where((row) => row.id.equals(id) & row.userId.equals(userId)))
            .getSingleOrNull();
    if (asset == null) return;
    await (update(
      physicalAssets,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      PhysicalAssetsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await _writePortfolioAudit(
      userId: userId,
      action: 'restored',
      entityType: 'physical',
      entityId: id,
      entityName: asset.name,
    );
    await captureNetWorth(userId);
  }

  Stream<List<DividendSchedule>> watchDividendSchedules(String userId) =>
      (select(dividendSchedules)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.paymentMonth),
              (row) => OrderingTerm.asc(row.investmentId),
            ]))
          .watch();

  Future<void> saveDividendSchedule(DividendSchedulesCompanion value) async {
    await into(dividendSchedules).insertOnConflictUpdate(value);
    _schedulePersist(value.userId.value);
  }

  Future<void> deleteDividendSchedule(String id, String userId) async {
    await (update(
      dividendSchedules,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      DividendSchedulesCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Stream<List<NetWorthSnapshot>> watchNetWorthSnapshots(String userId) =>
      (select(netWorthSnapshots)
            ..where((row) => row.userId.equals(userId))
            ..orderBy([(row) => OrderingTerm.asc(row.capturedAt)]))
          .watch();

  Future<void> captureNetWorth(String userId) async {
    final accountRows =
        await (select(accounts)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final liveAccountIds = accountRows.map((row) => row.id).toSet();
    final investmentRows =
        (await (select(investments)..where(
                  (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
                ))
                .get())
            .where((row) => liveAccountIds.contains(row.accountId))
            .toList();
    final physicalRows =
        (await (select(physicalAssets)..where(
                  (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
                ))
                .get())
            .where(
              (row) =>
                  row.accountId.isEmpty ||
                  liveAccountIds.contains(row.accountId),
            )
            .toList();
    final vehicleRows =
        await (select(vehicles)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final converter = CurrencyConverter.fromRates(
      (await preferencesFor(userId)).currency,
      await select(countryTaxRates).get(),
    );
    final accountBalance = accountRows.fold<double>(
      0,
      (sum, row) => sum + converter.toBase(row.balance, row.currency),
    );
    final portfolioValue =
        investmentRows.fold<double>(
          0,
          (sum, row) => sum + converter.investmentValue(row),
        ) +
        physicalRows.fold<double>(
          0,
          (sum, row) => sum + row.weightGrams * row.currentPricePerGram,
        );
    final vehicleValue = vehicleRows.fold<double>(
      0,
      (sum, row) => sum + row.currentValue,
    );
    final last =
        await (select(netWorthSnapshots)
              ..where((row) => row.userId.equals(userId))
              ..orderBy([(row) => OrderingTerm.desc(row.capturedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (last != null &&
        last.accountBalance == accountBalance &&
        last.portfolioValue == portfolioValue &&
        last.vehicleValue == vehicleValue) {
      _schedulePersist(userId);
      return;
    }
    await into(netWorthSnapshots).insert(
      NetWorthSnapshotsCompanion.insert(
        id: AppDatabase._uuid.v4(),
        userId: userId,
        capturedAt: DateTime.now().toUtc(),
        accountBalance: accountBalance,
        portfolioValue: portfolioValue,
        totalNetWorth: accountBalance + portfolioValue,
        vehicleValue: Value(vehicleValue),
      ),
    );
    _schedulePersist(userId);
  }
}
