part of '../app_database.dart';

/// Monatsbudgets je Kategorie.
extension BudgetQueries on AppDatabase {
  Stream<List<CategoryBudget>> watchCategoryBudgets(String userId) =>
      (select(categoryBudgets)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.category)]))
          .watch();

  /// Creates or changes a budget; one budget per category.
  Future<void> saveCategoryBudget(CategoryBudgetInput input) async {
    if (input.monthlyLimit <= 0) {
      throw ArgumentError('Das Budget muss größer als 0 sein.');
    }
    final category = input.category.trim();
    if (category.isEmpty) {
      throw ArgumentError('Bitte eine Kategorie wählen.');
    }
    final now = DateTime.now().toUtc();
    final sameCategory =
        await (select(categoryBudgets)..where(
              (row) =>
                  row.userId.equals(input.userId) &
                  row.category.equals(category) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final existing = await (select(
      categoryBudgets,
    )..where((row) => row.id.equals(input.id))).getSingleOrNull();
    await transaction(() async {
      // A second budget for the same category replaces the first.
      for (final other in sameCategory.where((row) => row.id != input.id)) {
        await (update(
          categoryBudgets,
        )..where((row) => row.id.equals(other.id))).write(
          CategoryBudgetsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
      await into(categoryBudgets).insertOnConflictUpdate(
        CategoryBudgetsCompanion.insert(
          id: input.id,
          userId: input.userId,
          category: category,
          monthlyLimit: input.monthlyLimit,
          carryOver: Value(input.carryOver),
          startMonth: existing?.startMonth ?? input.startMonth,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    });
    _schedulePersist(input.userId);
  }

  Future<void> deleteCategoryBudget(String id, String userId) async {
    final now = DateTime.now().toUtc();
    await (update(
      categoryBudgets,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      CategoryBudgetsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    _schedulePersist(userId);
  }
}

/// What the budget editor hands to [BudgetQueries.saveCategoryBudget].
class CategoryBudgetInput {
  const CategoryBudgetInput({
    required this.id,
    required this.userId,
    required this.category,
    required this.monthlyLimit,
    required this.carryOver,
    required this.startMonth,
  });

  final String id;
  final String userId;
  final String category;
  final double monthlyLimit;
  final bool carryOver;
  final DateTime startMonth;
}
