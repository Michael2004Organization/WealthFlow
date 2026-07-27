import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final investments =
        ref.watch(investmentsProvider).valueOrNull ?? const <Investment>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final costs =
        ref.watch(vehicleCostsProvider).valueOrNull ?? const <VehicleCost>[];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Statistik',
                subtitle: 'Interaktive Auswertungen über alle Module.',
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 820
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _AccountsChart(accounts: accounts),
                      ),
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _PortfolioChart(investments: investments),
                      ),
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _CategoryChart(entries: entries),
                      ),
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _CashflowChart(entries: entries),
                      ),
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _VehicleCostChart(costs: costs),
                      ),
                      SizedBox(
                        width: width,
                        height: 380,
                        child: _SavingsChart(entries: entries),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.description,
    required this.child,
  });
  final String title;
  final String description;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class _AccountsChart extends StatelessWidget {
  const _AccountsChart({required this.accounts});
  final List<Account> accounts;
  @override
  Widget build(BuildContext context) => _ChartCard(
    title: 'Kontostände',
    description: 'Verteilung des liquiden Vermögens nach Konto',
    child: accounts.isEmpty
        ? const Center(child: Text('Noch keine Kontodaten'))
        : PieChart(
            PieChartData(
              centerSpaceRadius: 52,
              sections: [
                for (var index = 0; index < accounts.length; index++)
                  PieChartSectionData(
                    value: accounts[index].balance.abs(),
                    title: accounts[index].label,
                    radius: 62,
                    color: Colors.primaries[index % Colors.primaries.length],
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
  );
}

class _PortfolioChart extends StatelessWidget {
  const _PortfolioChart({required this.investments});
  final List<Investment> investments;
  @override
  Widget build(BuildContext context) {
    final visible = [...investments]
      ..sort(
        (a, b) => (b.quantity * b.currentPrice).compareTo(
          a.quantity * a.currentPrice,
        ),
      );
    return _ChartCard(
      title: 'Depotentwicklung',
      description: 'Aktueller Wert der größten Positionen',
      child: visible.isEmpty
          ? const Center(child: Text('Noch keine Portfoliodaten'))
          : BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
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
                barGroups: [
                  for (var index = 0; index < visible.take(8).length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY:
                              visible[index].quantity *
                              visible[index].currentPrice,
                          width: 18,
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.entries});
  final List<LedgerEntry> entries;
  @override
  Widget build(BuildContext context) {
    final values = <String, double>{};
    for (final entry in entries.where((entry) => !entry.isIncome)) {
      values.update(
        entry.category,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }
    final sorted = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _ChartCard(
      title: 'Ausgabenkategorien',
      description: 'Anteil der Ausgaben nach Kategorie',
      child: sorted.isEmpty
          ? const Center(child: Text('Noch keine Ausgaben'))
          : PieChart(
              PieChartData(
                centerSpaceRadius: 48,
                sections: [
                  for (var index = 0; index < sorted.take(7).length; index++)
                    PieChartSectionData(
                      value: sorted[index].value,
                      title: sorted[index].key,
                      radius: 64,
                      color: Colors.primaries[index % Colors.primaries.length],
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CashflowChart extends StatelessWidget {
  const _CashflowChart({required this.entries});
  final List<LedgerEntry> entries;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final income = List<double>.filled(6, 0);
    final expense = List<double>.filled(6, 0);
    for (var index = 0; index < 6; index++) {
      final date = DateTime(now.year, now.month - 5 + index);
      for (final entry in entries.where(
        (e) =>
            e.bookingDate.year == date.year &&
            e.bookingDate.month == date.month,
      )) {
        (entry.isIncome ? income : expense)[index] += entry.amount;
      }
    }
    return _ChartCard(
      title: 'Cashflow',
      description: 'Einnahmen und Ausgaben der letzten sechs Monate',
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (var i = 0; i < 6; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: income[i],
                    width: 10,
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: expense[i],
                    width: 10,
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCostChart extends StatelessWidget {
  const _VehicleCostChart({required this.costs});
  final List<VehicleCost> costs;
  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    for (final cost in costs) {
      categories.update(
        cost.category,
        (value) => value + cost.amount,
        ifAbsent: () => cost.amount,
      );
    }
    final spots = categories.values.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2))
        .toList();
    return _ChartCard(
      title: 'Fahrzeugkosten',
      description: 'Summen nach Kostenart',
      child: spots.isEmpty
          ? const Center(child: Text('Noch keine Fahrzeugkosten'))
          : LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: Colors.cyan,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.cyan.withValues(alpha: .14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SavingsChart extends StatelessWidget {
  const _SavingsChart({required this.entries});
  final List<LedgerEntry> entries;
  @override
  Widget build(BuildContext context) {
    final income = entries
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = entries
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final rate = income <= 0
        ? 0.0
        : ((income - expense) / income).clamp(0.0, 1.0);
    return _ChartCard(
      title: 'Sparquote',
      description: 'Gesamteinnahmen im Verhältnis zum Überschuss',
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 190,
              child: CircularProgressIndicator(
                value: rate,
                strokeWidth: 22,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(rate * 100).toStringAsFixed(1)} %',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('Sparquote'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
