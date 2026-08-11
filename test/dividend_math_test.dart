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

  test('payout months follow the configured rhythm start', () {
    expect(dividendPaymentMonths('vierteljährlich', 2), [2, 5, 8, 11]);
    expect(dividendPaymentMonths('halbjährlich', 10), [4, 10]);
    expect(dividendPaymentMonths('jährlich', 7), [7]);
  });

  test('foreign dividend is converted after withholding tax', () {
    final net = netDividendInBaseCurrency(
      grossAmount: 1,
      exchangeRate: 0.92,
      withholdingTaxRate: 15,
    );
    expect(net, closeTo(0.782, 0.0001));
  });
}
