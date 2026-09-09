import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _defaultCardOrder = [
    'topExpenses',
    'accounts',
    'portfolio',
    'categories',
    'cashflow',
    'vehicleCosts',
    'savings',
  ];
  String _periodMode = 'month';
  DateTime _periodAnchor = DateTime.now();
  DateTimeRange _customPeriod = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  String _sortMode = 'default';
  List<String> _customOrder = [..._defaultCardOrder];
  String? _loadedForUser;

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
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null && _loadedForUser != userId) {
      _loadedForUser = userId;
      Future<void>.microtask(() => _loadCardLayout(userId));
    }
    final cards = <({String key, String title, double height, Widget child})>[
      (
        key: 'topExpenses',
        title: 'Top-Ausgaben',
        height: 430,
        child: _buildTopExpenses(context, entries),
      ),
      (
        key: 'accounts',
        title: 'Kontostände',
        height: 430,
        child: _AccountsChart(accounts: accounts),
      ),
      (
        key: 'portfolio',
        title: 'Depotentwicklung',
        height: 430,
        child: _PortfolioChart(investments: investments),
      ),
      (
        key: 'categories',
        title: 'Ausgabenkategorien',
        height: 430,
        child: _CategoryChart(entries: entries),
      ),
      (
        key: 'cashflow',
        title: 'Cashflow',
        height: 430,
        child: _CashflowChart(entries: entries),
      ),
      (
        key: 'vehicleCosts',
        title: 'Fahrzeugkosten',
        height: 430,
        child: _VehicleCostChart(costs: costs),
      ),
      (
        key: 'savings',
        title: 'Sparentwicklung',
        height: 430,
        child: _SavingsChart(entries: entries),
      ),
    ];
    if (_sortMode == 'alphabetical') {
      cards.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortMode == 'custom') {
      cards.sort(
        (a, b) =>
            _customOrder.indexOf(a.key).compareTo(_customOrder.indexOf(b.key)),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Statistik',
                subtitle: 'Interaktive Auswertungen über alle Module.',
                action: SizedBox(
                  width: 220,
                  child: SearchableDropdownButtonFormField<String>(
                    key: ValueKey(_sortMode),
                    initialValue: _sortMode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Blöcke sortieren',
                      prefixIcon: Icon(Icons.sort_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('Standardreihenfolge'),
                      ),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Eigene Reihenfolge'),
                      ),
                      DropdownMenuItem(
                        value: 'alphabetical',
                        child: Text('Alphabetisch'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) _setSortMode(value);
                    },
                  ),
                ),
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
                      for (final indexed in cards.indexed)
                        SizedBox(
                          width: width,
                          height:
                              indexed.$2.height +
                              (_sortMode == 'custom' ? 44 : 0),
                          child: Column(
                            children: [
                              if (_sortMode == 'custom')
                                _StatisticsMoveControls(
                                  canMoveUp: indexed.$1 > 0,
                                  canMoveDown: indexed.$1 < cards.length - 1,
                                  onMoveUp: () => _moveCard(
                                    indexed.$2.key,
                                    cards[indexed.$1 - 1].key,
                                  ),
                                  onMoveDown: () => _moveCard(
                                    indexed.$2.key,
                                    cards[indexed.$1 + 1].key,
                                  ),
                                ),
                              Expanded(child: indexed.$2.child),
                            ],
                          ),
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
                  child: SearchableDropdownButtonFormField<String>(
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
              SizedBox(
                height: 216,
                child: Scrollbar(
                  thumbVisibility: top.length > 3,
                  child: ListView.separated(
                    itemCount: top.take(10).length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = top[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          entry.merchant.isEmpty
                              ? entry.description
                              : entry.merchant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(entry.category),
                        trailing: Text(
                          money(entry.amount),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomPeriod() async {
    final selected = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => _CompactDateRangeDialog(
        initialRange: _customPeriod,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      ),
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

  Future<void> _loadCardLayout(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedOrder = preferences.getStringList(
      'statistics.cardOrder.$userId',
    );
    if (!mounted || _loadedForUser != userId) return;
    setState(() {
      _sortMode =
          preferences.getString('statistics.sortMode.$userId') ?? 'default';
      if (storedOrder != null) {
        _customOrder = [
          ...storedOrder.where(_defaultCardOrder.contains),
          ..._defaultCardOrder.where((key) => !storedOrder.contains(key)),
        ];
      }
    });
  }

  Future<void> _persistCardLayout() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('statistics.sortMode.$userId', _sortMode);
    await preferences.setStringList(
      'statistics.cardOrder.$userId',
      _customOrder,
    );
  }

  void _setSortMode(String value) {
    setState(() => _sortMode = value);
    _persistCardLayout();
  }

  void _moveCard(String key, String targetKey) {
    setState(() {
      final oldIndex = _customOrder.indexOf(key);
      final newIndex = _customOrder.indexOf(targetKey);
      final item = _customOrder.removeAt(oldIndex);
      _customOrder.insert(newIndex, item);
      _sortMode = 'custom';
    });
    _persistCardLayout();
  }
}

class _StatisticsMoveControls extends StatelessWidget {
  const _StatisticsMoveControls({
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      IconButton(
        tooltip: 'Nach oben',
        visualDensity: VisualDensity.compact,
        onPressed: canMoveUp ? onMoveUp : null,
        icon: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
      IconButton(
        tooltip: 'Nach unten',
        visualDensity: VisualDensity.compact,
        onPressed: canMoveDown ? onMoveDown : null,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
    ],
  );
}

class _CompactDateRangeDialog extends StatefulWidget {
  const _CompactDateRangeDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_CompactDateRangeDialog> createState() =>
      _CompactDateRangeDialogState();
}

class _CompactDateRangeDialogState extends State<_CompactDateRangeDialog> {
  late DateTime _start = widget.initialRange.start;
  late DateTime _end = widget.initialRange.end;
  bool _editingEnd = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Zeitraum wählen'),
    content: SizedBox(
      width: 360,
      height: 390,
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text('Von ${DateFormat('dd.MM.yyyy').format(_start)}'),
              ),
              ButtonSegment(
                value: true,
                label: Text('Bis ${DateFormat('dd.MM.yyyy').format(_end)}'),
              ),
            ],
            selected: {_editingEnd},
            onSelectionChanged: (value) =>
                setState(() => _editingEnd = value.first),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CalendarDatePicker(
              key: ValueKey((_editingEnd, _start, _end)),
              initialDate: _editingEnd ? _end : _start,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) {
                setState(() {
                  if (_editingEnd) {
                    _end = date.isBefore(_start) ? _start : date;
                  } else {
                    _start = date;
                    if (_end.isBefore(_start)) _end = _start;
                    _editingEnd = true;
                  }
                });
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, DateTimeRange(start: _start, end: _end)),
        child: const Text('Übernehmen'),
      ),
    ],
  );
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
    this.details,
  });
  final String title;
  final String description;
  final Widget child;
  final Widget? details;
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
          if (details != null)
            ExpansionTile(
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Angezeigte Werte'),
              children: [details!],
            ),
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
    details: SizedBox(
      height: 110,
      child: ListView(
        children: [
          for (final account in accounts)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(account.label),
              trailing: Text(
                money(account.balance),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    ),
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
                        '${accounts[index].label}\n${money(accounts[index].balance)}',
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
      details: SizedBox(
        height: 110,
        child: ListView(
          children: [
            for (final item in visible.take(6))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                trailing: Text(
                  money(item.quantity * item.currentPrice),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
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
      details: SizedBox(
        height: 110,
        child: ListView(
          children: [
            for (final item in sorted.take(7))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.key),
                trailing: Text(
                  money(item.value),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
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
                          '${sorted[index].key}\n${money(sorted[index].value)}',
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

class _CashflowChart extends StatefulWidget {
  const _CashflowChart({required this.entries});
  final List<LedgerEntry> entries;

  @override
  State<_CashflowChart> createState() => _CashflowChartState();
}

class _CashflowChartState extends State<_CashflowChart> {
  int _months = 6;
  final ScrollController _chartScrollController = ScrollController();
  bool _alignToCurrentMonth = true;

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_alignToCurrentMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_chartScrollController.hasClients) return;
        _chartScrollController.jumpTo(
          _chartScrollController.position.maxScrollExtent,
        );
        _alignToCurrentMonth = false;
      });
    }
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - _months + 1);
    final end = DateTime(now.year, now.month);
    final count = ((end.year - start.year) * 12 + end.month - start.month + 1)
        .clamp(1, 60);
    final periods = List.generate(
      count,
      (index) => DateTime(start.year, start.month + index),
    );
    final income = List<double>.filled(count, 0);
    final expense = List<double>.filled(count, 0);
    for (var index = 0; index < count; index++) {
      final date = periods[index];
      for (final entry in widget.entries.where((e) {
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
      description: 'Einnahmen und Ausgaben der letzten $_months Monate',
      child: Column(
        children: [
          Row(
            children: [
              _LegendDot(color: Colors.green, label: 'Einnahmen'),
              const SizedBox(width: 18),
              _LegendDot(color: Colors.redAccent, label: 'Ausgaben'),
              const Spacer(),
              SizedBox(
                width: 116,
                child: SearchableDropdownButtonFormField<int>(
                  initialValue: _months,
                  isDense: true,
                  decoration: const InputDecoration(labelText: 'Monate'),
                  items: const [6, 12, 24, 36]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _months = value;
                        _alignToCurrentMonth = true;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = count <= 6
                    ? constraints.maxWidth
                    : count * 92.0;
                final chart = SizedBox(
                  width: chartWidth,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = periods[group.x];
                            final label = rodIndex == 0
                                ? 'Einnahmen'
                                : 'Ausgaben';
                            return BarTooltipItem(
                              '${_statisticsMonthNames[date.month - 1]} ${date.year}\n'
                              '$label: ${money(rod.toY)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
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
                              final index = value.toInt();
                              if (index < 0 || index >= periods.length) {
                                return const SizedBox.shrink();
                              }
                              final date = periods[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  _statisticsMonthNames[date.month - 1]
                                      .substring(0, 3),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < count; i++)
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
                );
                if (count <= 6) return chart;
                return Scrollbar(
                  controller: _chartScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _chartScrollController,
                    scrollDirection: Axis.horizontal,
                    child: chart,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: false,
              itemCount: count.clamp(0, 4),
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final sourceIndex = count - count.clamp(0, 4) + index;
                final date = periods[sourceIndex];
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
                        'Einnahmen  ${money(income[sourceIndex])}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ausgaben  ${money(expense[sourceIndex])}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Saldo  ${money(income[sourceIndex] - expense[sourceIndex])}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: income[sourceIndex] - expense[sourceIndex] >= 0
                              ? Colors.green
                              : Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
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
