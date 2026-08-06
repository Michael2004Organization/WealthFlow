import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/budget_period.dart';

void main() {
  group('budget payment dates', () {
    test('month start moves weekends to the first weekday', () {
      expect(firstWorkingDay(DateTime(2026, 8)), DateTime(2026, 8, 3));
    });

    test('month end is the penultimate weekday of the previous month', () {
      expect(
        paymentDateForBudgetMonth(
          budgetMonth: DateTime(2026, 8),
          timing: 'end',
          selectedDay: 1,
        ),
        DateTime(2026, 7, 30),
      );
    });

    test('middle always uses the fifteenth', () {
      expect(
        paymentDateForBudgetMonth(
          budgetMonth: DateTime(2026, 8),
          timing: 'middle',
          selectedDay: 2,
        ),
        DateTime(2026, 8, 15),
      );
    });

    test('explicit budget month overrides the booking month', () {
      expect(
        budgetMonthOf(DateTime(2026, 7, 30), DateTime(2026, 8)),
        DateTime(2026, 8),
      );
    });

    test('advance payment becomes effective in its budget month', () {
      expect(
        ledgerEffectiveDate(DateTime(2026, 7, 31), DateTime(2026, 8)),
        DateTime(2026, 8),
      );
    });

    test('same-month payment keeps its actual booking day', () {
      expect(
        ledgerEffectiveDate(DateTime(2026, 8, 15), DateTime(2026, 8)),
        DateTime(2026, 8, 15),
      );
    });
  });
}
