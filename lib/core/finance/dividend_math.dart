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

const germanCapitalGainsTaxRate = 25.0;
const solidaritySurchargeRate = 5.5;

final class DividendTaxResult {
  const DividendTaxResult({
    required this.gross,
    required this.withholdingTax,
    required this.creditableWithholdingTax,
    required this.germanCapitalTax,
    required this.solidaritySurcharge,
    required this.allowanceUsed,
    required this.allowanceRemaining,
    required this.net,
  });

  final double gross;
  final double withholdingTax;
  final double creditableWithholdingTax;
  final double germanCapitalTax;
  final double solidaritySurcharge;
  final double allowanceUsed;
  final double allowanceRemaining;
  final double net;
}

/// Standard calculation for a German private investor without church tax.
/// Tax components are rounded per payout, as they are on a bank statement.
DividendTaxResult calculateGermanDividendTax({
  required double grossAmount,
  required double exchangeRate,
  required double withholdingTaxRate,
  required double allowanceRemaining,
}) {
  final gross = _cents((grossAmount * exchangeRate).clamp(0, double.infinity));
  final sourceRate = withholdingTaxRate.clamp(0, 100).toDouble();
  final withholdingTax = _cents(gross * sourceRate / 100);
  final allowanceUsed = _cents(
    gross.clamp(0, allowanceRemaining.clamp(0, double.infinity)),
  );
  final taxable = (gross - allowanceUsed).clamp(0, double.infinity);
  final capitalTaxBeforeCredit = _cents(
    taxable * germanCapitalGainsTaxRate / 100,
  );
  final maximumCreditable = _cents(gross * germanCapitalGainsTaxRate / 100);
  final creditable = _cents(
    withholdingTax.clamp(
      0,
      capitalTaxBeforeCredit < maximumCreditable
          ? capitalTaxBeforeCredit
          : maximumCreditable,
    ),
  );
  final germanCapitalTax = _cents(capitalTaxBeforeCredit - creditable);
  final solidarity = _cents(germanCapitalTax * solidaritySurchargeRate / 100);
  return DividendTaxResult(
    gross: gross,
    withholdingTax: withholdingTax,
    creditableWithholdingTax: creditable,
    germanCapitalTax: germanCapitalTax,
    solidaritySurcharge: solidarity,
    allowanceUsed: allowanceUsed,
    allowanceRemaining: _cents(
      (allowanceRemaining - allowanceUsed).clamp(0, double.infinity),
    ),
    net: _cents(gross - withholdingTax - germanCapitalTax - solidarity),
  );
}

double _cents(num value) => (value * 100).roundToDouble() / 100;

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
