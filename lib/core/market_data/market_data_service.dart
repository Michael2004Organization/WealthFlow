import '../database/app_database.dart';

/// Provider-neutral request plan. The concrete HTTP adapter is intentionally
/// left out until the final market-data endpoint is selected.
final class MarketDataRequestPlan {
  const MarketDataRequestPlan({
    required this.symbols,
    required this.slot,
    required this.reason,
  });

  final List<String> symbols;
  final DateTime slot;
  final String reason;

  bool get isEmpty => symbols.isEmpty;
}

final class ExchangeRateRequestPlan {
  const ExchangeRateRequestPlan({
    required this.currencies,
    required this.slot,
    required this.reason,
  });

  final List<String> currencies;
  final DateTime slot;
  final String reason;

  bool get isEmpty => currencies.isEmpty;
}

/// Centralizes cache and schedule decisions so opening a portfolio never
/// causes one request per user or position.
final class MarketDataCoordinator {
  MarketDataCoordinator(this._database);

  final AppDatabase _database;

  static const refreshHours = [10, 15, 19];
  static const dailyRequestLimit = 250;

  Future<MarketDataRequestPlan> quotePlan(
    DateTime now, {
    required String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      return MarketDataRequestPlan(
        symbols: const [],
        slot: DateTime(now.year, now.month, now.day),
        reason: 'Kein API-Key eingerichtet – Aktienabfragen sind deaktiviert',
      );
    }
    final slot = latestDueSlot(now);
    if (slot == null) {
      return MarketDataRequestPlan(
        symbols: const [],
        slot: DateTime(now.year, now.month, now.day),
        reason: 'Vor dem ersten Aktualisierungsfenster',
      );
    }
    final last = await _database.lastMarketRefresh('quotes', 'global');
    if (last != null && !last.isBefore(slot)) {
      return MarketDataRequestPlan(
        symbols: const [],
        slot: slot,
        reason: 'Aktuelles Zeitfenster bereits aus dem Cache bedient',
      );
    }
    final stocks = await _database.stockPool();
    return MarketDataRequestPlan(
      symbols: stocks.map((stock) => stock.symbol).toSet().toList()..sort(),
      slot: slot,
      reason: 'Eine gemeinsame Batch-Abfrage für den gesamten Aktienpool',
    );
  }

  Future<ExchangeRateRequestPlan> exchangeRatePlan(
    DateTime now, {
    required String? apiKey,
    required String baseCurrency,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      return ExchangeRateRequestPlan(
        currencies: const [],
        slot: DateTime(now.year, now.month, now.day),
        reason: 'Kein Wechselkurs-API-Key eingerichtet',
      );
    }
    final last = await _database.lastMarketRefresh('exchangeRates', 'global');
    final scheduledSlot = latestDueSlot(now);
    final slot = last == null
        ? now
        : scheduledSlot ?? DateTime(now.year, now.month, now.day);
    if (last != null &&
        (scheduledSlot == null || !last.isBefore(scheduledSlot))) {
      return ExchangeRateRequestPlan(
        currencies: const [],
        slot: slot,
        reason: scheduledSlot == null
            ? 'Vor dem ersten Aktualisierungsfenster'
            : 'Aktuelles Wechselkursfenster bereits geladen',
      );
    }
    final rates = await _database.countryExchangePool();
    final currencies =
        rates
            .map((item) => item.currency.toUpperCase())
            .where((currency) => currency != baseCurrency.toUpperCase())
            .toSet()
            .toList()
          ..sort();
    return ExchangeRateRequestPlan(
      currencies: currencies,
      slot: slot,
      reason: last == null
          ? 'Erste Abfrage nach dem Hinterlegen des API-Keys'
          : 'Gemeinsame Wechselkursabfrage für das fällige Zeitfenster',
    );
  }

  DateTime? latestDueSlot(DateTime now) {
    for (final hour in refreshHours.reversed) {
      final slot = DateTime(now.year, now.month, now.day, hour);
      if (!slot.isAfter(now)) return slot;
    }
    return null;
  }

  Future<bool> shouldLoadDividendYear(String stockId, int year) async {
    final last = await _database.lastMarketRefresh(
      'dividends',
      '$stockId:$year',
    );
    return last == null;
  }

  Future<int> remainingRequests(DateTime now) async {
    final used = await _database.apiRequestsForDay(_dayKey(now));
    return (dailyRequestLimit - used).clamp(0, dailyRequestLimit);
  }

  Future<bool> canSendRequest(DateTime now) async =>
      await remainingRequests(now) > 0;

  Future<void> recordRequest(DateTime now) =>
      _database.recordApiRequest(_dayKey(now));

  String _dayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
