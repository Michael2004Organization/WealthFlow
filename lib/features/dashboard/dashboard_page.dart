import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/dividend_math.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final investments =
        ref.watch(investmentsProvider).valueOrNull ?? const <Investment>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
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
    final now = DateTime.now();
    final thisMonth = entries.where(
      (entry) =>
          entry.bookingDate.year == now.year &&
          entry.bookingDate.month == now.month,
    );
    final income = thisMonth
        .where((entry) => entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final expenses = thisMonth
        .where((entry) => !entry.isIncome)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final monthlyDividend = investments.fold<double>(
      0,
      (sum, item) =>
          sum +
          dividendPerMonth(
            item.annualDividend,
            item.quantity,
            item.dividendFrequency,
          ),
    );
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
                title: 'Hallo, ${user?.displayName.split(' ').first ?? 'du'}',
                subtitle: 'Dein finanzieller Überblick für heute.',
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
                      value: money(dividendPerYearFromMonth(monthlyDividend)),
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
              _MonthlyChart(entries: entries),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.entries});
  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totals = List<double>.filled(6, 0);
    for (var index = 0; index < 6; index++) {
      final date = DateTime(now.year, now.month - (5 - index));
      totals[index] = entries
          .where(
            (entry) =>
                !entry.isIncome &&
                entry.bookingDate.year == date.year &&
                entry.bookingDate.month == date.month,
          )
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
                  barTouchData: BarTouchData(enabled: true),
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
                            now.year,
                            now.month - (5 - value.toInt()),
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
