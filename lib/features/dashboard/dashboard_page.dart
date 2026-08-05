import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/budget_period.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final investments =
        ref.watch(investmentsProvider).valueOrNull ?? const <Investment>[];
    final schedules =
        ref.watch(dividendSchedulesProvider).valueOrNull ??
        const <DividendSchedule>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final snapshots =
        ref.watch(netWorthSnapshotsProvider).valueOrNull ??
        const <NetWorthSnapshot>[];
    final user = ref.watch(authControllerProvider).user;
    final accountBalance = accounts.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );
    final portfolio = investments.fold<double>(
      0,
      (sum, item) => sum + item.quantity * item.currentPrice,
    );
    final invested = investments.fold<double>(
      0,
      (sum, item) => sum + item.quantity * item.purchasePrice + item.fees,
    );
    final thisMonth = entries.where((entry) {
      final period = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
      return period.year == _selectedMonth.year &&
          period.month == _selectedMonth.month &&
          entry.sourceType != 'transfer' &&
          entry.sourceType != 'saving';
    });
    final income = thisMonth
        .where((entry) => entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final expenses = thisMonth
        .where((entry) => !entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final yearlyDividend = investments.fold<double>(
      0,
      (sum, item) =>
          sum +
          List.generate(
            12,
            (index) => _dashboardDividendForMonth(item, schedules, index + 1),
          ).fold<double>(0, (total, value) => total + value),
    );
    final monthlyDividend = yearlyDividend / 12;
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Hallo, ' + (user?.displayName.split(' ').first ?? 'du'),
                subtitle:
                    'Finanzieller Überblick für ' +
                    _dashboardMonthLabel(_selectedMonth) +
                    '.',
                action: Card(
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Vorheriger Monat',
                        onPressed: () => setState(
                          () => _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          ),
                        ),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Text(
                        _dashboardMonthLabel(_selectedMonth),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        tooltip: 'Nächster Monat',
                        onPressed: () => setState(
                          () => _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          ),
                        ),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                      IconButton(
                        tooltip: 'Aktueller Monat',
                        onPressed: () {
                          final now = DateTime.now();
                          setState(
                            () =>
                                _selectedMonth = DateTime(now.year, now.month),
                          );
                        },
                        icon: const Icon(Icons.today_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 700 ? 1 : 2;
                  const spacing = 16.0;
                  final width =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  final cards = [
                    MetricCard(
                      title: 'Gesamtvermögen',
                      value: money(accountBalance + portfolio),
                      caption:
                          '${accounts.length} Konten · ${investments.length} Positionen',
                      icon: Icons.account_balance_wallet_rounded,
                      color: colors.primary,
                      onTap: () => openFinance(ref, 0),
                    ),
                    MetricCard(
                      title: 'Depotwert',
                      value: money(portfolio),
                      caption: invested == 0
                          ? 'Noch keine Performance'
                          : '${portfolio >= invested ? '+' : ''}${((portfolio - invested) / invested * 100).toStringAsFixed(2)} % Performance',
                      icon: Icons.trending_up_rounded,
                      color: portfolio >= invested ? Colors.teal : colors.error,
                      onTap: () => openFinance(ref, 1),
                    ),
                    MetricCard(
                      title: 'Ausgaben im Monat',
                      value: money(expenses),
                      caption:
                          '${thisMonth.where((entry) => !entry.isIncome).length} Buchungen',
                      icon: Icons.shopping_bag_rounded,
                      color: Colors.orange,
                      onTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 2,
                    ),
                    MetricCard(
                      title: 'Sparquote',
                      value: income <= 0
                          ? '–'
                          : '${((income - expenses) / income * 100).toStringAsFixed(1)} %',
                      caption: '${money(income)} Einnahmen im Monat',
                      icon: Icons.savings_rounded,
                      color: Colors.purple,
                      onTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 3,
                    ),
                    MetricCard(
                      title: 'Dividenden p. a.',
                      value: money(yearlyDividend),
                      caption: '${money(monthlyDividend)} pro Monat',
                      icon: Icons.payments_rounded,
                      color: Colors.green,
                      onTap: () => openFinance(ref, 2),
                    ),
                    MetricCard(
                      title: 'Freier Cashflow',
                      value: money(income - expenses),
                      caption: 'Einnahmen abzüglich Ausgaben',
                      icon: Icons.waterfall_chart_rounded,
                      color: income >= expenses ? Colors.cyan : colors.error,
                      onTap: () =>
                          ref.read(shellIndexProvider.notifier).state = 2,
                    ),
                  ];
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final card in cards)
                        SizedBox(width: width, child: card),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _NetWorthChart(snapshots: snapshots),
              const SizedBox(height: 16),
              _MonthlyChart(entries: entries, selectedMonth: _selectedMonth),
            ],
          ),
        ),
      ),
    );
  }
}

double _dashboardDividendForMonth(
  Investment investment,
  List<DividendSchedule> schedules,
  int month,
) {
  final exact = schedules.where(
    (row) => row.investmentId == investment.id && row.paymentMonth == month,
  );
  if (exact.isNotEmpty) {
    return exact.fold<double>(
      0,
      (sum, row) => sum + row.amountPerShare * investment.quantity,
    );
  }
  final paymentMonths = switch (investment.dividendFrequency) {
    'monatlich' => List<int>.generate(12, (index) => index + 1),
    'vierteljährlich' => const [3, 6, 9, 12],
    'halbjährlich' => const [6, 12],
    _ => const [12],
  };
  return paymentMonths.contains(month)
      ? investment.annualDividend * investment.quantity
      : 0;
}

String _dashboardMonthLabel(DateTime date) =>
    _dashboardMonths[date.month - 1] + ' ' + date.year.toString();

const _dashboardMonths = [
  'Januar',
  'Februar',
  'März',
  'April',
  'Mai',
  'Juni',
  'Juli',
  'August',
  'September',
  'Oktober',
  'November',
  'Dezember',
];

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.entries, required this.selectedMonth});
  final List<LedgerEntry> entries;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final totals = List<double>.filled(6, 0);
    for (var index = 0; index < 6; index++) {
      final date = DateTime(
        selectedMonth.year,
        selectedMonth.month - (5 - index),
      );
      totals[index] = entries
          .where((entry) {
            final period = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
            return !entry.isIncome &&
                entry.sourceType != 'transfer' &&
                entry.sourceType != 'saving' &&
                period.year == date.year &&
                period.month == date.month;
          })
          .fold<double>(0, (sum, entry) => sum + entry.amount);
    }
    final maxValue = totals.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ausgabenentwicklung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text('Die vergangenen sechs Monate'),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxValue <= 0 ? 100 : maxValue * 1.2,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            money(rod.toY),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime(
                            selectedMonth.year,
                            selectedMonth.month - (5 - value.toInt()),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              [
                                'Jan',
                                'Feb',
                                'Mär',
                                'Apr',
                                'Mai',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Okt',
                                'Nov',
                                'Dez',
                              ][date.month - 1],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var index = 0; index < totals.length; index++)
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: totals[index],
                            width: 20,
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthChart extends StatelessWidget {
  const _NetWorthChart({required this.snapshots});

  final List<NetWorthSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final visible = snapshots.length > 60
        ? snapshots.sublist(snapshots.length - 60)
        : snapshots;
    final totalSpots = visible.indexed
        .map((item) => FlSpot(item.$1.toDouble(), item.$2.totalNetWorth))
        .toList();
    final accountSpots = visible.indexed
        .map((item) => FlSpot(item.$1.toDouble(), item.$2.accountBalance))
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vermögensverlauf',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text('Gesamtvermögen und Kontostand bei jeder Wertänderung'),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: visible.length < 2
                  ? const Center(
                      child: Text(
                        'Der Verlauf erscheint nach der nächsten Wertänderung.',
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: .22),
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots
                                .map(
                                  (spot) => LineTooltipItem(
                                    (spot.barIndex == 0
                                            ? 'Gesamt: '
                                            : 'Konten: ') +
                                        money(spot.y),
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: totalSpots,
                            isCurved: true,
                            barWidth: 4,
                            color: Theme.of(context).colorScheme.primary,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: .12),
                            ),
                          ),
                          LineChartBarData(
                            spots: accountSpots,
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.teal,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
