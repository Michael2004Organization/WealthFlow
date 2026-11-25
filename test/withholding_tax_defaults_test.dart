import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/currencies.dart';
import 'package:wealthflow_core/finance/withholding_tax_defaults.dart';

void main() {
  test('finds countries by name and alias, ignoring case', () {
    expect(withholdingTaxDefaultFor('USA')!.withheld, 15);
    expect(withholdingTaxDefaultFor(' united states ')!.country, 'USA');
    expect(withholdingTaxDefaultFor('großbritannien')!.withheld, 0);
    expect(withholdingTaxDefaultFor('Atlantis'), isNull);
    expect(withholdingTaxDefaultFor(''), isNull);
  });

  test('values follow the BZSt overview for common markets', () {
    final ch = withholdingTaxDefaultFor('Schweiz')!;
    expect((ch.withheld, ch.creditable, ch.reclaimable), (35, 15, 20));
    final fr = withholdingTaxDefaultFor('Frankreich')!;
    expect((fr.withheld, fr.creditable), (12.8, 12.8));
    expect(withholdingTaxDefaultFor('Irland')!.creditable, 0);
  });

  test('table is consistent', () {
    final names = <String>{};
    for (final entry in withholdingTaxDefaults) {
      expect(names.add(normalizeCountry(entry.country)), isTrue);
      for (final alias in entry.aliases) {
        expect(alias, normalizeCountry(alias), reason: entry.country);
        expect(names.add(alias), isTrue, reason: alias);
      }
      expect(entry.withheld, inInclusiveRange(0, 100));
      expect(entry.creditable, lessThanOrEqualTo(entry.withheld));
      expect(
        isSupportedCurrency(entry.currency),
        isTrue,
        reason: entry.country,
      );
    }
  });

  test('a stored rule wins over the standard value', () {
    final stored = CountryTaxRate(
      country: 'usa',
      withholdingTaxRate: 30,
      currency: 'USD',
      exchangeRate: 1,
      updatedAt: DateTime.utc(2026),
    );
    expect(withholdingTaxRateFor('USA', [stored]), 30);
    expect(withholdingTaxRateFor('USA', const []), 15);
    expect(withholdingTaxRateFor('Atlantis', const []), 0);
  });
}
