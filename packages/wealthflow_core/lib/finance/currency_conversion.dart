import '../database/app_database.dart';
import 'exchange_rate_defaults.dart';

/// Converts amounts into the user's standard currency.
///
/// Rates are the configured exchange rates of the tax/country table: units of
/// the standard currency for one unit of the foreign currency. A currency
/// without a configured rate uses the ECB average ([defaultExchangeRate]).
final class CurrencyConverter {
  CurrencyConverter(String baseCurrency, Map<String, double> rates)
    : baseCurrency = baseCurrency.toUpperCase(),
      _rates = {
        for (final entry in rates.entries)
          if (entry.value > 0) entry.key.toUpperCase(): entry.value,
      };

  /// Rows whose rate was never set (still 1 for a foreign currency) are left
  /// out, so the ECB average applies to them.
  factory CurrencyConverter.fromRates(
    String baseCurrency,
    Iterable<CountryTaxRate> rows,
  ) => CurrencyConverter(baseCurrency, {
    for (final row in rows)
      if (isConfiguredRate(
        row.exchangeRate,
        row.currency,
        baseCurrency,
        updatedAt: row.exchangeRateUpdatedAt,
      ))
        row.currency: row.exchangeRate,
  });

  final String baseCurrency;
  final Map<String, double> _rates;

  /// Whether [currency] can be converted with a configured or ECB rate;
  /// anything else is counted 1:1.
  bool canConvert(String currency) {
    final code = currency.toUpperCase();
    return code == baseCurrency ||
        _rates.containsKey(code) ||
        defaultExchangeRate(code, baseCurrency) != null;
  }

  double toBase(double amount, String currency) => amount * rateOf(currency);

  /// Units of the standard currency for one unit of [currency].
  double rateOf(String currency) {
    final code = currency.toUpperCase();
    if (code == baseCurrency || code.isEmpty) return 1;
    return _rates[code] ?? defaultExchangeRate(code, baseCurrency) ?? 1;
  }

  /// Converts [amount] from one currency into another over the standard
  /// currency; an empty currency counts as the standard currency.
  double convert(double amount, String from, String to) {
    final source = from.toUpperCase();
    final target = to.toUpperCase();
    if (source == target) return amount;
    return amount * rateOf(source) / rateOf(target);
  }

  /// Rate for a dividend paid in [from] and booked in [to]: the rate stored
  /// on the payment if one was really set, else the current one.
  double dividendRate(double stored, String from, String to) {
    final source = from.trim().toUpperCase();
    final target = to.trim().toUpperCase();
    if (source.isEmpty || target.isEmpty || source == target) return 1;
    return isConfiguredRate(stored, source, target)
        ? stored
        : convert(1, source, target);
  }

  /// Current value of a position in the standard currency.
  double investmentValue(Investment investment, {double? quantity}) => toBase(
    (quantity ?? investment.quantity) * investment.currentPrice,
    investment.instrumentCurrency.isEmpty
        ? baseCurrency
        : investment.instrumentCurrency,
  );
}

/// A stored rate of exactly 1 between two different currencies is the
/// column default, not a real rate, unless someone saved it on purpose.
bool isConfiguredRate(
  double rate,
  String from,
  String to, {
  DateTime? updatedAt,
}) {
  if (rate <= 0) return false;
  if (from.trim().toUpperCase() == to.trim().toUpperCase()) return true;
  return rate != 1 || updatedAt != null;
}
