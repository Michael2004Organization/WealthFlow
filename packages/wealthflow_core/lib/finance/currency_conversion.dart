import '../database/app_database.dart';

/// Converts amounts into the user's standard currency.
///
/// Rates are the configured exchange rates of the tax/country table: units of
/// the standard currency for one unit of the foreign currency.
final class CurrencyConverter {
  CurrencyConverter(String baseCurrency, Map<String, double> rates)
    : baseCurrency = baseCurrency.toUpperCase(),
      _rates = {
        for (final entry in rates.entries)
          if (entry.value > 0) entry.key.toUpperCase(): entry.value,
      };

  factory CurrencyConverter.fromRates(
    String baseCurrency,
    Iterable<CountryTaxRate> rows,
  ) => CurrencyConverter(baseCurrency, {
    for (final row in rows) row.currency: row.exchangeRate,
  });

  final String baseCurrency;
  final Map<String, double> _rates;

  /// Whether [currency] can be converted; unknown currencies are counted 1:1.
  bool canConvert(String currency) {
    final code = currency.toUpperCase();
    return code == baseCurrency || _rates.containsKey(code);
  }

  double toBase(double amount, String currency) {
    final code = currency.toUpperCase();
    if (code == baseCurrency) return amount;
    return amount * (_rates[code] ?? 1);
  }
}
