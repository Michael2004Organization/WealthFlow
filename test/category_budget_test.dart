import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/category_budget.dart';

final _created = DateTime(2026, 1, 1);

CategoryBudget _budget({
  String category = 'Lebensmittel',
  double limit = 450,
  bool carryOver = false,
  DateTime? start,
}) => CategoryBudget(
  id: category,
  userId: 'user',
  category: category,
  monthlyLimit: limit,
  carryOver: carryOver,
  startMonth: start ?? DateTime(2026, 8),
  createdAt: _created,
  updatedAt: _created,
);

LedgerEntry _expense(
  DateTime date,
  double amount, {
  String category = 'Lebensmittel',
  String sourceType = 'manual',
  bool income = false,
  DateTime? budgetMonth,
}) => LedgerEntry(
  id: '$date-$amount-$category',
  userId: 'user',
  bookingDate: date,
  budgetMonth: budgetMonth,
  amount: amount,
  isIncome: income,
  category: category,
  merchant: '',
  description: '',
  paymentMethod: '',
  recurrenceId: '',
  sourceType: sourceType,
  sourceId: '',
  vehicleId: '',
  accountId: 'giro',
  accountApplied: true,
  createdAt: date,
  updatedAt: date,
);

void main() {
  test('zählt nur Ausgaben der Kategorie im Budgetmonat', () {
    final progress = buildBudgetProgress(
      [_budget()],
      [
        _expense(DateTime(2026, 10, 3), 112),
        _expense(DateTime(2026, 10, 20), 100),
        // Paid in September, counted for October.
        _expense(DateTime(2026, 9, 30), 50, budgetMonth: DateTime(2026, 10)),
        _expense(DateTime(2026, 10, 4), 80, category: 'Freizeit'),
        _expense(DateTime(2026, 10, 5), 300, sourceType: 'transfer'),
        _expense(DateTime(2026, 10, 6), 40, income: true),
        _expense(DateTime(2026, 11, 1), 70),
      ],
      DateTime(2026, 10),
    ).single;

    expect(progress.spent, 262);
    expect(progress.left, 188);
    expect(progress.state, BudgetState.ok);
  });

  test('orange ab 80 Prozent, rot darüber', () {
    BudgetState stateFor(double spent) => buildBudgetProgress(
      [_budget(limit: 100)],
      [_expense(DateTime(2026, 10, 3), spent)],
      DateTime(2026, 10),
    ).single.state;

    expect(stateFor(79), BudgetState.ok);
    expect(stateFor(80), BudgetState.warning);
    expect(stateFor(100), BudgetState.warning);
    expect(stateFor(100.5), BudgetState.over);
  });

  test('überträgt nur den Rest, eine Überschreitung nicht', () {
    final entries = [
      _expense(DateTime(2026, 8, 10), 70), // 30 left
      _expense(DateTime(2026, 9, 10), 150), // over: nothing carried
      _expense(DateTime(2026, 10, 10), 60), // 40 left
    ];
    BudgetProgress inMonth(int month, {bool carryOver = true}) =>
        buildBudgetProgress(
          [_budget(limit: 100, carryOver: carryOver)],
          entries,
          DateTime(2026, month),
        ).single;

    expect(inMonth(9).carried, 30);
    expect(inMonth(9).available, 130);
    expect(inMonth(10).carried, 0);
    expect(inMonth(11).carried, 40);
    expect(inMonth(11, carryOver: false).carried, 0);
  });

  test('vor dem Start gilt das Budget nicht', () {
    expect(
      buildBudgetProgress([_budget()], const [], DateTime(2026, 7)),
      isEmpty,
    );
  });

  test('ein zweites Budget für dieselbe Kategorie ersetzt das erste', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.createUser(
      UsersCompanion.insert(
        id: 'user',
        email: 'user@example.test',
        displayName: 'user',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        createdAt: _created,
        updatedAt: _created,
      ),
    );
    CategoryBudgetInput input(String id, double limit) => CategoryBudgetInput(
      id: id,
      userId: 'user',
      category: ' Lebensmittel ',
      monthlyLimit: limit,
      carryOver: false,
      startMonth: DateTime(2026, 10),
    );

    await database.saveCategoryBudget(input('a', 400));
    await database.saveCategoryBudget(input('b', 450));

    final budgets = await database.watchCategoryBudgets('user').first;
    expect(budgets.map((budget) => (budget.id, budget.category)), [
      ('b', 'Lebensmittel'),
    ]);
    expect(
      () => database.saveCategoryBudget(input('c', 0)),
      throwsArgumentError,
    );

    final exported = await database.exportUserData('user');
    expect(exported['categoryBudgets'], hasLength(2));
    expect(
      await (database.select(
        database.categoryBudgets,
      )..where((row) => row.deletedAt.isNotNull())).get(),
      hasLength(1),
    );
  });
}
