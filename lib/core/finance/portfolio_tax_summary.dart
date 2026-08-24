import '../database/app_database.dart';
import 'dividend_math.dart';

final class PortfolioTaxSummary {
  const PortfolioTaxSummary({
    required this.allowance,
    required this.allowanceUsed,
    required this.taxPaid,
  });

  final double allowance;
  final double allowanceUsed;
  final double taxPaid;

  double get allowanceRemaining =>
      (allowance - allowanceUsed).clamp(0, double.infinity);
}

PortfolioTaxSummary calculatePortfolioTaxYear({
  required int year,
  required double allowance,
  required List<Investment> investments,
  required List<DividendSchedule> schedules,
  required List<PortfolioSale> sales,
  bool includePhysicalAssets = false,
  DateTime? through,
}) {
  final limit = through ?? DateTime(year + 1);
  var remaining = allowance.clamp(0, double.infinity).toDouble();
  var used = 0.0;
  var taxes = 0.0;
  final investmentById = {for (final item in investments) item.id: item};
  final events =
      <({DateTime date, DividendSchedule? dividend, PortfolioSale? sale})>[];

  for (final schedule in schedules) {
    final date = schedule.paymentDate;
    if (date != null && date.year == year && !date.isAfter(limit)) {
      events.add((date: date, dividend: schedule, sale: null));
    }
  }
  for (final sale in sales) {
    if (sale.assetKind == 'physical' && !includePhysicalAssets) continue;
    if (sale.soldAt.year == year && !sale.soldAt.isAfter(limit)) {
      events.add((date: sale.soldAt, dividend: null, sale: sale));
    }
  }
  events.sort((a, b) => a.date.compareTo(b.date));

  for (final event in events) {
    final sale = event.sale;
    if (sale != null) {
      final gain = sale.realizedGain.clamp(0, double.infinity).toDouble();
      final consumed = gain.clamp(0, remaining).toDouble();
      used += consumed;
      remaining -= consumed;
      taxes += sale.taxPaid;
      continue;
    }
    final schedule = event.dividend!;
    final investment = investmentById[schedule.investmentId];
    if (investment == null) continue;
    final tax = calculateGermanDividendTax(
      grossAmount: schedule.amountPerShare * investment.quantity,
      exchangeRate: schedule.exchangeRate,
      withholdingTaxRate: schedule.withholdingTaxRate,
      allowanceRemaining: remaining,
    );
    used += tax.allowanceUsed;
    remaining = tax.allowanceRemaining;
    taxes +=
        tax.withholdingTax + tax.germanCapitalTax + tax.solidaritySurcharge;
  }

  return PortfolioTaxSummary(
    allowance: allowance,
    allowanceUsed: (used * 100).round() / 100,
    taxPaid: (taxes * 100).round() / 100,
  );
}
