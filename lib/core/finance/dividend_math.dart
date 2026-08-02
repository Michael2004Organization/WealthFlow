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
