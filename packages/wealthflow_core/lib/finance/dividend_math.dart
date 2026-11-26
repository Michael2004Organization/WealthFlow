double dividendPaymentsPerYear(String frequency) => switch (frequency) {
  'monatlich' => 12,
  'vierteljährlich' => 4,
  'halbjährlich' => 2,
  'jährlich' || 'Sonderdividende' => 1,
  _ => 1,
};

const germanCapitalGainsTaxRate = 25.0;
const solidaritySurchargeRate = 5.5;

final class DividendTaxResult {
  const DividendTaxResult({
    required this.grossSource,
    required this.withholdingTaxSource,
    required this.gross,
    required this.withholdingTax,
    required this.creditableWithholdingTax,
    required this.germanCapitalTax,
    required this.solidaritySurcharge,
    required this.churchTax,
    required this.allowanceUsed,
    required this.allowanceRemaining,
    required this.net,
    this.partialExemption = 0,
    this.taxable = 0,
  });

  /// Gross payout in the dividend currency, rounded to cents.
  final double grossSource;

  /// Foreign withholding tax in the dividend currency, rounded to cents.
  final double withholdingTaxSource;

  /// Amounts below are in the base currency.
  final double gross;
  final double withholdingTax;
  final double creditableWithholdingTax;
  final double germanCapitalTax;
  final double solidaritySurcharge;
  final double churchTax;
  final double allowanceUsed;
  final double allowanceRemaining;
  final double net;

  /// Tax-free part of a fund distribution (Teilfreistellung).
  final double partialExemption;

  /// Income subject to German tax after partial exemption and allowance.
  final double taxable;

  /// Foreign tax that German tax does not credit: only the source country
  /// refunds it (e.g. 20 of the 35 % withheld in Switzerland), or the bank
  /// credits it later in the year once the allowance is used up.
  double get nonCreditableWithholdingTax => _cents(
    (withholdingTax - creditableWithholdingTax).clamp(0, double.infinity),
  );

  /// All taxes on this payout, foreign and German.
  double get totalTax => _cents(
    withholdingTax + germanCapitalTax + solidaritySurcharge + churchTax,
  );
}

/// Standard calculation for a German private investor without church tax.
/// Tax components are rounded per payout, as they are on a bank statement.
///
/// [creditableRate] caps the foreign tax that is credited, in percent of the
/// gross payout (column C of the BZSt overview: 15 for Switzerland although
/// 35 are withheld). Without it, up to 25 % are credited.
/// [partialExemption] is the tax-free share of a fund distribution (0.3 for
/// equity funds); the saver allowance only covers the taxable rest.
DividendTaxResult calculateGermanDividendTax({
  required double grossAmount,
  required double exchangeRate,
  required double withholdingTaxRate,
  required double allowanceRemaining,
  double? creditableRate,
  double partialExemption = 0,
  double churchTaxRate = 0,
}) {
  // Foreign withholding tax is deducted in the dividend currency before the
  // payout is converted, as on a bank statement:
  // 14.86 USD - 2.23 USD = 12.63 USD -> EUR.
  final rate = exchangeRate.clamp(0, double.infinity);
  final grossSource = _cents(grossAmount.clamp(0, double.infinity));
  final sourceRate = withholdingTaxRate.clamp(0, 100).toDouble();
  final withholdingTaxSource = _cents(grossSource * sourceRate / 100);
  final gross = _cents(grossSource * rate);
  final afterWithholding = _cents((grossSource - withholdingTaxSource) * rate);
  final withholdingTax = _cents(gross - afterWithholding);
  final exempt = _cents(gross * partialExemption.clamp(0, 1));
  // The allowance is consumed by the taxable income; foreign withholding tax
  // does not reduce it.
  final beforeAllowance = _cents(gross - exempt);
  final taxExemptGross = _cents(
    beforeAllowance.clamp(0, allowanceRemaining.clamp(0, double.infinity)),
  );
  final taxable = _cents(
    (beforeAllowance - taxExemptGross).clamp(0, double.infinity),
  );
  final capitalTaxBeforeCredit = _cents(
    taxable * germanCapitalGainsTaxRate / 100,
  );
  final creditablePercent = (creditableRate ?? germanCapitalGainsTaxRate)
      .clamp(0, germanCapitalGainsTaxRate)
      .toDouble();
  final maximumCreditable = _cents(gross * creditablePercent / 100);
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
  final churchTax = _cents(
    germanCapitalTax * churchTaxRate.clamp(0, 100) / 100,
  );
  final net = _cents(
    afterWithholding - germanCapitalTax - solidarity - churchTax,
  );
  return DividendTaxResult(
    grossSource: grossSource,
    withholdingTaxSource: withholdingTaxSource,
    gross: gross,
    withholdingTax: withholdingTax,
    creditableWithholdingTax: creditable,
    germanCapitalTax: germanCapitalTax,
    solidaritySurcharge: solidarity,
    churchTax: churchTax,
    allowanceUsed: taxExemptGross,
    allowanceRemaining: _cents(
      (allowanceRemaining - taxExemptGross).clamp(0, double.infinity),
    ),
    net: net,
    partialExemption: exempt,
    taxable: taxable,
  );
}

double _cents(num value) => roundCents(value);

/// Rounds to cents like a bank statement: half up. 2.235 is stored as
/// 2.23499… in binary, so a tiny nudge keeps it from rounding down.
double roundCents(num value) {
  final scaled = value * 100;
  return (scaled + (scaled >= 0 ? 1e-6 : -1e-6)).roundToDouble() / 100;
}

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
