import 'category_budget.dart';

/// "Wie viel kann ich diesen Monat noch ausgeben?"
///
/// The balance of the household accounts today, minus what is already
/// planned until the end of the month (future-dated bookings, standing
/// orders) and minus what the budgets still reserve.
class FreeToSpend {
  const FreeToSpend({
    required this.month,
    required this.balance,
    required this.planned,
    required this.reserved,
    required this.daysLeft,
    required this.monthProgress,
    required this.budgetUse,
  });

  /// First day of the month the values are for.
  final DateTime month;

  /// Last day of [month].
  int get lastDay => DateTime(month.year, month.month + 1, 0).day;

  /// Household account balance today.
  final double balance;

  /// Expenses still to come this month (positive).
  final double planned;

  /// Rest of all budgets that is not spent yet (positive).
  final double reserved;

  /// Days left including today.
  final int daysLeft;

  /// Share of the month that has passed, 0 to 1.
  final double monthProgress;

  /// Spent share of all budgets, 0 to 1 (or more when overspent); null
  /// without budgets.
  final double? budgetUse;

  double get free => balance - planned - reserved;

  /// What can be spent per remaining day; never negative.
  double get perDay => free <= 0 ? 0 : free / daysLeft;
}

FreeToSpend calculateFreeToSpend({
  required double balance,
  required double plannedExpenses,
  required Iterable<BudgetProgress> budgets,
  required DateTime today,
}) {
  final day = DateTime(today.year, today.month, today.day);
  final lastDay = DateTime(today.year, today.month + 1, 0).day;
  var reserved = 0.0;
  var available = 0.0;
  var spent = 0.0;
  for (final progress in budgets) {
    if (progress.left > 0) reserved += progress.left;
    available += progress.available;
    spent += progress.spent;
  }
  return FreeToSpend(
    month: DateTime(today.year, today.month),
    balance: balance,
    planned: plannedExpenses < 0 ? 0 : plannedExpenses,
    reserved: reserved,
    daysLeft: lastDay - day.day + 1,
    monthProgress: (day.day - 1) / lastDay,
    budgetUse: available <= 0 ? null : spent / available,
  );
}
