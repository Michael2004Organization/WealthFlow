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
          : _PositionBars(investments: visible.take(6).toList()),
    );
  }
}

class _PositionBars extends StatelessWidget {
  const _PositionBars({required this.investments});

  final List<Investment> investments;

  @override
  Widget build(BuildContext context) {
    final maximum = investments
        .map((item) => item.quantity * item.currentPrice)
        .fold<double>(0, (max, value) => value > max ? value : max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in investments)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text(
                    money(item.quantity * item.currentPrice),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: maximum <= 0
                            ? 0
                            : (item.quantity * item.currentPrice / maximum)
                                  .clamp(.04, 1),
                        widthFactor: .62,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
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
      child: Column(
        children: [
          Row(
            children: [
              _LegendDot(color: Colors.green, label: 'Einnahmen'),
              const SizedBox(width: 18),
              _LegendDot(color: Colors.redAccent, label: 'Ausgaben'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: .18),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 54,
                      getTitlesWidget: (value, meta) => Text(
                        NumberFormat.compactCurrency(
                          locale: 'de_DE',
                          symbol: '€',
                          decimalDigits: 0,
                        ).format(value),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime(
                          now.year,
                          now.month - 5 + value.toInt(),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            _statisticsMonthNames[date.month - 1].substring(
                              0,
                              3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < 6; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: income[i],
                          width: 14,
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: expense[i],
                          width: 14,
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = DateTime(now.year, now.month - 5 + index);
                return SizedBox(
                  width: 148,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statisticsMonthNames[date.month - 1],
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Einnahmen  ${money(income[index])}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ausgaben  ${money(expense[index])}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Saldo  ${money(income[index] - expense[index])}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<double>(0, (sum, item) => sum + item.value);
    return _ChartCard(
      title: 'Fahrzeugkosten',
      description: 'Kostenarten im direkten Vergleich',
      child: sorted.isEmpty
          ? const Center(child: Text('Noch keine Fahrzeugkosten'))
          : ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = sorted[index];
                final share = total <= 0 ? 0.0 : item.value / total;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.key,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${money(item.value)}  ·  ${(share * 100).toStringAsFixed(1)} %',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: share,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: 10),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
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
