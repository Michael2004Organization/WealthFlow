import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/sale_tax.dart';

void main() {
  test('share gain without losses uses the allowance first', () {
    final tax = saleTax(
      assetType: 'Aktie',
      name: 'Beispiel AG',
      realizedGain: 1500,
      allowanceAvailable: 1000,
      priorSales: const [],
    );
    expect(tax.allowanceUsed, 1000);
    expect(tax.taxableGain, 500);
    expect(tax.taxPaid, 131.88);
  });

  test('earlier share loss offsets a later share gain', () {
    final tax = saleTax(
      assetType: 'Aktie',
      name: 'Gewinner AG',
      realizedGain: 1500,
      allowanceAvailable: 0,
      priorSales: const [
        PriorSale(assetType: 'Aktie', name: 'Verlierer AG', realizedGain: -1000),
      ],
    );
    expect(tax.lossOffset, 1000);
    expect(tax.taxableGain, 500);
    expect(tax.taxPaid, 131.88);
  });

  test('share losses do not offset fund gains, other losses do', () {
    final fromShares = saleTax(
      assetType: 'Anleihe',
      name: 'Bundesanleihe',
      realizedGain: 500,
      allowanceAvailable: 0,
      priorSales: const [
        PriorSale(assetType: 'Aktie', name: 'Verlierer AG', realizedGain: -500),
      ],
    );
    expect(fromShares.lossOffset, 0);
    expect(fromShares.taxableGain, 500);

    final fromBonds = saleTax(
      assetType: 'Aktie',
      name: 'Gewinner AG',
      realizedGain: 500,
      allowanceAvailable: 0,
      priorSales: const [
        PriorSale(assetType: 'Anleihe', name: 'Anleihe', realizedGain: -200),
      ],
    );
    expect(fromBonds.lossOffset, 200);
    expect(fromBonds.taxableGain, 300);
  });

  test('equity ETFs keep 30 percent of the gain tax-free', () {
    final tax = saleTax(
      assetType: 'ETF',
      name: 'MSCI World UCITS ETF',
      realizedGain: 1000,
      allowanceAvailable: 0,
      priorSales: const [],
    );
    expect(tax.taxableGain, closeTo(700, 0.0001));
    expect(partialExemptionRate('ETF', 'Euro Government Bond ETF'), 0);
    expect(partialExemptionRate('Fonds', 'Mischfonds Ausgewogen'), 0.15);
  });

  test('cryptocurrencies are not taxed with the flat rate', () {
    final tax = saleTax(
      assetType: 'Kryptowährung',
      name: 'Bitcoin',
      realizedGain: 5000,
      allowanceAvailable: 1000,
      priorSales: const [],
    );
    expect(tax.taxPaid, 0);
    expect(tax.allowanceUsed, 0);
  });
}
