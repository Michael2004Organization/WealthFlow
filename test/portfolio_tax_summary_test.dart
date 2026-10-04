import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/database/app_database.dart';
import 'package:wealthflow/core/finance/portfolio_tax_summary.dart';

void main() {
  test('physical gains are excluded from the allowance by default', () {
    final sale = _physicalSale(gain: 500, allowanceUsed: 500, taxPaid: 0);

    final excluded = calculatePortfolioTaxYear(
      year: 2026,
      allowance: 1000,
      investments: const [],
      schedules: const [],
      sales: [sale],
    );
    final included = calculatePortfolioTaxYear(
      year: 2026,
      allowance: 1000,
      investments: const [],
      schedules: const [],
      sales: [sale],
      includePhysicalAssets: true,
    );

    expect(excluded.allowanceUsed, 0);
    expect(excluded.allowanceRemaining, 1000);
    expect(included.allowanceUsed, 500);
    expect(included.allowanceRemaining, 500);
  });

  test(
    'historical dividends use shares held on the payment date and gross amount',
    () {
      final investment = _investment();
      final purchase = InvestmentPurchase(
        id: 'purchase',
        userId: 'user',
        investmentId: investment.id,
        purchaseDate: DateTime(2026, 6, 1),
        purchasePrice: 10,
        quantity: 10,
        fees: 0,
        cashApplied: false,
        createdAt: DateTime(2026, 6, 1),
      );
      final schedules = [
        _dividend('before-purchase', DateTime(2026, 5, 15)),
        _dividend('after-purchase', DateTime(2026, 7, 15)),
      ];

      final summary = calculatePortfolioTaxYear(
        year: 2026,
        allowance: 1000,
        investments: [investment],
        purchases: [purchase],
        schedules: schedules,
        sales: const [],
        through: DateTime(2026, 8, 1),
      );

      expect(summary.allowanceUsed, 100);
      expect(summary.allowanceRemaining, 900);
      expect(summary.taxPaid, 15);
    },
  );
}

Investment _investment() => Investment(
  id: 'stock',
  userId: 'user',
  accountId: 'portfolio',
  name: 'US Stock',
  symbol: 'USS',
  isin: '',
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
  purchaseDate: DateTime(2026, 6, 1),
  purchasePrice: 10,
  quantity: 10,
  fees: 0,
  currentPrice: 12,
  annualDividend: 0,
  dividendCurrency: 'USD',
  dividendExchangeRate: 1,
  dividendWithholdingTaxRate: 15,
  dividendFrequency: 'jährlich',
  dividendStartMonth: 7,
  notes: '',
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

DividendSchedule _dividend(String id, DateTime paymentDate) => DividendSchedule(
  id: id,
  userId: 'user',
  investmentId: 'stock',
  paymentMonth: paymentDate.month,
  amountPerShare: 10,
  paymentDate: paymentDate,
  paymentYear: 2026,
  currency: 'USD',
  exchangeRate: 1,
  withholdingTaxRate: 15,
  createdAt: paymentDate,
  updatedAt: paymentDate,
);

PortfolioSale _physicalSale({
  required double gain,
  required double allowanceUsed,
  required double taxPaid,
}) => PortfolioSale(
  id: 'sale',
  userId: 'user',
  accountId: 'portfolio',
  accountCredited: true,
  sourceCurrency: 'EUR',
  exchangeRate: 1,
  physicalAssetId: 'gold',
  assetName: 'Gold',
  assetKind: 'physical',
  quantity: 10,
  unit: 'g',
  pricePerUnit: 100,
  fees: 0,
  proceeds: 1000,
  costBasis: 1000 - gain,
  realizedGain: gain,
  allowanceUsed: allowanceUsed,
  taxPaid: taxPaid,
  soldAt: DateTime(2026, 8, 1),
  createdAt: DateTime(2026, 8, 1),
);
