part of '../app_database.dart';

/// Bestätigte Dividenden: als Buchung im Haushalt oder als Geld im Depot.
extension DividendReceiptQueries on AppDatabase {
  Stream<List<DividendReceipt>> watchDividendReceipts(String userId) =>
      (select(dividendReceipts)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.paymentDate)]))
          .watch();

  /// Books a received dividend. On a household account it becomes an income
  /// booking (category "Dividende"); on a portfolio account the cash balance
  /// grows, like the proceeds of a sale. [dueDate] is the projected date
  /// the confirmation belongs to; [paymentDate] the real one (default).
  Future<void> receiveDividend({
    required String userId,
    required Investment investment,
    required String accountId,
    required DateTime dueDate,
    DateTime? paymentDate,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Der Betrag muss größer als 0 sein.');
    }
    final id = dividendReceiptId(investment.id, dueDate);
    final paid = paymentDate ?? dueDate;
    final existing = await (select(
      dividendReceipts,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (existing != null &&
        existing.deletedAt == null &&
        existing.status == 'received') {
      return;
    }
    final account =
        await (select(accounts)..where(
              (row) =>
                  row.id.equals(accountId) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (account == null) throw StateError('Das Konto ist nicht verfügbar.');
    final portfolio = account.usageType == 'portfolio';
    final now = DateTime.now().toUtc();
    final day = DateTime(paid.year, paid.month, paid.day);
    await transaction(() async {
      if (portfolio) {
        await _changePortfolioCash(
          userId: userId,
          accountId: accountId,
          delta: amount,
        );
        await _writePortfolioAudit(
          userId: userId,
          action: 'dividend',
          entityType: 'investment',
          entityId: investment.id,
          entityName: investment.name,
          details:
              '${day.toIso8601String()} · ${amount.toStringAsFixed(2)} '
              '${account.currency}',
        );
      } else {
        await saveLedgerEntries([
          LedgerEntriesCompanion.insert(
            id: id,
            userId: userId,
            bookingDate: day,
            amount: amount,
            isIncome: const Value(true),
            category: 'Dividende',
            merchant: Value(investment.name),
            description: const Value('Dividende nach Steuern'),
            sourceType: const Value('dividend'),
            sourceId: Value(investment.id),
            accountId: Value(accountId),
            // Revives a booking an earlier undo removed.
            accountApplied: const Value(false),
            createdAt: now,
            updatedAt: now,
            deletedAt: const Value(null),
          ),
        ]);
      }
      await into(dividendReceipts).insertOnConflictUpdate(
        DividendReceiptsCompanion.insert(
          id: id,
          userId: userId,
          investmentId: investment.id,
          accountId: Value(accountId),
          paymentDate: day,
          amount: Value(amount),
          ledgerEntryId: Value(portfolio ? '' : id),
          status: const Value('received'),
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
          deletedAt: const Value(null),
        ),
      );
    });
    await captureNetWorth(userId);
    _schedulePersist(userId);
  }

  /// Marks a projected dividend as not paid, so it is not asked again.
  Future<void> skipDividend({
    required String userId,
    required String investmentId,
    required DateTime paymentDate,
  }) async {
    final now = DateTime.now().toUtc();
    await into(dividendReceipts).insertOnConflictUpdate(
      DividendReceiptsCompanion.insert(
        id: dividendReceiptId(investmentId, paymentDate),
        userId: userId,
        investmentId: investmentId,
        paymentDate: paymentDate,
        status: const Value('skipped'),
        amount: const Value(0),
        ledgerEntryId: const Value(''),
        createdAt: now,
        updatedAt: now,
        deletedAt: const Value(null),
      ),
    );
    _schedulePersist(userId);
  }

  /// Takes a confirmation back, including its booking or cash.
  Future<void> undoDividendReceipt(String id, String userId) async {
    final receipt =
        await (select(dividendReceipts)..where(
              (row) =>
                  row.id.equals(id) &
                  row.userId.equals(userId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (receipt == null) return;
    await transaction(() async {
      if (receipt.status == 'received') {
        if (receipt.ledgerEntryId.isNotEmpty) {
          await deleteLedgerEntry(receipt.ledgerEntryId, userId);
        } else if (receipt.accountId.isNotEmpty) {
          await _changePortfolioCash(
            userId: userId,
            accountId: receipt.accountId,
            delta: -receipt.amount,
          );
        }
      }
      final now = DateTime.now().toUtc();
      await (update(dividendReceipts)..where((row) => row.id.equals(id))).write(
        DividendReceiptsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    });
    await captureNetWorth(userId);
    _schedulePersist(userId);
  }
}

/// One confirmation per position and payment month, the same on every device.
String dividendReceiptId(String investmentId, DateTime paymentDate) =>
    'div-$investmentId-${paymentDate.year}'
    '${paymentDate.month.toString().padLeft(2, '0')}';
