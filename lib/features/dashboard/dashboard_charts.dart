part of 'dashboard_page.dart';

class _MonthlyChart extends StatefulWidget {
  const _MonthlyChart({required this.entries});
  final List<LedgerEntry> entries;

  @override
  State<_MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<_MonthlyChart> {
  int _months = 6;
  final ScrollController _scrollController = ScrollController();
  bool _alignToCurrentMonth = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_alignToCurrentMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _alignToCurrentMonth = false;
      });
    }
    final currentMonth = DateTime.now();
    final totals = List<double>.filled(_months, 0);
    for (var index = 0; index < _months; index++) {
      final date = DateTime(
        currentMonth.year,
        currentMonth.month - (_months - 1 - index),
      );
      totals[index] = widget.entries
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ausgabenentwicklung',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('Die vergangenen $_months Monate')),
                SizedBox(
                  width: 132,
                  child: SearchableDropdownButtonFormField<int>(
                    initialValue: _months,
                    isDense: true,
                    decoration: const InputDecoration(labelText: 'Monate'),
                    items: const [6, 12, 24, 36, 60]
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
            const SizedBox(height: 24),
            SizedBox(
              height: 236,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = _months <= 6
                      ? constraints.maxWidth
                      : _months * 82.0;
                  final chart = SizedBox(
                    width: chartWidth,
                    child: BarChart(
                      BarChartData(
                        maxY: maxValue <= 0 ? 100 : maxValue * 1.2,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) =>
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
                              reservedSize: 34,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime(
                                  currentMonth.year,
                                  currentMonth.month -
                                      (_months - 1 - value.toInt()),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(shortMonthName(date)),
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
                                  color: WealthColors.of(context).expense,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                  if (_months <= 6) return chart;
                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: chart,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _greeting(DateTime now) => now.hour < 11
    ? 'Guten Morgen'
    : now.hour < 18
    ? 'Hallo'
    : 'Guten Abend';

String _dayLabel(DateTime date) {
  final today = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final difference = day
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  return switch (difference) {
    0 => 'Heute',
    -1 => 'Gestern',
    1 => 'Morgen',
    _ => shortDate(date),
  };
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final current = month.year == now.year && month.month == now.month;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WealthColors.of(context).border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Vorheriger Monat',
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: current
                ? null
                : () => onChanged(DateTime(now.year, now.month)),
            child: Tooltip(
              message: current ? '' : 'Zum aktuellen Monat',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  monthLabel(month),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Nächster Monat',
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _NetWorthHero extends StatefulWidget {
  const _NetWorthHero({
    required this.netWorth,
    required this.change,
    required this.previousMonth,
    required this.accounts,
    required this.portfolio,
    required this.snapshots,
    required this.onTap,
  });

  final double netWorth;
  final double? change;
  final String previousMonth;
  final double accounts;
  final double portfolio;
  final List<NetWorthSnapshot> snapshots;
  final VoidCallback onTap;

  @override
  State<_NetWorthHero> createState() => _NetWorthHeroState();
}

/// Ranges of the net worth line; null months shows everything.
const _heroRanges = {'1M': 1, '6M': 6, '1J': 12, 'Alles': null};

class _NetWorthHeroState extends State<_NetWorthHero> {
  String _range = '6M';

  @override
  Widget build(BuildContext context) {
    final _NetWorthHero(
      :netWorth,
      :change,
      :previousMonth,
      :accounts,
      :portfolio,
      :snapshots,
      :onTap,
    ) = widget;
    final colors = WealthColors.of(context);
    final text = Theme.of(context).textTheme;
    final months = _heroRanges[_range];
    final now = DateTime.now();
    final from = months == null
        ? null
        : DateTime(now.year, now.month - months, now.day);
    final visible = from == null
        ? snapshots
        : snapshots.where((item) => !item.capturedAt.isBefore(from)).toList();
    final primary = Theme.of(context).colorScheme.primary;
    final base = netWorth - (change ?? 0);
    final percent = change == null || base == 0 ? null : change / base * 100;
    Widget figure(String label, double value, Color dot) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            money(value),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Eyebrow('Nettovermögen')),
                  _RangePicker(
                    value: _range,
                    values: _heroRanges.keys.toList(),
                    onChanged: (value) => setState(() => _range = value),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  money(netWorth),
                  style: text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    letterSpacing: -.5,
                  ),
                ),
              ),
              if (change != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${signedMoney(change, income: change >= 0)}'
                  '${percent == null ? '' : ' (${percent >= 0 ? '+' : '−'}${percent.abs().toStringAsFixed(1).replaceAll('.', ',')} %)'}'
                  ' seit $previousMonth',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.amount(income: change >= 0),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: visible.length < 2
                    ? Center(
                        child: Text(
                          'Der Verlauf erscheint nach der nächsten Wertänderung.',
                          style: TextStyle(color: colors.muted, fontSize: 13),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => [
                                for (final spot in spots)
                                  LineTooltipItem(
                                    '${shortDate(DateTime.fromMillisecondsSinceEpoch(spot.x.round()))}\n'
                                    '${money(spot.y)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (final item in visible)
                                  FlSpot(
                                    item.capturedAt.millisecondsSinceEpoch
                                        .toDouble(),
                                    item.totalNetWorth,
                                  ),
                              ],
                              isCurved: true,
                              preventCurveOverShooting: true,
                              barWidth: 2.5,
                              color: primary,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    primary.withValues(alpha: .18),
                                    primary.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: figure('Konten', accounts, colors.chart[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: figure(
                      'Depot & Sachwerte',
                      portfolio,
                      colors.chart[2],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
