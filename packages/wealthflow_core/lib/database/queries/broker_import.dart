part of '../app_database.dart';

/// What a broker import changed.
class BrokerImportSummary {
  int buys = 0;
  int sells = 0;
  int dividends = 0;
  int createdPositions = 0;
  int duplicates = 0;
  final failures = <String>[];

  int get imported => buys + sells + dividends;
}

/// Imports buys, sells and dividends of a broker export into one depot.
extension BrokerImportQueries on AppDatabase {
  /// Rows are applied oldest first. Positions are matched by ISIN within
  /// [accountId]; unknown ones are created. Running the same file twice
  /// changes nothing: buys keep the broker's id, sells and dividends are
  /// recognised by day and amount.
  ///
  /// With [bookCash], buys take their price from the depot's cash and
  /// dividends are paid into it (sells always credit it).
  Future<BrokerImportSummary> importBrokerTransactions({
    required String userId,
    required String accountId,
    required List<BrokerTransaction> transactions,
    bool bookCash = true,
  }) async {
    final summary = BrokerImportSummary();
    final ordered = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    for (final row in ordered) {
      try {
        final outcome = await _importBrokerRow(
          userId: userId,
          accountId: accountId,
          row: row,
          bookCash: bookCash,
        );
        switch (outcome) {
          case _BrokerOutcome.duplicate:
            summary.duplicates++;
          case _BrokerOutcome.createdAndBought:
            summary.createdPositions++;
            summary.buys++;
          case _BrokerOutcome.bought:
            summary.buys++;
          case _BrokerOutcome.sold:
            summary.sells++;
          case _BrokerOutcome.dividend:
            summary.dividends++;
        }
      } catch (error) {
        summary.failures.add(
          '${row.name} (${_day(row.date)}): ${_message(error)}',
        );
      }
    }
    return summary;
  }

  Future<_BrokerOutcome> _importBrokerRow({
    required String userId,
    required String accountId,
    required BrokerTransaction row,
    required bool bookCash,
  }) async {
    var investment = await _investmentByIsin(userId, accountId, row.isin);
    switch (row.kind) {
      case BrokerTransactionKind.buy:
        final purchaseId = 'broker-${_stableId(row.id)}';
        final existing = await (select(
          investmentPurchases,
        )..where((r) => r.id.equals(purchaseId))).getSingleOrNull();
        if (existing != null) return _BrokerOutcome.duplicate;
        var created = false;
        if (investment == null) {
          investment = await _createBrokerPosition(userId, accountId, row);
          created = true;
        }
        _requireEuro(investment);
        await recordInvestmentPurchase(
          userId: userId,
          investmentId: investment.id,
          purchaseDate: row.date,
          purchasePrice: row.price,
          quantity: row.shares,
          fees: row.fee,
          buy: bookCash,
          id: purchaseId,
        );
        return created
            ? _BrokerOutcome.createdAndBought
            : _BrokerOutcome.bought;
      case BrokerTransactionKind.sell:
        if (investment == null) {
          throw StateError('Keine Position mit ISIN ${row.isin} im Depot.');
        }
        _requireEuro(investment);
        final sameDay =
            await (select(portfolioSales)..where(
                  (r) =>
                      r.userId.equals(userId) &
                      r.investmentId.equals(investment!.id),
                ))
                .get();
        final duplicate = sameDay.any(
          (sale) =>
              _sameDay(sale.soldAt, row.date) &&
              (sale.quantity - row.shares).abs() < 1e-6,
        );
        if (duplicate) return _BrokerOutcome.duplicate;
        await sellInvestment(
          userId: userId,
          investmentId: investment.id,
          quantity: row.shares,
          pricePerUnit: row.price,
          fees: row.fee,
          soldAt: row.date,
        );
        return _BrokerOutcome.sold;
      case BrokerTransactionKind.dividend:
        if (investment == null) {
          throw StateError('Keine Position mit ISIN ${row.isin} im Depot.');
        }
        final receiptId = dividendReceiptId(investment.id, row.date);
        final receipt = await (select(
          dividendReceipts,
        )..where((r) => r.id.equals(receiptId))).getSingleOrNull();
        if (receipt != null &&
            receipt.deletedAt == null &&
            receipt.status == 'received') {
          return _BrokerOutcome.duplicate;
        }
        if (!bookCash) return _BrokerOutcome.duplicate;
        await receiveDividend(
          userId: userId,
          investment: investment,
          accountId: accountId,
          dueDate: row.date,
          paymentDate: row.date,
          amount: double.parse(row.netAmount.toStringAsFixed(2)),
        );
        return _BrokerOutcome.dividend;
    }
  }

  Future<Investment?> _investmentByIsin(
    String userId,
    String accountId,
    String isin,
  ) async {
    final rows =
        await (select(investments)..where(
              (r) =>
                  r.userId.equals(userId) &
                  r.accountId.equals(accountId) &
                  r.deletedAt.isNull(),
            ))
            .get();
    return rows
        .where((item) => item.isin.trim().toUpperCase() == isin)
        .firstOrNull;
  }

  Future<Investment> _createBrokerPosition(
    String userId,
    String accountId,
    BrokerTransaction row,
  ) async {
    final now = DateTime.now().toUtc();
    final id = AppDatabase._uuid.v4();
    await saveInvestment(
      InvestmentsCompanion.insert(
        id: id,
        userId: userId,
        accountId: Value(accountId),
        name: row.name,
        isin: Value(row.isin),
        assetType: row.assetType,
        instrumentCurrency: const Value('EUR'),
        dividendCurrency: const Value('EUR'),
        broker: const Value('Trade Republic'),
        purchaseDate: row.date,
        purchasePrice: row.price,
        // Filled in from the purchases that follow.
        quantity: 0,
        currentPrice: row.price,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return (select(investments)..where((r) => r.id.equals(id))).getSingle();
  }

  /// Trade Republic books in EUR; a position kept in another currency would
  /// mix up prices.
  void _requireEuro(Investment investment) {
    final currency = investment.instrumentCurrency.toUpperCase();
    if (currency.isNotEmpty && currency != 'EUR') {
      throw StateError(
        'Die Position wird in $currency geführt, der Export in EUR.',
      );
    }
  }
}

enum _BrokerOutcome { duplicate, createdAndBought, bought, sold, dividend }

/// The broker id as a plain text key (works the same on web).
String _stableId(String value) =>
    value.replaceAll(RegExp(r'[^A-Za-z0-9.-]'), '_');

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _day(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.${date.year}';

String _message(Object error) => switch (error) {
  StateError(:final message) => message,
  ArgumentError(:final message) => '$message',
  _ => '$error',
};
