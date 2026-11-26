import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/currency_conversion.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';
import 'package:wealthflow_core/finance/exchange_rate_defaults.dart';

/// Realty Income, as on the user's statement: 14,90 USD gross, 15 % US
/// withholding = 2,24 USD, 12,66 USD converted = 11,43 EUR paid out while
/// the saver allowance covers the German tax.
void main() {
  test('cents round half up like the bank (2,235 → 2,24)', () {
    expect(roundCents(2.235), 2.24);
    expect(roundCents(14.90 * 15 / 100), 2.24);
    expect(roundCents(-2.235), -2.24);
    expect(roundCents(1.004), 1.0);
  });

  test('Realty Income statement: 14,90 USD → 11,43 EUR', () {
    final tax = calculateGermanDividendTax(
      grossAmount: 14.90,
      exchangeRate: 1 / 1.1076, // rate on the payment day
      withholdingTaxRate: 15,
      allowanceRemaining: 1000,
    );
    expect(tax.grossSource, 14.90);
    expect(tax.withholdingTaxSource, 2.24);
    expect(tax.grossSource - tax.withholdingTaxSource, closeTo(12.66, 1e-9));
    expect(tax.germanCapitalTax, 0);
    expect(tax.net, 11.43);
  });

  test('54,86 shares × 0,2715 USD also give 12,66 USD after tax', () {
    final tax = calculateGermanDividendTax(
      grossAmount: 54.86 * 0.2715,
      exchangeRate: 1 / 1.1076,
      withholdingTaxRate: 15,
      allowanceRemaining: 1000,
    );
    expect(tax.grossSource, 14.89);
    expect(tax.grossSource - tax.withholdingTaxSource, closeTo(12.66, 1e-9));
    expect(tax.net, 11.43);
  });

  group('without a configured USD rate', () {
    test('the ECB average is used instead of 1:1', () {
      final converter = CurrencyConverter('EUR', const {});
      expect(converter.rateOf('USD'), closeTo(1 / 1.1094, 1e-9));
      // A stored rate of 1 between USD and EUR is the column default.
      expect(converter.dividendRate(1, 'USD', 'EUR'), closeTo(.9014, 1e-4));
      // A rate someone really entered wins.
      expect(converter.dividendRate(.9028, 'USD', 'EUR'), .9028);
      expect(converter.dividendRate(1, 'EUR', 'EUR'), 1);
    });

    test('projection pays about 11,41 EUR instead of 12,66', () {
      final projection = buildDividendProjection(
        [_realtyIncome],
        const [],
        1000,
        2026,
        const [],
        const [],
        const {'depot': 'EUR'},
      );
      final payment = projection.first;
      expect(payment.tax.grossSource, 14.89);
      expect(payment.tax.withholdingTaxSource, 2.23);
      expect(payment.tax.net, closeTo(12.66 / 1.1094, .01));
      expect(payment.tax.net, isNot(12.66));
    });

    test('a configured country rate wins over the average', () {
      final converter = CurrencyConverter('EUR', const {'USD': 1 / 1.1076});
      final payment = buildDividendProjection(
        [_realtyIncome],
        const [],
        1000,
        2026,
        const [],
        const [],
        const {'depot': 'EUR'},
        converter: converter,
      ).first;
      expect(payment.tax.net, 11.43);
    });
  });

  test('every country currency of the defaults has a rate or is EUR', () {
    expect(defaultExchangeRate('CHF', 'EUR'), closeTo(1 / .920525, 1e-9));
    expect(defaultExchangeRate('USD', 'CHF'), closeTo(.920525 / 1.1094, 1e-9));
    expect(defaultExchangeRate('TWD', 'EUR'), isNull);
  });
}

final _realtyIncome = Investment(
  id: 'o',
  userId: 'user',
  accountId: 'depot',
  name: 'Realty Income',
  symbol: 'O',
  isin: 'US7561091049',
  wkn: '',
  assetType: 'Aktie',
  instrumentSubtype: '',
  positionDirection: '',
  issuer: '',
  underlying: '',
  instrumentCurrency: 'USD',
  nominalValue: 0,
  couponRate: 0,
  strikePrice: 0,
  knockOutBarrier: 0,
  leverage: 0,
  subscriptionRatio: 0,
  broker: '',
  country: 'USA',
  sector: '',
  purchaseDate: DateTime(2025),
  purchasePrice: 50,
  quantity: 54.86,
  fees: 0,
  currentPrice: 55,
  annualDividend: 0.2715,
  dividendCurrency: 'USD',
  // Never set: still the column default.
  dividendExchangeRate: 1,
  dividendWithholdingTaxRate: 15,
  dividendFrequency: 'monatlich',
  dividendStartMonth: 1,
  notes: '',
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);
