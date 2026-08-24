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
}

PortfolioSale _physicalSale({
  required double gain,
  required double allowanceUsed,
  required double taxPaid,
}) => PortfolioSale(
  id: 'sale',
  userId: 'user',
  accountId: 'portfolio',
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
