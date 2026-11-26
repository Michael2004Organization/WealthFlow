import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/currencies.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';
import 'package:wealthflow_core/finance/sale_tax.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import 'dividend_prompt.dart';
import 'dividend_tax_breakdown.dart';
import 'investments_page.dart';
part 'dividends/payment_dialogs.dart';
part 'dividends/quick_entry.dart';

final _dividendInvestmentFilterProvider = StateProvider<String?>((_) => null);
const _allDividendInvestments = '__all__';
const _allDividendAccounts = '__all_accounts__';

class DividendsPage extends ConsumerStatefulWidget {
  const DividendsPage({super.key});

  @override
  ConsumerState<DividendsPage> createState() => _DividendsPageState();
}

class _DividendsPageState extends ConsumerState<DividendsPage> {
  int _selectedYear = DateTime.now().year;
  bool _projectTaxToYearEnd = false;
  String _selectedAccountId = _allDividendAccounts;

  @override
  Widget build(BuildContext context) {
    final investments = ref.watch(investmentsProvider);
    return investments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Dividenden konnten nicht geladen werden: $error'),
      ),
      data: (items) {
        final accounts =
            ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
        final portfolioAccounts = accounts
            .where(
              (account) =>
                  account.usageType == 'portfolio' &&
                  items.any((item) => item.accountId == account.id),
            )
            .toList();
        final selectedAccountId =
            _selectedAccountId == _allDividendAccounts ||
                portfolioAccounts.any(
                  (account) => account.id == _selectedAccountId,
                )
            ? _selectedAccountId
            : _allDividendAccounts;
        final accountItems = selectedAccountId == _allDividendAccounts
            ? items
            : items
                  .where((item) => item.accountId == selectedAccountId)
                  .toList();
        final preference = ref.watch(preferencesProvider).valueOrNull;
        final selectedAccount = portfolioAccounts
            .where((account) => account.id == selectedAccountId)
            .firstOrNull;
        final baseCurrency =
            selectedAccount?.currency ?? preference?.currency ?? 'EUR';
        final taxAllowance = preference?.taxAllowance ?? 1000;
        final schedules =
            ref.watch(dividendSchedulesProvider).valueOrNull ??
            const <DividendSchedule>[];
        final sales =
            ref.watch(portfolioSalesProvider).valueOrNull ??
            const <PortfolioSale>[];
        final purchases =
            ref.watch(investmentPurchasesProvider).valueOrNull ??
            const <InvestmentPurchase>[];
        final taxThrough = _selectedYear == DateTime.now().year
            ? (_projectTaxToYearEnd
                  ? DateTime(_selectedYear, 12, 31, 23, 59, 59)
                  : DateTime.now())
            : DateTime(_selectedYear, 12, 31, 23, 59, 59);
        final taxYear = calculatePortfolioTaxYear(
          year: _selectedYear,
          allowance: taxAllowance,
          investments: accountItems,
          schedules: schedules,
          sales: sales,
          purchases: purchases,
          includePhysicalAssets:
              preference?.includePhysicalAssetsInTaxAllowance ?? false,
          converter: ref.watch(currencyConverterProvider),
          through: taxThrough,
        );
        var dividendItems = accountItems
            .where(
              (item) =>
                  wasHeldDuringYear(item, purchases, sales, _selectedYear) &&
                  (item.annualDividend > 0 ||
                      schedules.any((row) => row.investmentId == item.id)),
            )
            .toList()
            .toList();
        final fullProjection = buildDividendProjection(
          dividendItems,
          schedules,
          taxAllowance,
          _selectedYear,
          purchases,
          sales,
          {for (final account in accounts) account.id: account.currency},
          includePhysicalAssets:
              preference?.includePhysicalAssetsInTaxAllowance ?? false,
          converter: ref.watch(currencyConverterProvider),
        );
        dividendItems.sort(
          (a, b) => _netForInvestment(
            fullProjection,
            b.id,
          ).compareTo(_netForInvestment(fullProjection, a.id)),
        );
        final requestedSelection = ref.watch(_dividendInvestmentFilterProvider);
        final selectedId =
            requestedSelection == null ||
                requestedSelection == _allDividendInvestments
            ? _allDividendInvestments
            : dividendItems.any((item) => item.id == requestedSelection)
            ? requestedSelection
            : dividendItems.firstOrNull?.id;
        final visibleItems = selectedId == _allDividendInvestments
            ? dividendItems
            : dividendItems.where((item) => item.id == selectedId).toList();
        final projection = selectedId == _allDividendInvestments
            ? fullProjection
            : fullProjection
                  .where((payment) => payment.investment.id == selectedId)
                  .toList();
        final yearly = projection.fold<double>(
          0,
          (sum, payment) => sum + payment.tax.net,
        );
        final current = DateTime.now();
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
                    actionBelow: true,
                    action: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Vorheriges Jahr',
                                onPressed: () =>
                                    setState(() => _selectedYear--),
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              Text(
                                '$_selectedYear',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Nächstes Jahr',
                                onPressed: _selectedYear >= current.year
                                    ? null
                                    : () => setState(() => _selectedYear++),
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                              if (_selectedYear != current.year)
                                IconButton(
                                  tooltip: 'Aktuelles Jahr',
                                  onPressed: () => setState(
                                    () => _selectedYear = current.year,
                                  ),
                                  icon: const Icon(Icons.today_rounded),
                                ),
                            ],
                          ),
                        ),
                        FilterChip(
                          avatar: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Automatisch buchen'),
                          tooltip:
                              'Dividenden mit bekanntem Zahltag ohne '
                              'Nachfrage als Buchung übernehmen',
                          selected:
                              ref.watch(dividendAutoBookProvider).valueOrNull ??
                              false,
                          onSelected: (value) =>
                              setDividendAutoBook(ref, value),
                        ),
                        SizedBox(
                          width: 290,
                          child: SearchableDropdownButtonFormField<String>(
                            key: ValueKey(selectedAccountId),
                            initialValue: selectedAccountId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Portfolio-Konto',
                              prefixIcon: Icon(Icons.account_balance_rounded),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: _allDividendAccounts,
                                child: Text('Alle Portfolio-Konten'),
                              ),
                              ...portfolioAccounts.map(
                                (account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(
                                    '${account.label} · ${account.currency}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(() {
                              _selectedAccountId =
                                  value ?? _allDividendAccounts;
                              ref
                                      .read(
                                        _dividendInvestmentFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  _allDividendInvestments;
                            }),
                          ),
                        ),
                        if (dividendItems.isNotEmpty)
                          SizedBox(
                            width: 290,
                            child: SearchableDropdownButtonFormField<String>(
                              key: ValueKey(selectedId),
                              initialValue: selectedId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Aktienansicht',
                                prefixIcon: Icon(Icons.filter_alt_rounded),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: _allDividendInvestments,
                                  child: Text('Alle Aktien'),
                                ),
                                ...dividendItems.map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(
                                      item.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  ref
                                          .read(
                                            _dividendInvestmentFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      value,
                            ),
                          ),
                        if (_selectedYear == current.year)
                          FilterChip(
                            selected: _projectTaxToYearEnd,
                            avatar: const Icon(Icons.event_available_rounded),
                            label: Text(
                              _projectTaxToYearEnd
                                  ? 'Freistellung: Jahresende'
                                  : 'Freistellung: heute',
                            ),
                            onSelected: (value) =>
                                setState(() => _projectTaxToYearEnd = value),
                          ),
                        FilledButton.icon(
                          onPressed: () => openFinance(ref, 1),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Positionen verwalten'),
                        ),
                      ],
                    ),
                  ),
                  if (dividendItems.isNotEmpty)
                    _DividendHero(
                      year: _selectedYear,
                      yearly: yearly,
                      projection: projection,
                      baseCurrency: baseCurrency,
                      taxPaid: taxYear.taxPaid,
                      allowanceRemaining: taxYear.allowanceRemaining,
                      onTaxTap: () => _showDividendTaxInfo(
                        context,
                        taxYear,
                        projection,
                        sales,
                        _selectedYear,
                        taxThrough,
                      ),
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nach Unternehmen',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            for (final item in visibleItems)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () => showInvestmentEditor(
                                  context,
                                  ref,
                                  investment: item,
                                ),
                                leading: IconTile(
                                  size: 40,
                                  label:
                                      (item.symbol.isEmpty
                                              ? item.name
                                              : item.symbol)
                                          .substring(
                                            0,
                                            (item.symbol.isEmpty
                                                    ? item.name
                                                    : item.symbol)
                                                .length
                                                .clamp(1, 4),
                                          )
                                          .toUpperCase(),
                                ),
                                title: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.dividendFrequency} · '
                                  '${_perShareSummary(item, schedules)} je Stück',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      money(
                                        _annualDividend(projection, item.id),
                                        currency: baseCurrency,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${money(_annualDividend(projection, item.id) / 12, currency: baseCurrency)}/Monat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: WealthColors.of(context).muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (dividendItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DividendCalendar(
                      investments: dividendItems,
                      schedules: schedules,
                      projection: projection,
                      baseCurrency: baseCurrency,
                      selectedInvestmentId: selectedId,
                      year: _selectedYear,
                      onSelected: (value) =>
                          ref
                                  .read(
                                    _dividendInvestmentFilterProvider.notifier,
                                  )
                                  .state =
                              value,
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

class _CompactTaxMetric extends StatelessWidget {
  const _CompactTaxMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ],
  );
}

Future<void> _showDividendTaxInfo(
  BuildContext context,
  PortfolioTaxSummary summary,
  List<ProjectedDividend> projection,
  List<PortfolioSale> sales,
  int year,
  DateTime through,
) async {
  var filter = 'Alle';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final payments = projection.where((payment) {
          if (payment.date.isAfter(through)) return false;
          if (filter == 'Quellensteuer') return payment.tax.withholdingTax > 0;
          if (filter == 'Ländersteuer') {
            return payment.tax.germanCapitalTax +
                    payment.tax.solidaritySurcharge >
                0;
          }
          return true;
        }).toList();
        final yearSales = filter == 'Quellensteuer'
            ? const <PortfolioSale>[]
            : sales
                  .where(
                    (sale) =>
                        sale.soldAt.year == year &&
                        !sale.soldAt.isAfter(through),
                  )
                  .toList();
        return AlertDialog(
          title: Text('Steuern & Freistellung $year'),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 64).clamp(300, 700),
            height: (MediaQuery.sizeOf(context).height - 220).clamp(320, 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _CompactTaxMetric(
                      label: 'Steuern gesamt',
                      value: money(summary.taxPaid),
                      icon: Icons.receipt_long_outlined,
                    ),
                    _CompactTaxMetric(
                      label: 'Freistellung verwendet',
                      value: money(summary.allowanceUsed),
                      icon: Icons.savings_outlined,
                    ),
                    _CompactTaxMetric(
                      label: 'Frei',
                      value: money(summary.allowanceRemaining),
                      icon: Icons.shield_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Alle', label: Text('Alle')),
                    ButtonSegment(
                      value: 'Ländersteuer',
                      label: Text('Ländersteuer'),
                    ),
                    ButtonSegment(
                      value: 'Quellensteuer',
                      label: Text('Quellensteuer'),
                    ),
                  ],
                  selected: {filter},
                  onSelectionChanged: (value) =>
                      setDialogState(() => filter = value.first),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: payments.isEmpty && yearSales.isEmpty
                      ? const Center(
                          child: Text('Keine passenden Steuerereignisse.'),
                        )
                      : ListView(
                          children: [
                            for (final payment in payments)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.payments_outlined),
                                ),
                                title: Text(payment.investment.name),
                                subtitle: Text(
                                  '${DateFormat('dd.MM.yyyy').format(payment.date)} · '
                                  '${payment.investment.country.isEmpty ? 'Auslands' : payment.investment.country}-Quellensteuer '
                                  '${money(payment.tax.withholdingTax)} · '
                                  'Ländersteuer ${money(payment.tax.germanCapitalTax + payment.tax.solidaritySurcharge)}',
                                ),
                                trailing: Text(
                                  money(payment.tax.net),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            for (final sale in yearSales)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.sell_outlined),
                                ),
                                title: Text('${sale.assetName} · Verkauf'),
                                subtitle: Text(
                                  '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                                  'Quellensteuer ${money(0)} · Ländersteuer ${money(sale.taxPaid)}',
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    ),
  );
}

double _annualDividend(
  List<ProjectedDividend> projection,
  String investmentId,
) => _netForInvestment(projection, investmentId);

double _netForInvestment(
  List<ProjectedDividend> projection,
  String investmentId,
) => projection
    .where((payment) => payment.investment.id == investmentId)
    .fold<double>(0, (sum, payment) => sum + payment.tax.net);

String _perShareSummary(
  Investment investment,
  List<DividendSchedule> schedules,
) {
  final schedule = schedules
      .where((row) => row.investmentId == investment.id)
      .firstOrNull;
  final gross = schedule?.amountPerShare ?? investment.annualDividend;
  final currency = schedule?.currency ?? investment.dividendCurrency;
  return money(gross, currency: currency);
}

class _DividendCalendar extends ConsumerWidget {
  const _DividendCalendar({
    required this.investments,
    required this.schedules,
    required this.projection,
    required this.baseCurrency,
    required this.selectedInvestmentId,
    required this.year,
    required this.onSelected,
  });

  final List<Investment> investments;
  final List<DividendSchedule> schedules;
  final List<ProjectedDividend> projection;
  final String baseCurrency;
  final String? selectedInvestmentId;
  final int year;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId =
        selectedInvestmentId == null ||
            selectedInvestmentId == _allDividendInvestments
        ? _allDividendInvestments
        : investments.any((item) => item.id == selectedInvestmentId)
        ? selectedInvestmentId!
        : investments.first.id;
    final selected = selectedId == _allDividendInvestments
        ? null
        : investments.firstWhere((item) => item.id == selectedId);
    final exact = schedules
        .where(
          (row) =>
              row.investmentId == selectedId &&
              (row.paymentYear == year ||
                  (row.paymentYear == 0 && year == DateTime.now().year)),
        )
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Dividendenkalender Januar bis Dezember',
                maxLines: 1,
                softWrap: false,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 112).clamp(
                    200.0,
                    300.0,
                  ),
                  child: SearchableDropdownButtonFormField<String>(
                    key: ValueKey(selectedId),
                    initialValue: selectedId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Aktienansicht',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: _allDividendInvestments,
                        child: Text('Alle Aktien'),
                      ),
                      ...investments.map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      ),
                    ],
                    onChanged: onSelected,
                  ),
                ),
                FilledButton.icon(
                  onPressed: selected == null
                      ? null
                      : () => _showQuickEntry(
                          context,
                          ref,
                          investment: selected,
                          schedules: exact,
                          baseCurrency: baseCurrency,
                          year: year,
                        ),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text('Schnellerfassung'),
                ),
              ],
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
                          projection: projection,
                          baseCurrency: baseCurrency,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            if (selected == null)
              const Text(
                'Für Bearbeitung und Schnellerfassung bitte eine einzelne Aktie auswählen.',
              )
            else if (exact.isNotEmpty)
              for (final row in exact)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      monthNames[row.paymentMonth - 1].substring(0, 3),
                    ),
                  ),
                  title: Text(
                    '${money(projection.where((payment) => payment.investment.id == selected.id && payment.month == row.paymentMonth).firstOrNull?.tax.net ?? 0, currency: baseCurrency)} netto',
                  ),
                  subtitle: Text(
                    [
                      row.exDate == null
                          ? 'Ex-Datum offen'
                          : 'Ex ${DateFormat('dd.MM.yyyy').format(row.exDate!)}',
                      row.paymentDate == null
                          ? 'Zahlungstermin offen'
                          : 'Zahlung ${DateFormat('dd.MM.yyyy').format(row.paymentDate!)}',
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
                          baseCurrency: baseCurrency,
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

class _AnnualDividendChart extends StatelessWidget {
  const _AnnualDividendChart({
    required this.investment,
    required this.projection,
    required this.baseCurrency,
  });

  final Investment? investment;
  final List<ProjectedDividend> projection;
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    final values = List.generate(
      12,
      (index) => projection
          .where(
            (payment) =>
                (investment == null ||
                    payment.investment.id == investment!.id) &&
                payment.month == index + 1,
          )
          .fold<double>(0, (sum, payment) => sum + payment.tax.net),
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
                child: Text(monthNames[value.toInt()].substring(0, 3)),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${monthNames[group.x]}\n${money(rod.toY, currency: baseCurrency)}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
    required this.projection,
    required this.baseCurrency,
  });

  final int month;
  final List<ProjectedDividend> projection;
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    final payments = projection
        .where((payment) => payment.month == month)
        .toList();
    final total = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.tax.net,
    );
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: payments.isEmpty
            ? null
            : () => _showDividendPayments(
                context,
                title: monthNames[month - 1],
                payments: payments,
                baseCurrency: baseCurrency,
              ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                monthNames[month - 1],
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                money(total, currency: baseCurrency),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WealthColors.of(context).income,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${payment.investment.symbol.isEmpty ? payment.investment.name : payment.investment.symbol} · ${money(payment.tax.net, currency: baseCurrency)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          !payment.paymentDateKnown
                              ? '● Zahltag offen'
                              : payment.date.isAfter(DateTime.now())
                              ? '◷ Zukünftig'
                              : '✓ Eingegangen',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: !payment.paymentDateKnown
                                    ? WealthColors.of(context).expense
                                    : payment.date.isAfter(DateTime.now())
                                    ? Theme.of(context).colorScheme.primary
                                    : WealthColors.of(context).income,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividendHero extends StatelessWidget {
  const _DividendHero({
    required this.year,
    required this.yearly,
    required this.projection,
    required this.baseCurrency,
    required this.taxPaid,
    required this.allowanceRemaining,
    required this.onTaxTap,
  });

  final int year;
  final double yearly;
  final List<ProjectedDividend> projection;
  final String baseCurrency;
  final double taxPaid;
  final double allowanceRemaining;
  final VoidCallback onTaxTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('Dividenden $year · nach Steuern'),
            const SizedBox(height: 6),
            Text(
              money(yearly, currency: baseCurrency),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '≈ ${money(yearly / 12, currency: baseCurrency)} pro Monat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.income,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _AnnualDividendChart(
                investment: null,
                projection: projection,
                baseCurrency: baseCurrency,
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.border),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTaxTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Wrap(
                  spacing: 28,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _CompactTaxMetric(
                      label: 'Steuern',
                      value: money(taxPaid),
                      icon: Icons.receipt_long_outlined,
                    ),
                    _CompactTaxMetric(
                      label: 'Freistellung frei',
                      value: money(allowanceRemaining),
                      icon: Icons.shield_outlined,
                    ),
                    Icon(Icons.chevron_right_rounded, color: colors.muted),
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
