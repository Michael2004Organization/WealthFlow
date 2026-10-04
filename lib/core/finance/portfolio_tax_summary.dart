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

final class PortfolioTaxEvent {
  const PortfolioTaxEvent({
    required this.date,
    required this.title,
    required this.kind,
    required this.allowanceUsed,
    required this.taxPaid,
    this.withholdingTax = 0,
    this.domesticTax = 0,
  });

  final DateTime date;
  final String title;
  final String kind;
  final double allowanceUsed;
  final double taxPaid;
  final double withholdingTax;
  final double domesticTax;
}

PortfolioTaxSummary calculatePortfolioTaxYear({
  required int year,
  required double allowance,
  required List<Investment> investments,
  required List<DividendSchedule> schedules,
  required List<PortfolioSale> sales,
  List<InvestmentPurchase> purchases = const [],
  bool includePhysicalAssets = false,
  DateTime? through,
}) {
  final events = calculatePortfolioTaxEvents(
    year: year,
    allowance: allowance,
    investments: investments,
    schedules: schedules,
    sales: sales,
    purchases: purchases,
    includePhysicalAssets: includePhysicalAssets,
    through: through,
  );
  return PortfolioTaxSummary(
    allowance: allowance,
    allowanceUsed:
        (events.fold<double>(0, (sum, event) => sum + event.allowanceUsed) *
                100)
            .round() /
        100,
    taxPaid:
        (events.fold<double>(0, (sum, event) => sum + event.taxPaid) * 100)
            .round() /
        100,
  );
}

List<PortfolioTaxEvent> calculatePortfolioTaxEvents({
  required int year,
  required double allowance,
  required List<Investment> investments,
  required List<DividendSchedule> schedules,
  required List<PortfolioSale> sales,
  List<InvestmentPurchase> purchases = const [],
  bool includePhysicalAssets = false,
  DateTime? through,
}) {
  final limit = through ?? DateTime(year + 1);
  var remaining = allowance.clamp(0, double.infinity).toDouble();
  final results = <PortfolioTaxEvent>[];
  final investmentById = {for (final item in investments) item.id: item};
  final events =
      <
        ({
          DateTime date,
          Investment? investment,
          DividendSchedule? dividend,
          PortfolioSale? sale,
        })
      >[];

  for (final schedule in schedules) {
    final appliesToYear =
        schedule.paymentYear == year ||
        (schedule.paymentYear == 0 && year == DateTime.now().year);
    if (!appliesToYear) continue;
    final date = schedule.paymentDate ?? DateTime(year, schedule.paymentMonth);
    if (!date.isAfter(limit)) {
      events.add((
        date: date,
        investment: investmentById[schedule.investmentId],
        dividend: schedule,
        sale: null,
      ));
    }
  }
  for (final investment in investments) {
    for (final month in dividendPaymentMonths(
      investment.dividendFrequency,
      investment.dividendStartMonth,
    )) {
      final hasExact = schedules.any(
        (schedule) =>
            schedule.investmentId == investment.id &&
            schedule.paymentMonth == month &&
            (schedule.paymentYear == year ||
                (schedule.paymentYear == 0 && year == DateTime.now().year)),
      );
      final date = DateTime(year, month);
      if (!hasExact && investment.annualDividend > 0 && !date.isAfter(limit)) {
        events.add((
          date: date,
          investment: investment,
          dividend: null,
          sale: null,
        ));
      }
    }
  }
  for (final sale in sales) {
    if (sale.assetKind == 'physical' && !includePhysicalAssets) continue;
    if (sale.soldAt.year == year && !sale.soldAt.isAfter(limit)) {
      events.add((
        date: sale.soldAt,
        investment: null,
        dividend: null,
        sale: sale,
      ));
    }
  }
  events.sort((a, b) => a.date.compareTo(b.date));

  for (final event in events) {
    final sale = event.sale;
    if (sale != null) {
      // The allowance the sale actually used, after partial exemption and
      // loss offsetting, as stored when it was booked.
      final consumed = sale.allowanceUsed.clamp(0, remaining).toDouble();
      remaining -= consumed;
      results.add(
        PortfolioTaxEvent(
          date: event.date,
          title: sale.assetName,
          kind: 'sale',
          allowanceUsed: consumed,
          taxPaid: sale.taxPaid,
          domesticTax: sale.taxPaid,
        ),
      );
      continue;
    }
    final schedule = event.dividend;
    final investment = event.investment;
    if (investment == null) continue;
    final quantity = investmentSharesAt(
      investment: investment,
      date: event.date,
      purchases: purchases,
      sales: sales,
    );
    if (quantity <= 0) continue;
    final tax = calculateGermanDividendTax(
      grossAmount:
          (schedule?.amountPerShare ?? investment.annualDividend) * quantity,
      exchangeRate: schedule?.exchangeRate ?? investment.dividendExchangeRate,
      withholdingTaxRate:
          schedule?.withholdingTaxRate ?? investment.dividendWithholdingTaxRate,
      allowanceRemaining: remaining,
    );
    remaining = tax.allowanceRemaining;
    final domesticTax =
        tax.germanCapitalTax + tax.solidaritySurcharge + tax.churchTax;
    final totalTax = tax.withholdingTax + domesticTax;
    results.add(
      PortfolioTaxEvent(
        date: event.date,
        title: investment.name,
        kind: 'dividend',
        allowanceUsed: tax.allowanceUsed,
        taxPaid: totalTax,
        withholdingTax: tax.withholdingTax,
        domesticTax: domesticTax,
      ),
    );
  }
  return results;
}

double investmentSharesAt({
  required Investment investment,
  required DateTime date,
  required List<InvestmentPurchase> purchases,
  required List<PortfolioSale> sales,
}) {
  final investmentPurchases = purchases
      .where(
        (row) => row.investmentId == investment.id && row.deletedAt == null,
      )
      .toList();
  final investmentSales = sales
      .where((sale) => sale.investmentId == investment.id)
      .toList();
  final purchased = investmentPurchases.isEmpty
      ? (date.isBefore(investment.purchaseDate)
            ? 0.0
            : investment.quantity +
                  investmentSales.fold<double>(
                    0,
                    (sum, sale) => sum + sale.quantity,
                  ))
      : investmentPurchases
            .where((row) => !row.purchaseDate.isAfter(date))
            .fold<double>(0, (sum, row) => sum + row.quantity);
  final sold = investmentSales
      .where((sale) => !sale.soldAt.isAfter(date))
      .fold<double>(0, (sum, sale) => sum + sale.quantity);
  return (purchased - sold).clamp(0, double.infinity).toDouble();
}
