import '../database/app_database.dart';
import 'budget_period.dart';

/// Accounts that can carry household bookings: explicitly marked household
/// accounts, plus unassigned ones that hold no investment or physical asset.
List<Account> householdAccounts(
  Iterable<Account> accounts, {
  required List<Investment> investments,
  required List<PhysicalAsset> physicalAssets,
}) => accounts.where((account) {
  if (account.usageType == 'household') return true;
  if (account.usageType != 'unassigned') return false;
  return !investments.any((item) => item.accountId == account.id) &&
      !physicalAssets.any((item) => item.accountId == account.id);
}).toList();

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
    // A balance is "valid from" a day: it is the opening balance of that
    // day, so bookings, sales and purchases on the same day count on top.
    final baseDay = DateTime(
      base.effectiveAt.year,
      base.effectiveAt.month,
      base.effectiveAt.day,
    );
    var balance = base.balance;
    for (final entry in entries.where((entry) {
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return entry.accountId == account.id &&
          !effective.isBefore(baseDay) &&
          !effective.isAfter(date);
    })) {
      balance += entry.isIncome ? entry.amount : -entry.amount;
    }
    for (final sale in sales.where((sale) {
      final creditedAccount =
          sale.destinationAccountId ??
          (sale.accountCredited ? sale.accountId : null);
      return creditedAccount == account.id &&
          !sale.soldAt.isBefore(baseDay) &&
          !sale.soldAt.isAfter(date);
    })) {
      balance += sale.proceeds;
    }
    for (final purchase in purchases.where(
      (purchase) =>
          purchase.cashApplied &&
          investmentIds.contains(purchase.investmentId) &&
          !purchase.purchaseDate.isBefore(baseDay) &&
          !purchase.purchaseDate.isAfter(date),
    )) {
      balance -= purchase.cashAmount;
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
      balance += purchase.cashAmount;
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
