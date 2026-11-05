import '../database/app_database.dart';
import 'budget_period.dart';

enum BudgetState { ok, warning, over }

/// Where one category budget stands in a month.
class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.carried,
  });

  final CategoryBudget budget;

  /// Expenses of the category that count for the month.
  final double spent;

  /// Unused rest of earlier months, when the budget carries it over.
  final double carried;

  double get available => budget.monthlyLimit + carried;
  double get left => available - spent;
  double get ratio => available <= 0 ? 1 : spent / available;

  /// Orange from 80 %, red once the budget is used up.
  BudgetState get state => ratio > 1
      ? BudgetState.over
      : ratio >= .8
      ? BudgetState.warning
      : BudgetState.ok;
}

/// Expenses per category and budget month, without transfers and savings.
Map<DateTime, Map<String, double>> expensesByMonthAndCategory(
  Iterable<LedgerEntry> entries,
) {
  final result = <DateTime, Map<String, double>>{};
  for (final entry in entries) {
    if (entry.isIncome ||
        entry.deletedAt != null ||
        entry.sourceType == 'transfer' ||
        entry.sourceType == 'saving') {
      continue;
    }
    final month = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
    final categories = result.putIfAbsent(month, () => {});
    categories.update(
      entry.category,
      (sum) => sum + entry.amount,
      ifAbsent: () => entry.amount,
    );
  }
  return result;
}

/// Progress of every budget in [month], fullest first.
List<BudgetProgress> buildBudgetProgress(
  List<CategoryBudget> budgets,
  Iterable<LedgerEntry> entries,
  DateTime month,
) {
  final target = DateTime(month.year, month.month);
  final expenses = expensesByMonthAndCategory(entries);
  double spentIn(DateTime month, String category) =>
      expenses[month]?[category] ?? 0;
  final result = [
    for (final budget in budgets)
      if (!DateTime(
        budget.startMonth.year,
        budget.startMonth.month,
      ).isAfter(target))
        BudgetProgress(
          budget: budget,
          spent: spentIn(target, budget.category),
          carried: budget.carryOver ? _carried(budget, target, spentIn) : 0,
        ),
  ]..sort((a, b) => b.ratio.compareTo(a.ratio));
  return result;
}

/// Only an unused rest moves on; an overrun does not shrink later months.
double _carried(
  CategoryBudget budget,
  DateTime target,
  double Function(DateTime month, String category) spentIn,
) {
  var month = DateTime(budget.startMonth.year, budget.startMonth.month);
  var carried = 0.0;
  // 600 months are 50 years; a guard against a broken start date.
  for (var guard = 0; guard < 600 && month.isBefore(target); guard++) {
    final rest =
        budget.monthlyLimit + carried - spentIn(month, budget.category);
    carried = rest > 0 ? rest : 0;
    month = DateTime(month.year, month.month + 1);
  }
  return carried;
}
