import '../database/app_database.dart';
import 'currencies.dart';

/// Withholding tax for [country]: the stored rule if there is one, else the
/// standard value, else 0.
double withholdingTaxRateFor(String? country, Iterable<CountryTaxRate> rates) {
  final normalized = normalizeCountry(country ?? '');
  final stored = rates
      .where((rate) => normalizeCountry(rate.country) == normalized)
      .firstOrNull;
  return stored?.withholdingTaxRate ??
      withholdingTaxDefaultFor(country)?.withheld ??
      0;
}

/// Standard withholding tax on dividends for a private investor resident in
/// Germany (Streubesitz), as a starting value for the country tax rules.
///
/// Source: Bundeszentralamt für Steuern, "Anrechenbarkeit der Quellensteuer
/// auf Dividenden und Zinsen", Stand 1. Januar 2026. [withheld] is the rate
/// usually deducted at source under national law; [creditable] is the part
/// German withholding tax credits (column C). The difference can only be
/// reclaimed in the source country.
class WithholdingTaxDefault {
  const WithholdingTaxDefault({
    required this.country,
    required this.currency,
    required this.withheld,
    required this.creditable,
    this.aliases = const [],
    this.note = '',
  });

  /// German country name as used in the app.
  final String country;
  final String currency;
  final double withheld;
  final double creditable;
  final List<String> aliases;
  final String note;

  /// Percentage points that only the source country can refund.
  double get reclaimable => (withheld - creditable).clamp(0, 100).toDouble();
}

const withholdingTaxSource =
    'Bundeszentralamt für Steuern, Stand 1. Januar 2026';

const withholdingTaxDefaults = <WithholdingTaxDefault>[
  WithholdingTaxDefault(
    country: 'Deutschland',
    currency: 'EUR',
    withheld: 0,
    creditable: 0,
    aliases: ['germany'],
    note: 'Inland: Kapitalertragsteuer statt Quellensteuer',
  ),
  WithholdingTaxDefault(
    country: 'USA',
    currency: 'USD',
    withheld: 15,
    creditable: 15,
    aliases: [
      'us',
      'vereinigte staaten',
      'united states',
      'united states of america',
    ],
    note: '15 % mit Formular W-8BEN (bei deutschen Banken üblich), sonst 30 %',
  ),
  WithholdingTaxDefault(
    country: 'Kanada',
    currency: 'CAD',
    withheld: 25,
    creditable: 15,
    aliases: ['canada'],
  ),
  WithholdingTaxDefault(
    country: 'Vereinigtes Königreich',
    currency: 'GBP',
    withheld: 0,
    creditable: 0,
    aliases: ['großbritannien', 'uk', 'united kingdom', 'england'],
    note: 'Keine Quellensteuer auf Dividenden',
  ),
  WithholdingTaxDefault(
    country: 'Frankreich',
    currency: 'EUR',
    withheld: 12.8,
    creditable: 12.8,
    aliases: ['france'],
  ),
  WithholdingTaxDefault(
    country: 'Schweiz',
    currency: 'CHF',
    withheld: 35,
    creditable: 15,
    aliases: ['switzerland'],
  ),
  WithholdingTaxDefault(
    country: 'Österreich',
    currency: 'EUR',
    withheld: 27.5,
    creditable: 15,
    aliases: ['oesterreich', 'austria'],
  ),
  WithholdingTaxDefault(
    country: 'Niederlande',
    currency: 'EUR',
    withheld: 15,
    creditable: 15,
    aliases: ['netherlands', 'holland'],
  ),
  WithholdingTaxDefault(
    country: 'Belgien',
    currency: 'EUR',
    withheld: 30,
    creditable: 0,
    aliases: ['belgium'],
    note: 'Nicht anrechenbar, Erstattung nur in Belgien',
  ),
  WithholdingTaxDefault(
    country: 'Luxemburg',
    currency: 'EUR',
    withheld: 15,
    creditable: 15,
    aliases: ['luxembourg'],
  ),
  WithholdingTaxDefault(
    country: 'Irland',
    currency: 'EUR',
    withheld: 25,
    creditable: 0,
    aliases: ['ireland'],
    note: 'Befreiung bzw. Erstattung auf Antrag, daher nicht anrechenbar',
  ),
  WithholdingTaxDefault(
    country: 'Spanien',
    currency: 'EUR',
    withheld: 19,
    creditable: 15,
    aliases: ['spain'],
  ),
  WithholdingTaxDefault(
    country: 'Portugal',
    currency: 'EUR',
    withheld: 28,
    creditable: 15,
  ),
  WithholdingTaxDefault(
    country: 'Italien',
    currency: 'EUR',
    withheld: 26,
    creditable: 15,
    aliases: ['italy'],
  ),
  WithholdingTaxDefault(
    country: 'Dänemark',
    currency: 'DKK',
    withheld: 27,
    creditable: 15,
    aliases: ['daenemark', 'denmark'],
  ),
  WithholdingTaxDefault(
    country: 'Norwegen',
    currency: 'NOK',
    withheld: 25,
    creditable: 0,
    aliases: ['norway'],
    note: 'Nicht anrechenbar, Erstattung nur in Norwegen',
  ),
  WithholdingTaxDefault(
    country: 'Schweden',
    currency: 'SEK',
    withheld: 30,
    creditable: 15,
    aliases: ['sweden'],
  ),
  WithholdingTaxDefault(
    country: 'Finnland',
    currency: 'EUR',
    withheld: 35,
    creditable: 15,
    aliases: ['finland'],
    note: '35 % bei Sammelverwahrung, 30 % mit Nachweis',
  ),
  WithholdingTaxDefault(
    country: 'Polen',
    currency: 'PLN',
    withheld: 19,
    creditable: 15,
    aliases: ['poland'],
  ),
  WithholdingTaxDefault(
    country: 'Tschechien',
    currency: 'CZK',
    withheld: 15,
    creditable: 15,
    aliases: ['tschechische republik', 'czech republic'],
  ),
  WithholdingTaxDefault(
    country: 'Japan',
    currency: 'JPY',
    withheld: 15.315,
    creditable: 15,
    note: '15 % plus Wiederaufbau-Zuschlag',
  ),
  WithholdingTaxDefault(
    country: 'China',
    currency: 'CNY',
    withheld: 10,
    creditable: 10,
    aliases: ['volksrepublik china'],
  ),
  WithholdingTaxDefault(
    country: 'Hongkong',
    currency: 'HKD',
    withheld: 0,
    creditable: 0,
    aliases: ['hong kong'],
    note: 'Keine Quellensteuer auf Dividenden, kein DBA',
  ),
  WithholdingTaxDefault(
    country: 'Singapur',
    currency: 'SGD',
    withheld: 0,
    creditable: 0,
    aliases: ['singapore'],
    note: 'Keine Quellensteuer auf Dividenden',
  ),
  WithholdingTaxDefault(
    country: 'Südkorea',
    currency: 'KRW',
    withheld: 20,
    creditable: 15,
    aliases: ['korea', 'korea, republik', 'south korea'],
  ),
  WithholdingTaxDefault(
    country: 'Taiwan',
    currency: 'TWD',
    withheld: 21,
    creditable: 10,
  ),
  WithholdingTaxDefault(
    country: 'Indien',
    currency: 'INR',
    withheld: 20,
    creditable: 10,
    aliases: ['india'],
  ),
  WithholdingTaxDefault(
    country: 'Australien',
    currency: 'AUD',
    withheld: 30,
    creditable: 15,
    aliases: ['australia'],
    note: '„Franked dividends“ sind frei von Quellensteuer',
  ),
  WithholdingTaxDefault(
    country: 'Neuseeland',
    currency: 'NZD',
    withheld: 30,
    creditable: 15,
    aliases: ['new zealand'],
  ),
  WithholdingTaxDefault(
    country: 'Israel',
    currency: 'ILS',
    withheld: 25,
    creditable: 10,
  ),
  WithholdingTaxDefault(
    country: 'Südafrika',
    currency: 'ZAR',
    withheld: 20,
    creditable: 15,
    aliases: ['south africa'],
  ),
  WithholdingTaxDefault(
    country: 'Mexiko',
    currency: 'MXN',
    withheld: 10,
    creditable: 10,
    aliases: ['mexico'],
  ),
  WithholdingTaxDefault(
    country: 'Türkei',
    currency: 'TRY',
    withheld: 15,
    creditable: 15,
    aliases: ['turkey'],
  ),
  WithholdingTaxDefault(
    country: 'Ungarn',
    currency: 'HUF',
    withheld: 15,
    creditable: 15,
    aliases: ['hungary'],
  ),
];

/// The standard values for [country] (name or common alias), if known.
WithholdingTaxDefault? withholdingTaxDefaultFor(String? country) {
  final normalized = normalizeCountry(country ?? '');
  if (normalized.isEmpty) return null;
  for (final entry in withholdingTaxDefaults) {
    if (normalizeCountry(entry.country) == normalized ||
        entry.aliases.contains(normalized)) {
      return entry;
    }
  }
  return null;
}

/// Share of the gross dividend, in percent, that German tax credits for
/// [country] when [withheld] percent were deducted there. Unknown countries
/// get the usual treaty rate of 15 %.
double creditableTaxRateFor(String? country, double withheld) {
  final known = withholdingTaxDefaultFor(country);
  final cap = known?.creditable ?? 15;
  return (withheld < cap ? withheld : cap).clamp(0, 25).toDouble();
}
