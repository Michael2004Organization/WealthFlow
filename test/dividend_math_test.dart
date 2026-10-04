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

  test('US dividend credits withholding tax against German tax per payout', () {
    final result = calculateGermanDividendTax(
      grossAmount: 100,
      exchangeRate: 1,
      withholdingTaxRate: 15,
      allowanceRemaining: 0,
    );

    expect(result.withholdingTax, 15);
    expect(result.creditableWithholdingTax, 15);
    expect(result.germanCapitalTax, 10);
    expect(result.solidaritySurcharge, .55);
    expect(result.net, 74.45);
  });

  test('allowance is consumed before German dividend tax', () {
    final result = calculateGermanDividendTax(
      grossAmount: 100,
      exchangeRate: 1,
      withholdingTaxRate: 0,
      allowanceRemaining: 60,
    );

    expect(result.allowanceUsed, 60);
    expect(result.allowanceRemaining, 0);
    expect(result.germanCapitalTax, 10);
    expect(result.solidaritySurcharge, .55);
    expect(result.net, 89.45);
  });

  test('foreign tax remains payable while allowance prevents German tax', () {
    final result = calculateGermanDividendTax(
      grossAmount: 100,
      exchangeRate: 1,
      withholdingTaxRate: 15,
      allowanceRemaining: 1000,
    );

    expect(result.withholdingTax, 15);
    expect(result.germanCapitalTax, 0);
    expect(result.solidaritySurcharge, 0);
    expect(result.net, 85);
    expect(result.allowanceUsed, 100);
    expect(result.allowanceRemaining, 900);
  });

  test('US withholding tax is deducted in USD before conversion', () {
    final result = calculateGermanDividendTax(
      grossAmount: 54.822676 * 0.271,
      exchangeRate: 1 / 1.1551,
      withholdingTaxRate: 15,
      allowanceRemaining: 1000,
    );

    expect(result.grossSource, 14.86);
    expect(result.withholdingTaxSource, 2.23);
    expect(result.gross - result.withholdingTax, closeTo(10.93, 0.001));
    expect(result.net, 10.93);
  });

  test('conversion happens after withholding tax to avoid cent drift', () {
    // 12.63 USD x 0.8645 = 10.92 EUR. Converting gross first would round
    // 12.84 EUR - 1.93 EUR = 10.91 EUR.
    final result = calculateGermanDividendTax(
      grossAmount: 54.822676 * 0.271,
      exchangeRate: 0.8645,
      withholdingTaxRate: 15,
      allowanceRemaining: 1000,
    );

    expect(result.net, 10.92);
  });

  test('optional church tax is included in the net dividend', () {
    final result = calculateGermanDividendTax(
      grossAmount: 100,
      exchangeRate: 1,
      withholdingTaxRate: 0,
      allowanceRemaining: 0,
      churchTaxRate: 9,
    );

    expect(result.germanCapitalTax, 25);
    expect(result.churchTax, 2.25);
    expect(result.net, 71.37);
  });
}
