import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/dividend_math.dart';

void main() {
  test('dividend projections respect the payout frequency', () {
    const dividendPerShare = 2.5;
    const quantity = 4.0;

    final monthly = dividendPerMonth(
      dividendPerShare,
      quantity,
      'vierteljährlich',
    );
    expect(monthly, closeTo(10 / 3, 0.0001));
    expect(dividendPerQuarterFromMonth(monthly), closeTo(10, 0.0001));
    expect(dividendPerYearFromMonth(monthly), closeTo(40, 0.0001));
  });
}
