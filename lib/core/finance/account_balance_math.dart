import '../database/app_database.dart';
import 'budget_period.dart';

double accountBalanceAt({
  required Account account,
  required DateTime date,
  required List<AccountBalanceHistory> histories,
  required List<LedgerEntry> entries,
  required List<Investment> investments,
  required List<InvestmentPurchase> purchases,
  required List<PortfolioSale> sales,
}) {
  final allAccountHistories = histories
      .where((row) => row.accountId == account.id && row.deletedAt == null)
      .toList();
  final accountHistories =
      allAccountHistories
          .where(
            (row) =>
                row.accountId == account.id &&
                row.deletedAt == null &&
                !row.effectiveAt.isAfter(date),
          )
          .toList()
        ..sort((a, b) => a.effectiveAt.compareTo(b.effectiveAt));
  final base = accountHistories.lastOrNull;
  final now = DateTime.now();
  final investmentIds = investments
      .where((item) => item.accountId == account.id)
      .map((item) => item.id)
      .toSet();

  if (base != null) {
    var balance = base.balance;
    for (final entry in entries.where((entry) {
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return entry.accountId == account.id &&
          effective.isAfter(base.effectiveAt) &&
          !effective.isAfter(date);
    })) {
      balance += entry.isIncome ? entry.amount : -entry.amount;
    }
    for (final sale in sales.where((sale) {
      final creditedAccount =
          sale.destinationAccountId ??
          (sale.accountCredited ? sale.accountId : null);
      return creditedAccount == account.id &&
          sale.soldAt.isAfter(base.effectiveAt) &&
          !sale.soldAt.isAfter(date);
    })) {
      balance += sale.proceeds;
    }
    for (final purchase in purchases.where(
      (purchase) =>
          purchase.cashApplied &&
          investmentIds.contains(purchase.investmentId) &&
          purchase.purchaseDate.isAfter(base.effectiveAt) &&
          !purchase.purchaseDate.isAfter(date),
    )) {
      balance -= purchase.purchasePrice * purchase.quantity + purchase.fees;
    }
    return balance;
  }

  if (allAccountHistories.isNotEmpty || date.isBefore(account.createdAt)) {
    return 0;
  }

  var balance = account.balance;
  if (date.isBefore(now)) {
    for (final entry in entries.where((entry) {
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return entry.accountId == account.id &&
          entry.accountApplied &&
          effective.isAfter(date);
    })) {
      balance -= entry.isIncome ? entry.amount : -entry.amount;
    }
    for (final sale in sales.where((sale) {
      final creditedAccount =
          sale.destinationAccountId ??
          (sale.accountCredited ? sale.accountId : null);
      return creditedAccount == account.id && sale.soldAt.isAfter(date);
    })) {
      balance -= sale.proceeds;
    }
    for (final purchase in purchases.where(
      (purchase) =>
          purchase.cashApplied &&
          investmentIds.contains(purchase.investmentId) &&
          purchase.purchaseDate.isAfter(date),
    )) {
      balance += purchase.purchasePrice * purchase.quantity + purchase.fees;
    }
  } else {
    for (final entry in entries.where((entry) {
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return entry.accountId == account.id &&
          !entry.accountApplied &&
          effective.isAfter(now) &&
          !effective.isAfter(date);
    })) {
      balance += entry.isIncome ? entry.amount : -entry.amount;
    }
  }
  return balance;
}
