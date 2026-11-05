part of '../app_database.dart';

/// Benutzer, Stammdaten der Wertpapiere, Länder und Kurse, Konfiguration und Fehlerprotokoll.
extension AdminQueries on AppDatabase {
  Future<User?> userByEmail(String email) => (select(
    users,
  )..where((row) => row.email.equals(email.toLowerCase()))).getSingleOrNull();

  Future<User?> userById(String id) =>
      (select(users)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<void> createUser(UsersCompanion user) => into(users).insert(user);

  Future<int> userCount() async {
    final count = users.id.count();
    final row = await (selectOnly(users)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<User>> watchUsers() => (select(
    users,
  )..orderBy([(row) => OrderingTerm.asc(row.displayName)])).watch();

  Future<void> updateUserRole({
    required String actorUserId,
    required String userId,
    required String role,
  }) async {
    await _requireAdmin(actorUserId);
    if (!const {'admin', 'member'}.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Unbekannte Rolle');
    }
    if (actorUserId == userId && role != 'admin') {
      throw StateError('Administratoren können sich nicht selbst herabstufen.');
    }
    await (update(users)..where((row) => row.id.equals(userId))).write(
      UsersCompanion(
        role: Value(role),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<StockMaster>> watchStockMasters() =>
      (select(stockMasters)
            ..where((row) => row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Future<List<StockMaster>> stockPool() =>
      (select(stockMasters)..where((row) => row.deletedAt.isNull())).get();

  String _stockMasterIdentity(StockMaster stock) => portfolioMasterIdentity(
    assetType: stock.assetType,
    name: stock.name,
    symbol: stock.symbol,
    isin: stock.isin,
    wkn: stock.wkn,
    instrumentSubtype: stock.instrumentSubtype,
    issuer: stock.issuer,
    underlying: stock.underlying,
    maturityDate: stock.maturityDate,
  );

  String _companionStockMasterIdentity(StockMastersCompanion value) =>
      portfolioMasterIdentity(
        assetType: value.assetType.present ? value.assetType.value : 'Aktie',
        name: value.name.value,
        symbol: value.symbol.value,
        isin: value.isin.present ? value.isin.value : '',
        wkn: value.wkn.present ? value.wkn.value : '',
        instrumentSubtype: value.instrumentSubtype.present
            ? value.instrumentSubtype.value
            : '',
        issuer: value.issuer.present ? value.issuer.value : '',
        underlying: value.underlying.present ? value.underlying.value : '',
        maturityDate: value.maturityDate.present
            ? value.maturityDate.value
            : null,
      );

  String? _validateStockMasterCompanion(StockMastersCompanion value) =>
      portfolioMasterValidationError(
        assetType: value.assetType.present ? value.assetType.value : 'Aktie',
        name: value.name.value,
        country: value.country.present ? value.country.value : '',
        symbol: value.symbol.value,
        isin: value.isin.present ? value.isin.value : '',
        wkn: value.wkn.present ? value.wkn.value : '',
        instrumentSubtype: value.instrumentSubtype.present
            ? value.instrumentSubtype.value
            : '',
        issuer: value.issuer.present ? value.issuer.value : '',
        underlying: value.underlying.present ? value.underlying.value : '',
      );

  Future<StockMaster?> _matchingStockMaster(
    StockMastersCompanion value, {
    String? excludingId,
  }) async {
    final identity = _companionStockMasterIdentity(value);
    final items = await stockPool();
    return items
        .where(
          (item) =>
              item.id != excludingId && _stockMasterIdentity(item) == identity,
        )
        .firstOrNull;
  }

  Future<void> saveStockMaster(
    String actorUserId,
    StockMastersCompanion value,
  ) async {
    await _requireAdmin(actorUserId);
    final validationError = _validateStockMasterCompanion(value);
    if (validationError != null) throw ArgumentError(validationError);
    if (await _matchingStockMaster(value, excludingId: value.id.value) !=
        null) {
      throw StateError(
        'Ein Portfolio-Stammdatensatz mit dieser Identität existiert bereits.',
      );
    }
    await transaction(() async {
      await into(stockMasters).insertOnConflictUpdate(value);
      final stock = await (select(
        stockMasters,
      )..where((row) => row.id.equals(value.id.value))).getSingle();
      final rates = await select(countryTaxRates).get();
      final normalizedCountry = stock.country.trim().toLowerCase();
      final countryConfiguration = rates
          .where(
            (rate) => rate.country.trim().toLowerCase() == normalizedCountry,
          )
          .firstOrNull;
      final savedDividendCurrency = stock.dividendCurrency.toUpperCase();
      final configuredRate = countryConfiguration?.withholdingTaxRate;
      final fallbackRate =
          const {
            'usa',
            'us',
            'united states',
            'vereinigte staaten',
          }.contains(normalizedCountry)
          ? 15.0
          : 0.0;
      await (update(investments)..where(
            (row) => row.stockId.equals(stock.id) & row.deletedAt.isNull(),
          ))
          .write(
            InvestmentsCompanion(
              name: Value(stock.name),
              assetType: Value(stock.assetType),
              symbol: Value(stock.symbol),
              isin: Value(stock.isin),
              wkn: Value(stock.wkn),
              instrumentSubtype: Value(stock.instrumentSubtype),
              positionDirection: Value(stock.positionDirection),
              issuer: Value(stock.issuer),
              underlying: Value(stock.underlying),
              instrumentCurrency: Value(stock.instrumentCurrency),
              nominalValue: Value(stock.nominalValue),
              couponRate: Value(stock.couponRate),
              maturityDate: Value(stock.maturityDate),
              strikePrice: Value(stock.strikePrice),
              knockOutBarrier: Value(stock.knockOutBarrier),
              leverage: Value(stock.leverage),
              subscriptionRatio: Value(stock.subscriptionRatio),
              broker: Value(stock.broker),
              country: Value(stock.country),
              sector: Value(stock.sector),
              dividendCurrency: Value(savedDividendCurrency),
              annualDividend: Value(stock.dividendPerShare),
              dividendFrequency: Value(stock.dividendFrequency),
              dividendStartMonth: Value(stock.dividendStartMonth),
              dividendWithholdingTaxRate: Value(configuredRate ?? fallbackRate),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
  }

  /// Creates a catalogue record from a position if its class-specific
  /// identity is not known yet. Existing records are returned unchanged.
  Future<StockMaster> ensurePortfolioMaster(
    String actorUserId,
    StockMastersCompanion value,
  ) async {
    if (await userById(actorUserId) == null) {
      throw StateError('Unbekannter Benutzer.');
    }
    final validationError = _validateStockMasterCompanion(value);
    if (validationError != null) throw ArgumentError(validationError);
    return transaction(() async {
      final existing = await _matchingStockMaster(value);
      if (existing != null) return existing;
      await into(stockMasters).insert(value);
      return (select(
        stockMasters,
      )..where((row) => row.id.equals(value.id.value))).getSingle();
    });
  }

  Future<void> deleteStockMaster(String actorUserId, String id) async {
    await _requireAdmin(actorUserId);
    await (update(stockMasters)..where((row) => row.id.equals(id))).write(
      StockMastersCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> _requireAdmin(String userId) async {
    final actor = await userById(userId);
    if (actor?.role != 'admin') {
      throw StateError('Für diese Aktion ist die Adminrolle erforderlich.');
    }
  }

  /// Dividends not paid yet; paid ones keep the rate they were paid with.
  Expression<bool> _openDividendSchedule($DividendSchedulesTable row) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (row.paymentDate.isNotNull() &
            row.paymentDate.isBiggerOrEqualValue(today)) |
        (row.paymentDate.isNull() &
            (row.paymentYear.equals(0) |
                row.paymentYear.isBiggerThanValue(now.year) |
                (row.paymentYear.equals(now.year) &
                    row.paymentMonth.isBiggerOrEqualValue(now.month))));
  }

  Stream<List<CountryTaxRate>> watchCountryTaxRates() => (select(
    countryTaxRates,
  )..orderBy([(row) => OrderingTerm.asc(row.country)])).watch();

  Future<List<CountryTaxRate>> countryExchangePool() => (select(
    countryTaxRates,
  )..orderBy([(row) => OrderingTerm.asc(row.country)])).get();

  Stream<List<AssetClassesData>> watchAssetClasses() =>
      (select(assetClasses)..orderBy([
            (row) => OrderingTerm.asc(row.displayOrder),
            (row) => OrderingTerm.asc(row.name),
          ]))
          .watch();

  Future<void> saveAssetClass({
    required String actorUserId,
    required String name,
  }) async {
    await _requireAdmin(actorUserId);
    final normalized = name.trim();
    if (!supportedPortfolioAssetClasses.contains(normalized)) {
      throw StateError('Die Portfolio-Anlageklassen sind fest vorgegeben.');
    }
    await _seedAssetClasses();
  }

  Future<void> deleteAssetClass({
    required String actorUserId,
    required String name,
  }) async {
    await _requireAdmin(actorUserId);
    throw StateError('Die Portfolio-Anlageklassen sind fest vorgegeben.');
  }

  Future<List<String>> availableCountries() async {
    final values = <String>[];
    values.addAll(
      (await (select(masterData)..where(
                (row) => row.kind.equals('country') & row.deletedAt.isNull(),
              ))
              .get())
          .map((row) => row.value.trim()),
    );
    values.addAll(
      (await (select(
        stockMasters,
      )..where((row) => row.deletedAt.isNull())).get()).map(
        (row) => row.country.trim(),
      ),
    );
    values.addAll(
      (await select(countryTaxRates).get()).map((row) => row.country.trim()),
    );
    final deduplicated = <String, String>{};
    for (final value in values.where((value) => value.isNotEmpty)) {
      deduplicated.putIfAbsent(normalizeCountry(value), () => value.trim());
    }
    final sorted = deduplicated.values.toList()..sort();
    return sorted;
  }

  Future<void> saveCountryTaxRate({
    required String actorUserId,
    required String country,
    required double rate,
    String? currency,
  }) async {
    await _requireAdmin(actorUserId);
    if (country.trim().isEmpty || rate < 0 || rate > 100) {
      throw ArgumentError('Land und Quellensteuer müssen gültig sein.');
    }
    final normalizedCountry = normalizeCountry(country);
    final existing = (await select(countryTaxRates).get())
        .where((row) => normalizeCountry(row.country) == normalizedCountry)
        .firstOrNull;
    final normalizedCurrency = (currency ?? '').trim().toUpperCase();
    if (normalizedCurrency.isNotEmpty &&
        !isSupportedCurrency(normalizedCurrency)) {
      throw ArgumentError('Nicht unterstützte ISO-Währung.');
    }
    final resolvedCurrency = normalizedCurrency.isNotEmpty
        ? normalizedCurrency
        : existing?.currency.toUpperCase() ??
              defaultCurrencyForCountry(country);
    if (existing == null) {
      await into(countryTaxRates).insert(
        CountryTaxRatesCompanion.insert(
          country: country.trim(),
          withholdingTaxRate: Value(rate),
          currency: Value(resolvedCurrency),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } else {
      await (update(
        countryTaxRates,
      )..where((row) => row.country.equals(existing.country))).write(
        CountryTaxRatesCompanion(
          withholdingTaxRate: Value(rate),
          currency: Value(resolvedCurrency),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
    final normalized = normalizeCountry(country);
    final affected = (await select(investments).get())
        .where(
          (investment) => investment.country.trim().toLowerCase() == normalized,
        )
        .toList();
    await transaction(() async {
      for (final investment in affected) {
        await (update(
          investments,
        )..where((row) => row.id.equals(investment.id))).write(
          InvestmentsCompanion(
            dividendWithholdingTaxRate: Value(rate),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        await (update(dividendSchedules)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.deletedAt.isNull() &
                  _openDividendSchedule(row),
            ))
            .write(
              DividendSchedulesCompanion(
                withholdingTaxRate: Value(rate),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    });
  }

  Future<void> saveCountryExchangeRate({
    required String actorUserId,
    required String country,
    required String currency,
    required double exchangeRate,
  }) async {
    if (country.trim().isEmpty ||
        currency.trim().isEmpty ||
        exchangeRate <= 0) {
      throw ArgumentError('Land, Währung und Wechselkurs müssen gültig sein.');
    }
    if (!isSupportedCurrency(currency)) {
      throw ArgumentError('Nicht unterstützte ISO-Währung.');
    }
    final actor = await userById(actorUserId);
    final existing = (await select(countryTaxRates).get())
        .where(
          (row) =>
              row.country.trim().toLowerCase() == country.trim().toLowerCase(),
        )
        .firstOrNull;
    final isAdmin = actor?.role == 'admin';
    // The rate applies to every user of this database; with more than one
    // user only an administrator may change it.
    if (!isAdmin && (await select(users).get()).length > 1) {
      throw StateError(
        'Wechselkurse gelten für alle Benutzer und dürfen nur von der '
        'Administration geändert werden.',
      );
    }
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await into(countryTaxRates).insert(
        CountryTaxRatesCompanion.insert(
          country: country.trim(),
          currency: Value(currency.trim().toUpperCase()),
          exchangeRate: Value(exchangeRate),
          exchangeRateUpdatedAt: Value(now),
          updatedAt: now,
        ),
      );
    } else {
      await (update(
        countryTaxRates,
      )..where((row) => row.country.equals(existing.country))).write(
        CountryTaxRatesCompanion(
          currency: Value(currency.trim().toUpperCase()),
          exchangeRate: Value(exchangeRate),
          exchangeRateUpdatedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
    final normalized = country.trim().toLowerCase();
    final affected = (await select(investments).get())
        .where((item) => item.country.trim().toLowerCase() == normalized)
        .toList();
    await transaction(() async {
      for (final investment in affected) {
        await (update(
          investments,
        )..where((row) => row.id.equals(investment.id))).write(
          InvestmentsCompanion(
            dividendCurrency: Value(currency.trim().toUpperCase()),
            dividendExchangeRate: Value(exchangeRate),
            updatedAt: Value(now),
          ),
        );
        await (update(dividendSchedules)..where(
              (row) =>
                  row.investmentId.equals(investment.id) &
                  row.deletedAt.isNull() &
                  _openDividendSchedule(row),
            ))
            .write(
              DividendSchedulesCompanion(
                currency: Value(currency.trim().toUpperCase()),
                exchangeRate: Value(exchangeRate),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  Stream<AppConfiguration> watchAppConfiguration() async* {
    yield await appConfiguration();
    yield* (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).watchSingle();
  }

  Future<AppConfiguration> appConfiguration() async {
    final current = await (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).getSingleOrNull();
    if (current != null) return current;
    await into(appConfigurations).insert(
      AppConfigurationsCompanion.insert(
        id: 'global',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    return (select(
      appConfigurations,
    )..where((row) => row.id.equals('global'))).getSingle();
  }

  Future<void> setMaximumTaxAllowance({
    required String actorUserId,
    required double amount,
  }) async {
    await _requireAdmin(actorUserId);
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Ungültiger Höchstbetrag');
    }
    await into(appConfigurations).insertOnConflictUpdate(
      AppConfigurationsCompanion.insert(
        id: 'global',
        maximumTaxAllowance: Value(amount),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await customStatement(
      'UPDATE user_preferences SET tax_allowance = ? '
      'WHERE tax_allowance > ?',
      [amount, amount],
    );
  }

  Stream<List<AppErrorLog>> watchErrorLogs() => (select(
    appErrorLogs,
  )..orderBy([(row) => OrderingTerm.desc(row.occurredAt)])).watch();

  Future<void> logError({
    String? userId,
    required String source,
    required Object error,
    StackTrace? stackTrace,
    String details = '',
  }) async {
    try {
      await into(appErrorLogs).insert(
        AppErrorLogsCompanion.insert(
          id: AppDatabase._uuid.v4(),
          userId: Value(userId),
          source: source,
          message: error.toString(),
          details: Value(details),
          stackTrace: Value(stackTrace?.toString() ?? ''),
          occurredAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      // Error reporting must never trigger another application failure.
    }
  }

  Future<void> clearErrorLogs(String actorUserId) async {
    await _requireAdmin(actorUserId);
    await delete(appErrorLogs).go();
  }

  Future<void> updateUserPassword(String userId, String hash, String salt) =>
      (update(users)..where((row) => row.id.equals(userId))).write(
        UsersCompanion(
          passwordHash: Value(hash),
          passwordSalt: Value(salt),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
