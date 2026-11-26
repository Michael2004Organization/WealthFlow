/// Average euro reference rates of the European Central Bank as starting
/// values, until the administration sets its own rate for a country.
///
/// Units of the currency for 1 EUR, averaged over the 24 ECB fixing days
/// from 26 Oct to 26 Nov 2026 (eurofxref-hist). The ECB publishes no rate
/// for the Taiwan dollar (TWD); it has no standard value.
library;

const exchangeRateSource = 'EZB-Referenzkurse, Durchschnitt 26.10.–26.11.2026';

const ecbAverageRatesPerEuro = <String, double>{
  'EUR': 1,
  'USD': 1.1094,
  'CHF': 0.920525,
  'GBP': 0.83558,
  'DKK': 7.47452,
  'SEK': 11.0812,
  'NOK': 10.536,
  'JPY': 176.04,
  'CAD': 1.56978,
  'AUD': 1.62062,
  'NZD': 1.99292,
  'HKD': 8.70199,
  'SGD': 1.42482,
  'PLN': 4.41656,
  'CZK': 24.3819,
  'HUF': 366.793,
  'RON': 5.34546,
  'CNY': 7.39658,
  'INR': 104.274,
  'KRW': 1485.87,
  'MXN': 20.8628,
  'ZAR': 18.7255,
  'TRY': 55.7186,
  'ILS': 3.55921,
  'BRL': 6.2381,
  'ISK': 136.708,
  'IDR': 20183.2,
  'MYR': 4.53195,
  'PHP': 70.566,
  'THB': 37.4885,
};

/// Units of [to] for one unit of [from] from the ECB averages, or null when
/// one of the currencies has no published rate.
double? defaultExchangeRate(String from, String to) {
  final source = from.trim().toUpperCase();
  final target = to.trim().toUpperCase();
  if (source == target || source.isEmpty || target.isEmpty) return 1;
  final perEuroSource = ecbAverageRatesPerEuro[source];
  final perEuroTarget = ecbAverageRatesPerEuro[target];
  if (perEuroSource == null || perEuroTarget == null) return null;
  return perEuroTarget / perEuroSource;
}
