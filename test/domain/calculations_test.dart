import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/src/domain/calculations.dart';

void main() {
  group('compoundInterest', () {
    test('keeps capital stable without rate and contributions', () {
      final result = compoundInterest(initialCapital: 10000, monthlyContribution: 0, annualRatePercent: 0, years: 10);
      expect(result.finalCapital, 10000);
      expect(result.profit, 0);
    });
    test('adds monthly contributions', () {
      final result = compoundInterest(initialCapital: 1000, monthlyContribution: 100, annualRatePercent: 0, years: 1);
      expect(result.finalCapital, 2200);
      expect(result.deposits, 2200);
    });
    test('rejects negative values', () => expect(() => compoundInterest(initialCapital: -1, monthlyContribution: 0, annualRatePercent: 0, years: 1), throwsArgumentError));
  });
  test('trip cost derives all periods consistently', () {
    final result = tripCosts(kilometers: 100, litersPer100Km: 5, pricePerLiter: 2, tripsPerWeek: 3);
    expect(result.perTrip, 10);
    expect(result.perWeek, 30);
    expect(result.perYear, 1560);
  });
}
