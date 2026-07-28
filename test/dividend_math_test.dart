import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/dividend_math.dart';

void main() {
  test('all dividend projections start from the monthly per-share value', () {
    const monthlyPerShare = 2.5;
    const quantity = 4.0;

    final monthly = dividendPerMonth(monthlyPerShare, quantity);
    expect(monthly, 10);
    expect(dividendPerQuarterFromMonth(monthly), 30);
    expect(dividendPerYearFromMonth(monthly), 120);
  });
}
