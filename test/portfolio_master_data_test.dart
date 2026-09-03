import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow/core/finance/currencies.dart';
import 'package:wealthflow/core/finance/portfolio_master_data.dart';

void main() {
  test('country defaults provide meaningful ISO currencies', () {
    expect(defaultCurrencyForCountry('USA'), 'USD');
    expect(defaultCurrencyForCountry('Schweiz'), 'CHF');
    expect(defaultCurrencyForCountry('Deutschland'), 'EUR');
    expect(defaultCurrencyForCountry('Unbekannt', fallback: 'GBP'), 'GBP');
    expect(
      supportedIsoCurrencies.toSet().length,
      supportedIsoCurrencies.length,
    );
  });

  test('portfolio identity is class-specific and normalized', () {
    final stock = portfolioMasterIdentity(
      assetType: 'Aktie',
      name: 'Example AG',
      isin: ' de0001234567 ',
    );
    final duplicate = portfolioMasterIdentity(
      assetType: 'Aktie',
      name: 'Anderer Name',
      isin: 'DE0001234567',
    );
    final fund = portfolioMasterIdentity(
      assetType: 'Fonds',
      name: 'Example AG',
      isin: 'DE0001234567',
    );

    expect(stock, duplicate);
    expect(stock, isNot(fund));
  });

  test('crypto requires a symbol but never an ISIN', () {
    expect(
      portfolioMasterValidationError(
        assetType: 'Kryptowährung',
        name: 'Bitcoin',
        country: 'USA',
        symbol: 'BTC',
      ),
      isNull,
    );
    expect(
      portfolioMasterValidationError(
        assetType: 'Kryptowährung',
        name: 'Bitcoin',
        country: 'USA',
      ),
      contains('Symbol'),
    );
  });
}
