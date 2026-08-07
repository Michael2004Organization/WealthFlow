import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/budget_period.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  String _periodMode = 'month';
  DateTime _periodAnchor = DateTime.now();
  DateTimeRange _customPeriod = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
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
              _buildTopExpenses(context, entries),
              const SizedBox(height: 16),
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

  Widget _buildTopExpenses(BuildContext context, List<LedgerEntry> entries) {
    final range = switch (_periodMode) {
      'year' => DateTimeRange(
        start: DateTime(_periodAnchor.year),
        end: DateTime(_periodAnchor.year, 12, 31, 23, 59, 59),
      ),
      'custom' => _customPeriod,
      _ => DateTimeRange(
        start: DateTime(_periodAnchor.year, _periodAnchor.month),
        end: DateTime(
          _periodAnchor.year,
          _periodAnchor.month + 1,
        ).subtract(const Duration(milliseconds: 1)),
      ),
    };
    final top = entries.where((entry) {
      if (entry.isIncome ||
          entry.sourceType == 'transfer' ||
          entry.sourceType == 'saving') {
        return false;
      }
      final economicDate = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return !economicDate.isBefore(range.start) &&
          !economicDate.isAfter(range.end);
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
    final label = switch (_periodMode) {
      'year' => '${_periodAnchor.year}',
      'custom' =>
        '${DateFormat('dd.MM.yyyy').format(range.start)} – '
            '${DateFormat('dd.MM.yyyy').format(range.end)}',
      _ =>
        '${_statisticsMonthNames[_periodAnchor.month - 1]} '
            '${_periodAnchor.year}',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Top-Ausgaben',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Text('Höchste Einzel-Ausgaben im gewählten Zeitraum'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: _periodMode,
                    decoration: const InputDecoration(labelText: 'Zeitraum'),
                    items: const [
                      DropdownMenuItem(value: 'month', child: Text('Monat')),
                      DropdownMenuItem(value: 'year', child: Text('Jahr')),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Benutzerdefiniert'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _periodMode = value ?? 'month'),
                  ),
                ),
                if (_periodMode != 'custom') ...[
                  IconButton(
                    tooltip: 'Vorheriger Zeitraum',
                    onPressed: () => setState(
                      () => _periodAnchor = _periodMode == 'year'
                          ? DateTime(_periodAnchor.year - 1)
                          : DateTime(
                              _periodAnchor.year,
                              _periodAnchor.month - 1,
                            ),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    tooltip: 'Nächster Zeitraum',
                    onPressed: () => setState(
                      () => _periodAnchor = _periodMode == 'year'
                          ? DateTime(_periodAnchor.year + 1)
                          : DateTime(
                              _periodAnchor.year,
                              _periodAnchor.month + 1,
                            ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ] else
                  OutlinedButton.icon(
                    onPressed: _pickCustomPeriod,
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(label),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (top.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Keine Ausgaben in diesem Zeitraum.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              for (final indexed in top.take(10).indexed) ...[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${indexed.$1 + 1}')),
                  title: Text(
                    indexed.$2.merchant.isEmpty
                        ? indexed.$2.description
                        : indexed.$2.merchant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(indexed.$2.category),
                  trailing: Text(
                    money(indexed.$2.amount),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (indexed.$1 < top.take(10).length - 1)
                  const Divider(height: 1),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomPeriod() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDateRange: _customPeriod,
    );
    if (selected != null) {
      setState(
        () => _customPeriod = DateTimeRange(
          start: selected.start,
          end: DateTime(
            selected.end.year,
            selected.end.month,
            selected.end.day,
            23,
            59,
            59,
          ),
        ),
      );
    }
  }
}

const _statisticsMonthNames = [
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
                    title:
                        accounts[index].label +
                        '\n' +
                        money(accounts[index].balance),
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
                      title:
                          sorted[index].key + '\n' + money(sorted[index].value),
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
      for (final entry in entries.where((e) {
        final period = budgetMonthOf(e.bookingDate, e.budgetMonth);
        return period.year == date.year &&
            period.month == date.month &&
            e.sourceType != 'transfer' &&
            e.sourceType != 'saving';
      })) {
        (entry.isIncome ? income : expense)[index] += entry.amount;
      }
    }
    return _ChartCard(
      title: 'Cashflow',
      description: 'Einnahmen und Ausgaben der letzten sechs Monate',
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    (rodIndex == 0 ? 'Einnahmen\n' : 'Ausgaben\n') +
                        money(rod.toY),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
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
