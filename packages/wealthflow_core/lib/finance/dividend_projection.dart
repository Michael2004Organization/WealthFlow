import '../database/app_database.dart';
import 'dividend_math.dart';
import 'portfolio_tax_summary.dart';

final class ProjectedDividend {
  const ProjectedDividend({
    required this.investment,
    required this.month,
    required this.tax,
    required this.withholdingTaxRate,
    required this.date,
    required this.paymentDateKnown,
    required this.sourceCurrency,
    required this.exchangeRate,
    required this.grossSource,
    required this.accountCurrency,
  });

  final Investment investment;
  final int month;
  final DividendTaxResult tax;
  final double withholdingTaxRate;
  final DateTime date;
  final bool paymentDateKnown;
  final String sourceCurrency;
  final double exchangeRate;
  final double grossSource;
  final String accountCurrency;
}

/// Expected dividend payouts of [year], after foreign withholding tax and
/// German capital gains tax. The saver allowance is consumed in payout order.
/// Exact schedules win over the investment's frequency estimate.
List<ProjectedDividend> buildDividendProjection(
  List<Investment> investments,
  List<DividendSchedule> schedules,
  double allowance,
  int year,
  List<InvestmentPurchase> purchases,
  List<PortfolioSale> sales,
  Map<String, String> accountCurrencies,
) {
  var remainingAllowance = allowance.clamp(0, double.infinity).toDouble();
  final events =
      <
        ({
          Investment investment,
          int month,
          double amount,
          double exchangeRate,
          double withholdingTaxRate,
          String currency,
          DateTime date,
        })
      >[];
  for (var month = 1; month <= 12; month++) {
    for (final investment in investments) {
      final exact = schedules
          .where(
            (row) =>
                row.investmentId == investment.id &&
                row.paymentMonth == month &&
                (row.paymentYear == year ||
                    (row.paymentYear == 0 && year == DateTime.now().year)),
          )
          .toList();
      if (exact.isNotEmpty) {
        for (final row in exact) {
          final accountCurrency =
              accountCurrencies[investment.accountId]?.toUpperCase() ?? 'EUR';
          final sourceCurrency = row.currency.toUpperCase();
          events.add((
            investment: investment,
            month: month,
            amount: row.amountPerShare,
            exchangeRate: sourceCurrency == accountCurrency
                ? 1
                : row.exchangeRate,
            withholdingTaxRate: row.withholdingTaxRate,
            currency: sourceCurrency,
            date: row.paymentDate ?? row.exDate ?? DateTime(year, month, 1),
          ));
        }
      } else if (dividendPaymentMonths(
        investment.dividendFrequency,
        investment.dividendStartMonth,
      ).contains(month)) {
        final accountCurrency =
            accountCurrencies[investment.accountId]?.toUpperCase() ?? 'EUR';
        final sourceCurrency = investment.dividendCurrency.toUpperCase();
        events.add((
          investment: investment,
          month: month,
          amount: investment.annualDividend,
          exchangeRate: sourceCurrency == accountCurrency
              ? 1
              : investment.dividendExchangeRate,
          withholdingTaxRate: investment.dividendWithholdingTaxRate,
          currency: sourceCurrency,
          date: DateTime(year, month),
        ));
      }
    }
  }
  events.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0
        ? byDate
        : a.investment.name.compareTo(b.investment.name);
  });
  final result = <ProjectedDividend>[];
  for (final event in events) {
    final shares = investmentSharesAt(
      investment: event.investment,
      date: event.date,
      purchases: purchases,
      sales: sales,
    );
    if (event.amount <= 0 || shares <= 0) continue;
    final tax = calculateGermanDividendTax(
      grossAmount: event.amount * shares,
      exchangeRate: event.exchangeRate,
      withholdingTaxRate: event.withholdingTaxRate,
      allowanceRemaining: remainingAllowance,
    );
    remainingAllowance = tax.allowanceRemaining;
    result.add(
      ProjectedDividend(
        investment: event.investment,
        month: event.month,
        tax: tax,
        withholdingTaxRate: event.withholdingTaxRate,
        date: event.date,
        paymentDateKnown: schedules.any(
          (row) =>
              row.investmentId == event.investment.id &&
              row.paymentMonth == event.month &&
              row.paymentDate != null &&
              (row.paymentYear == year ||
                  (row.paymentYear == 0 && year == DateTime.now().year)),
        ),
        sourceCurrency: event.currency,
        exchangeRate: event.exchangeRate,
        grossSource: event.amount * shares,
        accountCurrency: accountCurrencies[event.investment.accountId] ?? 'EUR',
      ),
    );
  }
  return result;
}

bool wasHeldDuringYear(
  Investment investment,
  List<InvestmentPurchase> purchases,
  List<PortfolioSale> sales,
  int year,
) {
  final end = DateTime(year + 1).subtract(const Duration(microseconds: 1));
  final start = DateTime(year);
  if (investment.deletedAt != null && investment.deletedAt!.isBefore(start)) {
    return false;
  }
  return investmentSharesAt(
            investment: investment,
            date: end,
            purchases: purchases,
            sales: sales,
          ) >
          0 ||
      sales.any(
        (sale) =>
            sale.investmentId == investment.id &&
            !sale.soldAt.isBefore(start) &&
            sale.soldAt.isBefore(DateTime(year + 1)),
      );
}

/// Payouts of [projection] that should have arrived within the last [days]
/// and are neither confirmed nor marked as not received, oldest first.
List<ProjectedDividend> pendingDividends(
  Iterable<ProjectedDividend> projection,
  Iterable<DividendReceipt> receipts, {
  required DateTime today,
  int days = 45,
}) {
  final end = DateTime(today.year, today.month, today.day + 1);
  final start = end.subtract(Duration(days: days + 1));
  final answered = {
    for (final receipt in receipts)
      if (receipt.deletedAt == null) receipt.id,
  };
  return [
    for (final payment in projection)
      if (payment.tax.net > 0 &&
          payment.date.isBefore(end) &&
          !payment.date.isBefore(start) &&
          !answered.contains(
            dividendReceiptId(payment.investment.id, payment.date),
          ))
        payment,
  ]..sort((a, b) => a.date.compareTo(b.date));
}
