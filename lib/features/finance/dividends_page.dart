import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/dividend_math.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import 'investments_page.dart';

class DividendsPage extends ConsumerWidget {
  const DividendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investments = ref.watch(investmentsProvider);
    return investments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Dividenden konnten nicht geladen werden: $error'),
      ),
      data: (items) {
        final schedules =
            ref.watch(dividendSchedulesProvider).valueOrNull ??
            const <DividendSchedule>[];
        final dividendItems =
            items
                .where(
                  (item) =>
                      item.annualDividend > 0 ||
                      schedules.any((row) => row.investmentId == item.id),
                )
                .toList()
              ..sort(
                (a, b) => _annualDividend(
                  b,
                  schedules,
                ).compareTo(_annualDividend(a, schedules)),
              );
        final yearly = dividendItems.fold<double>(
          0,
          (sum, item) => sum + _annualDividend(item, schedules),
        );
        final monthly = yearly / 12;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: 'Dividenden',
                    subtitle:
                        'Erträge und Ausschüttungsrhythmus deiner Positionen.',
                    action: FilledButton.icon(
                      onPressed: () => openFinance(ref, 1),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Positionen verwalten'),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth < 700
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 32) / 3;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Jahr',
                              value: money(yearly),
                              icon: Icons.calendar_today_rounded,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Quartal',
                              value: money(
                                dividendPerQuarterFromMonth(monthly),
                              ),
                              icon: Icons.date_range_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Monat',
                              value: money(monthly),
                              icon: Icons.today_rounded,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (dividendItems.isEmpty)
                    SizedBox(
                      height: 360,
                      child: EmptyState(
                        icon: Icons.payments_rounded,
                        title: 'Noch keine Dividenden',
                        message:
                            'Hinterlege bei deinen Portfolio-Positionen die Dividende je Stück und Monat.',
                        action: FilledButton.icon(
                          onPressed: () => openFinance(ref, 1),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Position bearbeiten'),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chartWidth = constraints.maxWidth < 820
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 16) * .48;
                        final listWidth = constraints.maxWidth < 820
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 16) * .52;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: chartWidth,
                              height: 390,
                              child: _DividendChart(
                                items: dividendItems,
                                schedules: schedules,
                              ),
                            ),
                            SizedBox(
                              width: listWidth,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nach Unternehmen',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      for (final item in dividendItems)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () => showInvestmentEditor(
                                            context,
                                            ref,
                                            investment: item,
                                          ),
                                          leading: CircleAvatar(
                                            child: Text(
                                              item.symbol.isEmpty
                                                  ? item.name[0]
                                                  : item.symbol[0],
                                            ),
                                          ),
                                          title: Text(item.name),
                                          subtitle: Text(
                                            '${item.dividendFrequency} · '
                                            '${money(item.annualDividend)} je Stück/Ausschüttung · '
                                            'Kurs ${money(item.currentPrice)}',
                                          ),
                                          trailing: Text(
                                            money(
                                                  _annualDividend(
                                                        item,
                                                        schedules,
                                                      ) /
                                                      12,
                                                ) +
                                                '/Monat',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  if (dividendItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DividendCalendar(
                      investments: dividendItems,
                      schedules: schedules,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DividendChart extends StatelessWidget {
  const _DividendChart({required this.items, required this.schedules});
  final List<Investment> items;
  final List<DividendSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    final palette = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verteilung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 58,
                  sectionsSpace: 3,
                  sections: [
                    for (var index = 0; index < items.length; index++)
                      PieChartSectionData(
                        value: _annualDividend(items[index], schedules),
                        title: items[index].symbol.isEmpty
                            ? items[index].name
                            : items[index].symbol,
                        color: palette[index % palette.length],
                        radius: 72,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
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

double _annualDividend(
  Investment investment,
  List<DividendSchedule> schedules,
) => List.generate(
  12,
  (index) => _dividendForMonth(investment, schedules, index + 1),
).fold<double>(0, (sum, value) => sum + value);

double _dividendForMonth(
  Investment investment,
  List<DividendSchedule> schedules,
  int month,
) {
  final exact = schedules
      .where((row) => row.investmentId == investment.id)
      .toList();
  final exactForMonth = exact
      .where((row) => row.paymentMonth == month)
      .toList();
  if (exactForMonth.isNotEmpty) {
    return exactForMonth.fold<double>(
      0,
      (sum, row) => sum + row.amountPerShare * investment.quantity,
    );
  }
  final paymentMonths = dividendPaymentMonths(
    investment.dividendFrequency,
    investment.dividendStartMonth,
  );
  return paymentMonths.contains(month)
      ? investment.annualDividend * investment.quantity
      : 0;
}

class _DividendCalendar extends ConsumerStatefulWidget {
  const _DividendCalendar({required this.investments, required this.schedules});

  final List<Investment> investments;
  final List<DividendSchedule> schedules;

  @override
  ConsumerState<_DividendCalendar> createState() => _DividendCalendarState();
}

class _DividendCalendarState extends ConsumerState<_DividendCalendar> {
  String? _selectedInvestmentId;

  @override
  Widget build(BuildContext context) {
    final ids = widget.investments.map((item) => item.id).toSet();
    final selectedId = ids.contains(_selectedInvestmentId)
        ? _selectedInvestmentId!
        : widget.investments.first.id;
    final selected = widget.investments.firstWhere(
      (item) => item.id == selectedId,
    );
    final exact = widget.schedules
        .where((row) => row.investmentId == selectedId)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Dividendenkalender Januar bis Dezember',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selectedId),
                    initialValue: selectedId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Aktienansicht',
                    ),
                    items: widget.investments
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedInvestmentId = value),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _showScheduleEditor(context, ref, investment: selected),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Auszahlung'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showHistoryLoader(context, selected),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Historie nachladen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DividendQuickEntry(
              key: ValueKey('quick-$selectedId'),
              investment: selected,
              schedules: exact,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 560
                    ? constraints.maxWidth
                    : constraints.maxWidth < 950
                    ? (constraints.maxWidth - 12) / 2
                    : (constraints.maxWidth - 36) / 4;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var month = 1; month <= 12; month++)
                      SizedBox(
                        width: width,
                        child: _DividendMonthCard(
                          month: month,
                          investments: widget.investments,
                          schedules: widget.schedules,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              selected.name + ' im Jahresverlauf',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 230,
              child: _AnnualDividendChart(
                investment: selected,
                schedules: widget.schedules,
              ),
            ),
            const SizedBox(height: 12),
            if (exact.isEmpty)
              const Text(
                'Noch kein genauer Zahlungsplan: Die Monatswerte werden aus dem bisherigen Rhythmus hochgerechnet.',
              )
            else
              for (final row in exact)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      _monthNames[row.paymentMonth - 1].substring(0, 3),
                    ),
                  ),
                  title: Text(money(row.amountPerShare) + ' je Aktie'),
                  subtitle: Text(
                    [
                      row.exDate == null
                          ? 'Ex-Datum offen'
                          : 'Ex ' +
                                DateFormat('dd.MM.yyyy').format(row.exDate!),
                      row.paymentDate == null
                          ? 'Zahlungstermin offen'
                          : 'Zahlung ' +
                                DateFormat(
                                  'dd.MM.yyyy',
                                ).format(row.paymentDate!),
                      row.currency,
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Bearbeiten',
                        onPressed: () => _showScheduleEditor(
                          context,
                          ref,
                          investment: selected,
                          schedule: row,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Löschen',
                        onPressed: () => _deleteSchedule(context, ref, row),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showHistoryLoader(
  BuildContext context,
  Investment investment,
) async {
  var year = DateTime.now().year - 1;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Dividendenhistorie · ${investment.name}'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(
                  labelText: 'Historisches Jahr',
                ),
                items: List.generate(15, (index) => DateTime.now().year - index)
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text('$value')),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => year = value ?? year),
              ),
              const SizedBox(height: 16),
              const Text(
                'Der Cache und die jahresweise Abruflogik sind vorbereitet. Der Download wird freigeschaltet, sobald die endgültige Marktdaten-Webseite angebunden ist; bis dahin entsteht kein API-Request.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    ),
  );
}

class _DividendQuickEntry extends ConsumerStatefulWidget {
  const _DividendQuickEntry({
    super.key,
    required this.investment,
    required this.schedules,
  });

  final Investment investment;
  final List<DividendSchedule> schedules;

  @override
  ConsumerState<_DividendQuickEntry> createState() =>
      _DividendQuickEntryState();
}

class _DividendQuickEntryState extends ConsumerState<_DividendQuickEntry> {
  late final List<TextEditingController> _amounts = List.generate(12, (index) {
    final month = index + 1;
    final rows = widget.schedules.where((row) => row.paymentMonth == index + 1);
    return TextEditingController(
      text: rows.isNotEmpty
          ? rows.first.amountPerShare.toString()
          : _editableMonths.contains(month) &&
                widget.investment.annualDividend > 0
          ? widget.investment.annualDividend.toString()
          : '',
    );
  });
  bool _saving = false;

  late final Set<int> _editableMonths = dividendPaymentMonths(
    widget.investment.dividendFrequency,
    widget.investment.dividendStartMonth,
  ).toSet();

  @override
  void dispose() {
    for (final controller in _amounts) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .28),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Schnellerfassung · Betrag je Aktie',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Nur die Monate des ${widget.investment.dividendFrequency}en '
            'Rhythmus ab ${_monthNames[widget.investment.dividendStartMonth - 1]} '
            'sind änderbar. Der Positionsbetrag ist bereits vorbelegt.',
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var month = 1; month <= 12; month++) ...[
                  SizedBox(
                    width: 92,
                    child: TextField(
                      controller: _amounts[month - 1],
                      readOnly: !_editableMonths.contains(month),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _monthNames[month - 1].substring(0, 3),
                        suffixText: '€',
                        filled: !_editableMonths.contains(month),
                        prefixIcon: _editableMonths.contains(month)
                            ? null
                            : const Icon(Icons.lock_outline_rounded, size: 17),
                      ),
                    ),
                  ),
                  if (month < 12) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Alle Werte speichern'),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    setState(() => _saving = true);
    final database = ref.read(databaseProvider);
    final now = DateTime.now().toUtc();
    for (var month = 1; month <= 12; month++) {
      if (!_editableMonths.contains(month)) continue;
      final old = widget.schedules
          .where((row) => row.paymentMonth == month)
          .firstOrNull;
      final amount = double.tryParse(
        _amounts[month - 1].text.replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) {
        if (old != null) await database.deleteDividendSchedule(old.id, userId);
        continue;
      }
      await database.saveDividendSchedule(
        DividendSchedulesCompanion.insert(
          id: old?.id ?? const Uuid().v4(),
          userId: userId,
          investmentId: widget.investment.id,
          paymentMonth: month,
          amountPerShare: amount,
          exDate: Value(old?.exDate),
          paymentDate: Value(old?.paymentDate),
          paymentYear: Value(
            old?.paymentYear == 0 || old == null
                ? DateTime.now().year
                : old.paymentYear,
          ),
          currency: Value(old?.currency ?? 'EUR'),
          createdAt: old?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dividendenwerte wurden gespeichert.')),
      );
    }
  }
}

class _AnnualDividendChart extends StatelessWidget {
  const _AnnualDividendChart({
    required this.investment,
    required this.schedules,
  });

  final Investment investment;
  final List<DividendSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    final values = List.generate(
      12,
      (index) => _dividendForMonth(investment, schedules, index + 1),
    );
    final maximum = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    return BarChart(
      BarChartData(
        maxY: maximum <= 0 ? 1 : maximum * 1.2,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: .2),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_monthNames[value.toInt()].substring(0, 3)),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${_monthNames[group.x]}\n${money(rod.toY)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < values.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DividendMonthCard extends StatelessWidget {
  const _DividendMonthCard({
    required this.month,
    required this.investments,
    required this.schedules,
  });

  final int month;
  final List<Investment> investments;
  final List<DividendSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    final payments = investments
        .map((item) => (item, _dividendForMonth(item, schedules, month)))
        .where((entry) => entry.$2 > 0)
        .toList();
    final total = payments.fold<double>(0, (sum, entry) => sum + entry.$2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _monthNames[month - 1],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              money(total),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            if (payments.isEmpty)
              Text(
                'Keine Zahlung',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final payment in payments)
                Text(
                  (payment.$1.symbol.isEmpty
                          ? payment.$1.name
                          : payment.$1.symbol) +
                      ' · ' +
                      money(payment.$2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showScheduleEditor(
  BuildContext context,
  WidgetRef ref, {
  required Investment investment,
  DividendSchedule? schedule,
}) async {
  final existing =
      (ref.read(dividendSchedulesProvider).valueOrNull ??
              const <DividendSchedule>[])
          .where((row) => row.investmentId == investment.id)
          .toList();
  final amount = TextEditingController(
    text:
        schedule?.amountPerShare.toString() ??
        (investment.annualDividend > 0
            ? investment.annualDividend.toString()
            : ''),
  );
  var startMonth =
      schedule?.paymentMonth ?? existing.firstOrNull?.paymentMonth ?? 1;
  var months = schedule != null
      ? <int>{schedule.paymentMonth}
      : <int>{startMonth};
  var exDate = schedule?.exDate;
  var paymentDate = schedule?.paymentDate;
  final currency = TextEditingController(text: schedule?.currency ?? 'EUR');
  final key = GlobalKey<FormState>();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Auszahlung für ' + investment.name),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 560),
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (schedule == null) ...[
                    DropdownButtonFormField<int>(
                      initialValue: startMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Startmonat des Rhythmus',
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_monthNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          startMonth = value;
                          months = <int>{startMonth};
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    schedule == null
                        ? 'Auszahlungsmonate'
                        : 'Abweichende Auszahlung',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var month = 1; month <= 12; month++)
                        FilterChip(
                          label: Text(_monthNames[month - 1].substring(0, 3)),
                          selected: months.contains(month),
                          onSelected: schedule != null
                              ? null
                              : (selected) => setDialogState(() {
                                  if (selected) {
                                    months.add(month);
                                  } else {
                                    months.remove(month);
                                  }
                                }),
                        ),
                    ],
                  ),
                  if (months.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Wähle mindestens einen Auszahlungsmonat.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Dividende je Aktie und Auszahlung',
                      suffixText: '€',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );
                      return parsed == null || parsed <= 0
                          ? 'Bitte einen positiven Betrag eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: months.length == 1
                        ? () async {
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: exDate ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setDialogState(() => exDate = selected);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(
                      months.length > 1
                          ? 'Ex-Datum bei Bedarf je Monat bearbeiten'
                          : exDate == null
                          ? 'Ex-Datum auswählen'
                          : 'Ex-Datum ' +
                                DateFormat('dd.MM.yyyy').format(exDate!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: months.length == 1
                        ? () async {
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: paymentDate ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setDialogState(() => paymentDate = selected);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(
                      months.length > 1
                          ? 'Zahlungstermin bei Bedarf je Eintrag bearbeiten'
                          : paymentDate == null
                          ? 'Zahlungstermin auswählen'
                          : 'Zahlung ' +
                                DateFormat('dd.MM.yyyy').format(paymentDate!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currency,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Währung'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (months.isNotEmpty &&
                  (key.currentState?.validate() ?? false)) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (result == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      final now = DateTime.now().toUtc();
      final database = ref.read(databaseProvider);
      for (final month in months) {
        final old = schedule;
        await database.saveDividendSchedule(
          DividendSchedulesCompanion.insert(
            id: old?.id ?? const Uuid().v4(),
            userId: userId,
            investmentId: investment.id,
            paymentMonth: month,
            amountPerShare: double.parse(amount.text.replaceAll(',', '.')),
            exDate: Value(months.length == 1 ? exDate : old?.exDate),
            paymentDate: Value(
              months.length == 1 ? paymentDate : old?.paymentDate,
            ),
            paymentYear: Value(
              (paymentDate ?? exDate)?.year ?? DateTime.now().year,
            ),
            currency: Value(currency.text.trim().toUpperCase()),
            createdAt: old?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }
    }
  }
  amount.dispose();
  currency.dispose();
}

Future<void> _deleteSchedule(
  BuildContext context,
  WidgetRef ref,
  DividendSchedule schedule,
) async {
  if (!await confirmDelete(
    context,
    title: 'Auszahlung löschen?',
    message: 'Der Eintrag wird aus dem Dividendenkalender entfernt.',
  )) {
    return;
  }
  final userId = ref.read(currentUserIdProvider);
  if (userId != null) {
    await ref
        .read(databaseProvider)
        .deleteDividendSchedule(schedule.id, userId);
  }
}

const _monthNames = [
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
