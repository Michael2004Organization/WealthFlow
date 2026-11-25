import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';
import 'package:wealthflow_core/finance/withholding_tax_defaults.dart';
import 'package:wealthflow/features/finance/dividend_tax_breakdown.dart';

/// Gross to net of dividends, checked by hand against German rules:
/// 25 % KapESt + 5.5 % Soli, foreign tax credited up to the treaty rate,
/// 30 % partial exemption for equity funds, allowance before tax.
void main() {
  group('Brutto bis Netto', () {
    test('Swiss shares: 35 % withheld, only 15 % credited', () {
      final tax = calculateInvestmentDividendTax(
        _investment(country: 'Schweiz', currency: 'CHF'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 35,
        allowanceRemaining: 0,
      );
      expect(tax.withholdingTax, 35);
      expect(tax.creditableWithholdingTax, 15);
      expect(tax.germanCapitalTax, 10);
      expect(tax.solidaritySurcharge, .55);
      expect(tax.net, 54.45);
      expect(tax.nonCreditableWithholdingTax, 20);
      expect(dividendTaxHint(tax, 'Schweiz', 'EUR'), contains('Schweiz'));
    });

    test('US shares: 15 % withheld and fully credited', () {
      final tax = calculateInvestmentDividendTax(
        _investment(),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 15,
        allowanceRemaining: 0,
      );
      expect(tax.germanCapitalTax, 10);
      expect(tax.net, 74.45);
      expect(tax.totalTax, 25.55);
      expect(tax.nonCreditableWithholdingTax, 0);
    });

    test('Irish shares: 25 % withheld, none credited', () {
      final tax = calculateInvestmentDividendTax(
        _investment(country: 'Irland', currency: 'EUR'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 25,
        allowanceRemaining: 0,
      );
      expect(tax.creditableWithholdingTax, 0);
      expect(tax.germanCapitalTax, 25);
      expect(tax.net, 100 - 25 - 25 - 1.38);
    });

    test('equity ETF: no foreign tax, 30 % partial exemption', () {
      final tax = calculateInvestmentDividendTax(
        _investment(type: 'ETF', name: 'MSCI World', country: 'Irland'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 25,
        allowanceRemaining: 0,
      );
      expect(tax.withholdingTax, 0);
      expect(tax.partialExemption, 30);
      expect(tax.taxable, 70);
      expect(tax.germanCapitalTax, 17.5);
      expect(tax.solidaritySurcharge, .96);
      expect(tax.net, 81.54);
    });

    test('equity ETF: allowance only covers the taxable 70 %', () {
      final tax = calculateInvestmentDividendTax(
        _investment(type: 'ETF', name: 'MSCI World'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 0,
        allowanceRemaining: 30,
      );
      expect(tax.allowanceUsed, 30);
      expect(tax.allowanceRemaining, 0);
      expect(tax.taxable, 40);
      expect(tax.germanCapitalTax, 10);
      expect(tax.net, 89.45);
    });

    test('bond ETF has no partial exemption', () {
      final tax = calculateInvestmentDividendTax(
        _investment(type: 'ETF', name: 'Euro Government Bond'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 0,
        allowanceRemaining: 0,
      );
      expect(tax.partialExemption, 0);
      expect(tax.germanCapitalTax, 25);
    });

    test('allowance used up mid payout: credit limited to German tax', () {
      final tax = calculateInvestmentDividendTax(
        _investment(),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 15,
        allowanceRemaining: 60,
      );
      expect(tax.taxable, 40);
      expect(tax.creditableWithholdingTax, 10);
      expect(tax.germanCapitalTax, 0);
      expect(tax.net, 85);
      expect(tax.nonCreditableWithholdingTax, 5);
      expect(dividendTaxHint(tax, 'USA', 'EUR'), contains('Quellensteuertopf'));
    });

    test('German shares: only domestic tax', () {
      final tax = calculateInvestmentDividendTax(
        _investment(country: 'Deutschland', currency: 'EUR'),
        grossAmount: 100,
        exchangeRate: 1,
        withholdingTaxRate: 0,
        allowanceRemaining: 0,
      );
      expect(tax.germanCapitalTax, 25);
      expect(tax.solidaritySurcharge, 1.38);
      expect(tax.net, 73.62);
    });

    test('unknown country credits at most 15 %', () {
      expect(creditableTaxRateFor('Atlantis', 30), 15);
      expect(creditableTaxRateFor('Atlantis', 10), 10);
      expect(creditableTaxRateFor('USA', 30), 15);
    });
  });

  test('sales earlier in the year use up the allowance of dividends', () {
    final investment = _investment(country: 'Deutschland', currency: 'EUR');
    final schedule = DividendSchedule(
      id: 'march',
      userId: 'user',
      investmentId: investment.id,
      paymentMonth: 3,
      amountPerShare: 10,
      paymentDate: DateTime(2026, 3, 10),
      paymentYear: 2026,
      currency: 'EUR',
      exchangeRate: 1,
      withholdingTaxRate: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    List<ProjectedDividend> project(DateTime soldAt) => buildDividendProjection(
      [investment],
      [schedule],
      1000,
      2026,
      const [],
      [_sale(soldAt)],
      const {'portfolio': 'EUR'},
    );

    final afterSale = project(DateTime(2026, 2, 1)).single;
    expect(afterSale.tax.allowanceUsed, 0);
    expect(afterSale.tax.germanCapitalTax, 25);

    final beforeSale = project(DateTime(2026, 4, 1)).single;
    expect(beforeSale.tax.allowanceUsed, 100);
    expect(beforeSale.tax.net, 100);
  });
}

Investment _investment({
  String type = 'Aktie',
  String name = 'Stock',
  String country = 'USA',
  String currency = 'USD',
}) => Investment(
  id: 'stock',
  userId: 'user',
  accountId: 'portfolio',
  name: name,
  symbol: '',
  isin: '',
  wkn: '',
  assetType: type,
  instrumentSubtype: '',
  positionDirection: '',
  issuer: '',
  underlying: '',
  instrumentCurrency: currency,
  nominalValue: 0,
  couponRate: 0,
  strikePrice: 0,
  knockOutBarrier: 0,
  leverage: 0,
  subscriptionRatio: 0,
  broker: '',
  country: country,
  sector: '',
  purchaseDate: DateTime(2025),
  purchasePrice: 10,
  quantity: 10,
  fees: 0,
  currentPrice: 12,
  annualDividend: 0,
  dividendCurrency: currency,
  dividendExchangeRate: 1,
  dividendWithholdingTaxRate: 0,
  dividendFrequency: 'jährlich',
  dividendStartMonth: 3,
  notes: '',
  createdAt: DateTime(2025),
  updatedAt: DateTime(2025),
);

PortfolioSale _sale(DateTime soldAt) => PortfolioSale(
  id: 'sale',
  userId: 'user',
  accountId: 'portfolio',
  accountCredited: true,
  sourceCurrency: 'EUR',
  exchangeRate: 1,
  investmentId: 'other',
  assetName: 'Other',
  assetKind: 'investment',
  quantity: 1,
  unit: '',
  pricePerUnit: 2000,
  fees: 0,
  proceeds: 2000,
  costBasis: 1000,
  realizedGain: 1000,
  allowanceUsed: 1000,
  taxPaid: 0,
  soldAt: soldAt,
  createdAt: soldAt,
);
