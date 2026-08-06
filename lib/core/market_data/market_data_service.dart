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
