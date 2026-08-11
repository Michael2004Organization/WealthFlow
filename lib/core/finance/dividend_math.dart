double dividendPaymentsPerYear(String frequency) => switch (frequency) {
  'monatlich' => 12,
  'vierteljährlich' => 4,
  'halbjährlich' => 2,
  'jährlich' || 'Sonderdividende' => 1,
  _ => 1,
};

double dividendPerYear(
  double dividendPerShareAndPayment,
  double quantity,
  String frequency,
) => dividendPerShareAndPayment * quantity * dividendPaymentsPerYear(frequency);

double dividendPerMonth(
  double dividendPerShareAndPayment,
  double quantity,
  String frequency,
) => dividendPerYear(dividendPerShareAndPayment, quantity, frequency) / 12;

double dividendPerQuarterFromMonth(double monthlyTotal) => monthlyTotal * 3;

double dividendPerYearFromMonth(double monthlyTotal) => monthlyTotal * 12;

double netDividendInBaseCurrency({
  required double grossAmount,
  required double exchangeRate,
  required double withholdingTaxRate,
}) => grossAmount * exchangeRate * (1 - withholdingTaxRate.clamp(0, 100) / 100);

List<int> dividendPaymentMonths(String frequency, int startMonth) {
  final interval = switch (frequency) {
    'monatlich' => 1,
    'vierteljährlich' => 3,
    'halbjährlich' => 6,
    _ => 12,
  };
  final normalizedStart = ((startMonth - 1) % 12) + 1;
  return List<int>.generate(12 ~/ interval, (index) {
    return ((normalizedStart - 1 + index * interval) % 12) + 1;
  })..sort();
}
