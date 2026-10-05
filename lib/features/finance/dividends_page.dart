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
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import 'investments_page.dart';

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
          through: taxThrough,
        );
        var dividendItems = accountItems
            .where(
              (item) =>
                  _wasHeldDuringYear(item, purchases, sales, _selectedYear) &&
                  (item.annualDividend > 0 ||
                      schedules.any((row) => row.investmentId == item.id)),
            )
            .toList()
            .toList();
        final fullProjection = _buildDividendProjection(
          dividendItems,
          schedules,
          taxAllowance,
          _selectedYear,
          purchases,
          sales,
          {for (final account in accounts) account.id: account.currency},
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
        final now = DateTime(_selectedYear, current.month, current.day);
        final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        final quarterly = projection
            .where(
              (payment) =>
                  payment.month >= quarterStart &&
                  payment.month < quarterStart + 3,
            )
            .fold<double>(0, (sum, payment) => sum + payment.tax.net);
        final monthly = projection
            .where((payment) => payment.month == now.month)
            .fold<double>(0, (sum, payment) => sum + payment.tax.net);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title:
                        'Dividenden – Erträge und Ausschüttungsrhythmus deiner Positionen',
                    subtitle: '',
                    titleSingleLine: true,
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
                            child: _DividendMetric(
                              title: 'Pro Jahr',
                              value: yearly,
                              icon: Icons.calendar_today_rounded,
                              color: Colors.green,
                              currency: baseCurrency,
                              payments: projection,
                              periodLabel: '${now.year}',
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _DividendMetric(
                              title: 'Pro Quartal',
                              value: quarterly,
                              icon: Icons.date_range_rounded,
                              color: Colors.teal,
                              currency: baseCurrency,
                              payments: projection
                                  .where(
                                    (payment) =>
                                        payment.month >= quarterStart &&
                                        payment.month < quarterStart + 3,
                                  )
                                  .toList(),
                              periodLabel:
                                  '${((now.month - 1) ~/ 3) + 1}. Quartal ${now.year}',
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _DividendMetric(
                              title: 'Pro Monat',
                              value: monthly,
                              icon: Icons.today_rounded,
                              color: Colors.cyan,
                              currency: baseCurrency,
                              payments: projection
                                  .where(
                                    (payment) => payment.month == now.month,
                                  )
                                  .toList(),
                              periodLabel:
                                  '${_monthNames[now.month - 1]} ${now.year}',
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
                                items: visibleItems,
                                projection: projection,
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
                                      for (final item in visibleItems)
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
                                            '${_perShareSummary(item, schedules)} je Stück',
                                          ),
                                          trailing: Text(
                                            '${money(_annualDividend(projection, item.id) / 12, currency: baseCurrency)}/Monat',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      const Divider(height: 24),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () => _showDividendTaxInfo(
                                          context,
                                          taxYear,
                                          projection,
                                          sales,
                                          _selectedYear,
                                          taxThrough,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Wrap(
                                            spacing: 22,
                                            runSpacing: 10,
                                            children: [
                                              _CompactTaxMetric(
                                                label: 'Steuern',
                                                value: money(taxYear.taxPaid),
                                                icon:
                                                    Icons.receipt_long_outlined,
                                              ),
                                              _CompactTaxMetric(
                                                label: 'Freistellung verwendet',
                                                value: money(
                                                  taxYear.allowanceUsed,
                                                ),
                                                icon: Icons.savings_outlined,
                                              ),
                                              _CompactTaxMetric(
                                                label: 'Freistellung frei',
                                                value: money(
                                                  taxYear.allowanceRemaining,
                                                ),
                                                icon: Icons.shield_outlined,
                                              ),
                                            ],
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

class _DividendMetric extends StatelessWidget {
  const _DividendMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.currency,
    required this.payments,
    required this.periodLabel,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String currency;
  final List<_ProjectedDividend> payments;
  final String periodLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title Details',
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showDividendPayments(
        context,
        title: '$title · $periodLabel',
        payments: payments,
        baseCurrency: currency,
      ),
      child: MetricCard(
        title: title,
        value: money(value, currency: currency),
        icon: icon,
        color: color,
      ),
    ),
  );
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
  List<_ProjectedDividend> projection,
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

class _DividendChart extends StatelessWidget {
  const _DividendChart({required this.items, required this.projection});
  final List<Investment> items;
  final List<_ProjectedDividend> projection;

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
    final total = items.fold<double>(
      0,
      (sum, item) => sum + _annualDividend(projection, item.id),
    );
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
                        value: _annualDividend(projection, items[index].id),
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
            ExpansionTile(
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Betrag · Anteil im Dividendenportfolio'),
              children: [
                SizedBox(
                  height: 94,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: palette[index % palette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              items[index].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${money(_annualDividend(projection, items[index].id))} · '
                            '${(total <= 0 ? 0 : _annualDividend(projection, items[index].id) / total * 100).toStringAsFixed(1)} %',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

double _annualDividend(
  List<_ProjectedDividend> projection,
  String investmentId,
) => _netForInvestment(projection, investmentId);

double _netForInvestment(
  List<_ProjectedDividend> projection,
  String investmentId,
) => projection
    .where((payment) => payment.investment.id == investmentId)
    .fold<double>(0, (sum, payment) => sum + payment.tax.net);

final class _ProjectedDividend {
  const _ProjectedDividend({
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

List<_ProjectedDividend> _buildDividendProjection(
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
  final result = <_ProjectedDividend>[];
  for (final event in events) {
    final shares = _sharesHeldAt(
      event.investment,
      event.date,
      purchases,
      sales,
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
      _ProjectedDividend(
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

bool _wasHeldDuringYear(
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
  return _sharesHeldAt(investment, end, purchases, sales) > 0 ||
      sales.any(
        (sale) =>
            sale.investmentId == investment.id &&
            !sale.soldAt.isBefore(start) &&
            sale.soldAt.isBefore(DateTime(year + 1)),
      );
}

double _sharesHeldAt(
  Investment investment,
  DateTime date,
  List<InvestmentPurchase> purchases,
  List<PortfolioSale> sales,
) => investmentSharesAt(
  investment: investment,
  date: date,
  purchases: purchases,
  sales: sales,
);

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
  final List<_ProjectedDividend> projection;
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
                OutlinedButton.icon(
                  onPressed: selected == null
                      ? null
                      : () => _showHistoryLoader(context, ref, selected),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Historie nachladen'),
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
            const SizedBox(height: 20),
            Text(
              '${selected?.name ?? 'Alle Aktien'} im Jahresverlauf',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 230,
              child: _AnnualDividendChart(
                investment: selected,
                projection: projection,
                baseCurrency: baseCurrency,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: _AnnualDividendLineChart(
                investment: selected,
                projection: projection,
                baseCurrency: baseCurrency,
              ),
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
                      _monthNames[row.paymentMonth - 1].substring(0, 3),
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

Future<void> _showHistoryLoader(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) async {
  var year = DateTime.now().year - 1;
  final load = await showDialog<bool>(
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
              SearchableDropdownButtonFormField<int>(
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
                'Bereits zentral abgerufene API-Daten dieses Jahres werden in die Dividendenhistorie übernommen.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Schließen'),
          ),
          FilledButton.icon(
            onPressed: investment.stockId == null
                ? null
                : () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('API-Daten übernehmen'),
          ),
        ],
      ),
    ),
  );
  if (load != true || investment.stockId == null) return;
  final rows = await ref
      .read(databaseProvider)
      .stockDividendsForYear(investment.stockId!, year);
  if (rows.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Für $year sind noch keine API-Daten im Cache.'),
        ),
      );
    }
    return;
  }
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final database = ref.read(databaseProvider);
  final now = DateTime.now().toUtc();
  for (final row in rows) {
    await database.saveDividendSchedule(
      DividendSchedulesCompanion.insert(
        id: '${investment.id}-api-${row.id}',
        userId: userId,
        investmentId: investment.id,
        paymentMonth: (row.paymentDate ?? row.exDate).month,
        amountPerShare: row.amount,
        exDate: Value(row.exDate),
        paymentDate: Value(row.paymentDate),
        paymentYear: Value(year),
        currency: Value(row.currency),
        exchangeRate: Value(investment.dividendExchangeRate),
        withholdingTaxRate: Value(investment.dividendWithholdingTaxRate),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${rows.length} API-Zahlungen für $year übernommen.'),
      ),
    );
  }
}

Future<void> _showQuickEntry(
  BuildContext context,
  WidgetRef ref, {
  required Investment investment,
  required List<DividendSchedule> schedules,
  required String baseCurrency,
  required int year,
}) => showDialog<void>(
  context: context,
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
      child: _DividendQuickEntry(
        investment: investment,
        schedules: schedules,
        baseCurrency: baseCurrency,
        year: year,
      ),
    ),
  ),
);

class _DividendQuickEntry extends ConsumerStatefulWidget {
  const _DividendQuickEntry({
    required this.investment,
    required this.schedules,
    required this.baseCurrency,
    required this.year,
  });

  final Investment investment;
  final List<DividendSchedule> schedules;
  final String baseCurrency;
  final int year;

  @override
  ConsumerState<_DividendQuickEntry> createState() =>
      _DividendQuickEntryState();
}

class _DividendQuickEntryState extends ConsumerState<_DividendQuickEntry> {
  late final Set<int> _editableMonths = {
    ...dividendPaymentMonths(
      widget.investment.dividendFrequency,
      widget.investment.dividendStartMonth,
    ),
    ...widget.schedules.map((row) => row.paymentMonth),
  };
  late final List<TextEditingController> _amounts = List.generate(12, (index) {
    final month = index + 1;
    final row = _rowFor(month);
    return TextEditingController(
      text:
          row?.amountPerShare.toString() ??
          (widget.investment.annualDividend > 0
              ? widget.investment.annualDividend.toString()
              : ''),
    );
  });
  late final List<DateTime?> _exDates = List.generate(
    12,
    (index) => _rowFor(index + 1)?.exDate,
  );
  late final List<DateTime?> _paymentDates = List.generate(
    12,
    (index) => _rowFor(index + 1)?.paymentDate,
  );
  late final _currency = TextEditingController(
    text:
        widget.schedules.firstOrNull?.currency ??
        widget.investment.dividendCurrency,
  );
  late final _exchangeRate = TextEditingController(
    text:
        (widget.schedules.firstOrNull?.exchangeRate ??
                widget.investment.dividendExchangeRate)
            .toString(),
  );
  late final _taxRate = TextEditingController(
    text:
        (widget.schedules.firstOrNull?.withholdingTaxRate ??
                widget.investment.dividendWithholdingTaxRate)
            .toString(),
  );
  bool _saving = false;

  DividendSchedule? _rowFor(int month) =>
      widget.schedules.where((row) => row.paymentMonth == month).firstOrNull;

  @override
  void dispose() {
    for (final controller in _amounts) {
      controller.dispose();
    }
    _currency.dispose();
    _exchangeRate.dispose();
    _taxRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Schnellerfassung · ${widget.investment.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Schließen',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _currency,
                readOnly: true,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Währung'),
              ),
            ),
            SizedBox(
              width: 210,
              child: TextField(
                controller: _exchangeRate,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Kurs zu ${widget.baseCurrency}',
                  helperText: '1 Fremdwährung = ? ${widget.baseCurrency}',
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _taxRate,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quellensteuer',
                  suffixText: '%',
                  helperText: 'Aus Länder-Stammdaten',
                ),
              ),
            ),
            PopupMenuButton<int>(
              tooltip: 'Einen Monat auf alle übernehmen',
              onSelected: _copyMonthToAll,
              itemBuilder: (_) => [
                for (final month in _editableMonths)
                  PopupMenuItem(
                    value: month,
                    child: Text(
                      '${_monthNames[month - 1]} auf alle übernehmen',
                    ),
                  ),
              ],
              child: const Chip(
                avatar: Icon(Icons.copy_all_rounded, size: 18),
                label: Text('Monat übernehmen'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _editableMonths.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final month = _editableMonths.elementAt(index);
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fields = <Widget>[
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _amounts[month - 1],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: _monthNames[month - 1],
                            suffixText: _currency.text.toUpperCase(),
                          ),
                        ),
                      ),
                      _quickDateButton(
                        label: 'Ex-Datum',
                        value: _exDates[month - 1],
                        icon: Icons.event_rounded,
                        onChanged: (value) =>
                            setState(() => _exDates[month - 1] = value),
                      ),
                      _quickDateButton(
                        label: 'Zahlung',
                        value: _paymentDates[month - 1],
                        icon: Icons.payments_outlined,
                        onChanged: (value) =>
                            setState(() => _paymentDates[month - 1] = value),
                      ),
                    ];
                    return constraints.maxWidth < 650
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                fields[i],
                                if (i < fields.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          )
                        : Row(
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                if (i == 0)
                                  fields[i]
                                else
                                  Expanded(child: fields[i]),
                              ],
                            ],
                          );
                  },
                ),
              ),
            );
          },
        ),
      ),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Alle speichern'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _quickDateButton({
    required String label,
    required DateTime? value,
    required IconData icon,
    required ValueChanged<DateTime?> onChanged,
  }) => OutlinedButton.icon(
    onPressed: () async {
      final selected = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: value ?? DateTime.now(),
      );
      if (selected != null) onChanged(selected);
    },
    icon: Icon(icon),
    label: Text(
      value == null
          ? '$label wählen'
          : '$label ${DateFormat('dd.MM.yy').format(value)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  double? _number(String value) => parseAmount(value);

  Future<void> _save() async {
    final userId = ref.read(currentUserIdProvider);
    final rate = _number(_exchangeRate.text);
    final tax = _number(_taxRate.text);
    if (userId == null ||
        _currency.text.trim().isEmpty ||
        rate == null ||
        rate <= 0 ||
        tax == null ||
        tax < 0 ||
        tax > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Umrechnung und Steuer prüfen.')),
      );
      return;
    }
    setState(() => _saving = true);
    final database = ref.read(databaseProvider);
    final now = DateTime.now().toUtc();
    for (final month in _editableMonths) {
      final old = _rowFor(month);
      final amount = _number(_amounts[month - 1].text);
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
          exDate: Value(_exDates[month - 1]),
          paymentDate: Value(_paymentDates[month - 1]),
          paymentYear: Value(widget.year),
          currency: Value(_currency.text.trim().toUpperCase()),
          exchangeRate: Value(rate),
          withholdingTaxRate: Value(tax.clamp(0, 100)),
          createdAt: old?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dividendenwerte wurden gespeichert.')),
      );
    }
  }

  void _copyMonthToAll(int sourceMonth) {
    final sourceIndex = sourceMonth - 1;
    setState(() {
      for (final month in _editableMonths) {
        if (month == sourceMonth) continue;
        _amounts[month - 1].text = _amounts[sourceIndex].text;
        final ex = _exDates[sourceIndex];
        final payment = _paymentDates[sourceIndex];
        _exDates[month - 1] = ex == null
            ? null
            : DateTime(widget.year, month, ex.day);
        _paymentDates[month - 1] = payment == null
            ? null
            : DateTime(widget.year, month, payment.day);
      }
    });
  }
}

class _AnnualDividendChart extends StatelessWidget {
  const _AnnualDividendChart({
    required this.investment,
    required this.projection,
    required this.baseCurrency,
  });

  final Investment? investment;
  final List<_ProjectedDividend> projection;
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
                child: Text(_monthNames[value.toInt()].substring(0, 3)),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${_monthNames[group.x]}\n${money(rod.toY, currency: baseCurrency)}',
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

class _AnnualDividendLineChart extends StatelessWidget {
  const _AnnualDividendLineChart({
    required this.investment,
    required this.projection,
    required this.baseCurrency,
  });

  final Investment? investment;
  final List<_ProjectedDividend> projection;
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
    final color = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maximum <= 0 ? 1 : maximum * 1.2,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: .18),
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
              interval: 1,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_monthNames[value.toInt()].substring(0, 3)),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${_monthNames[spot.x.toInt()]}\n'
                    '${money(spot.y, currency: baseCurrency)} netto',
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
            spots: values.indexed
                .map((item) => FlSpot(item.$1.toDouble(), item.$2))
                .toList(),
            isCurved: true,
            barWidth: 4,
            color: color,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: .12),
            ),
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
  final List<_ProjectedDividend> projection;
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
                title: _monthNames[month - 1],
                payments: payments,
                baseCurrency: baseCurrency,
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
                money(total, currency: baseCurrency),
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
                                    ? Colors.orange
                                    : payment.date.isAfter(DateTime.now())
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.green,
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

Future<void> _showDividendPayments(
  BuildContext context, {
  required String title,
  required List<_ProjectedDividend> payments,
  required String baseCurrency,
}) {
  var newestFirst = true;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final sorted = [...payments]
          ..sort(
            (a, b) => newestFirst
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date),
          );
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(title)),
              TextButton.icon(
                onPressed: () => setState(() => newestFirst = !newestFirst),
                icon: Icon(
                  newestFirst
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
                label: Text(newestFirst ? 'Neueste' : 'Älteste'),
              ),
            ],
          ),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 620),
            child: sorted.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'In diesem Zeitraum sind keine Dividenden vorhanden.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final payment = sorted[index];
                      final status = !payment.paymentDateKnown
                          ? 'Zahltag offen'
                          : payment.date.isAfter(DateTime.now())
                          ? 'Zukünftig'
                          : 'Eingegangen';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                            payment.investment.symbol.isEmpty
                                ? payment.investment.name.substring(0, 1)
                                : payment.investment.symbol.substring(0, 1),
                          ),
                        ),
                        title: Text(payment.investment.name),
                        subtitle: Text(
                          '${DateFormat('dd.MM.yyyy').format(payment.date)} · $status',
                        ),
                        trailing: Text(
                          money(
                            payment.tax.net,
                            currency: payment.accountCurrency,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onTap: () => _showDividendPaymentDetail(
                          context,
                          payment: payment,
                        ),
                      );
                    },
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

Future<void> _showDividendPaymentDetail(
  BuildContext context, {
  required _ProjectedDividend payment,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) {
    final tax = payment.tax;
    final accountCurrency = payment.accountCurrency;
    final rate =
        payment.sourceCurrency.toUpperCase() == accountCurrency.toUpperCase()
        ? 1.0
        : payment.exchangeRate <= 0
        ? 1.0
        : payment.exchangeRate;
    return AlertDialog(
      title: Text('${payment.investment.name} · Brutto bis Netto'),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 720.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DividendTaxRow(
                label: 'Brutto',
                value: tax.grossSource,
                currency: payment.sourceCurrency,
                emphasized: true,
              ),
              _DividendTaxRow(
                label:
                    'Quellensteuer (${payment.withholdingTaxRate.toStringAsFixed(2)} % · ${payment.investment.country})',
                value: -tax.withholdingTaxSource,
                currency: payment.sourceCurrency,
              ),
              const SizedBox(height: 6),
              _DividendTaxRow(
                label: 'Zwischensumme nach Quellensteuer',
                value: tax.grossSource - tax.withholdingTaxSource,
                currency: payment.sourceCurrency,
                emphasized: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${payment.sourceCurrency.toUpperCase()} → ${accountCurrency.toUpperCase()} · Kurs ${rate.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              _DividendTaxRow(
                label: 'Nach Quellensteuer umgerechnet',
                value: tax.gross - tax.withholdingTax,
                currency: accountCurrency,
              ),
              if (tax.creditableWithholdingTax > 0)
                _DividendTaxRow(
                  label: 'Davon anrechenbare Quellensteuer',
                  value: tax.creditableWithholdingTax,
                  currency: accountCurrency,
                  informational: true,
                ),
              _DividendTaxRow(
                label: 'Kapitalertragsteuer ($germanCapitalGainsTaxRate %)',
                value: -tax.germanCapitalTax,
                currency: accountCurrency,
              ),
              _DividendTaxRow(
                label:
                    'Solidaritätszuschlag ($solidaritySurchargeRate % auf Kapitalertragsteuer)',
                value: -tax.solidaritySurcharge,
                currency: accountCurrency,
              ),
              if (tax.churchTax > 0)
                _DividendTaxRow(
                  label: 'Kirchensteuer',
                  value: -tax.churchTax,
                  currency: accountCurrency,
                ),
              if (tax.allowanceUsed > 0)
                _DividendTaxRow(
                  label: 'Genutzter Freistellungsauftrag',
                  value: tax.allowanceUsed,
                  currency: accountCurrency,
                  informational: true,
                ),
              const Divider(height: 18),
              _DividendTaxRow(
                label: 'Netto',
                value: tax.net,
                currency: accountCurrency,
                emphasized: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fertig'),
        ),
      ],
    );
  },
);

class _DividendTaxRow extends StatelessWidget {
  const _DividendTaxRow({
    required this.label,
    required this.value,
    required this.currency,
    this.emphasized = false,
    this.informational = false,
  });

  final String label;
  final double value;
  final String currency;
  final bool emphasized;
  final bool informational;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelWidget = Text(
          label,
          style: TextStyle(
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            color: informational
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        );
        Widget amount(double value, String currency) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            _signedMoney(value, currency),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              color: value < 0 ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        );
        final valueWidget = amount(value, currency);
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [labelWidget, const SizedBox(height: 5), valueWidget],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: labelWidget),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: valueWidget),
          ],
        );
      },
    ),
  );
}

String _signedMoney(double value, String currency) =>
    '${value < 0 ? '−' : ''}${money(value.abs(), currency: currency)}';

Future<void> _showScheduleEditor(
  BuildContext context,
  WidgetRef ref, {
  required Investment investment,
  DividendSchedule? schedule,
  required String baseCurrency,
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
  final currency = TextEditingController(
    text: schedule?.currency ?? investment.dividendCurrency,
  );
  final exchangeRate = TextEditingController(
    text: (schedule?.exchangeRate ?? investment.dividendExchangeRate)
        .toString(),
  );
  final taxRate = TextEditingController(
    text:
        (schedule?.withholdingTaxRate ?? investment.dividendWithholdingTaxRate)
            .toString(),
  );
  final key = GlobalKey<FormState>();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Auszahlung für ${investment.name}'),
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
                    SearchableDropdownButtonFormField<int>(
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
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Dividende je Aktie und Auszahlung',
                      suffixText: currency.text.trim().toUpperCase(),
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
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
                          : 'Ex-Datum ${DateFormat('dd.MM.yyyy').format(exDate!)}',
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
                          : 'Zahlung ${DateFormat('dd.MM.yyyy').format(paymentDate!)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchableDropdownButtonFormField<String>(
                    initialValue: currency.text.trim().toUpperCase(),
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Währung'),
                    items:
                        <String>{
                              ...supportedIsoCurrencies,
                              currency.text.trim().toUpperCase(),
                            }
                            .where((value) => value.isNotEmpty)
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setDialogState(
                      () => currency.text = value ?? currency.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: exchangeRate,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Umrechnung zu $baseCurrency',
                      helperText:
                          '1 ${currency.text.trim().toUpperCase()} = ? $baseCurrency',
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
                      return parsed == null || parsed <= 0
                          ? 'Bitte einen positiven Kurs eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: taxRate,
                    readOnly: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quellensteuer',
                      suffixText: '%',
                      helperText:
                          'Wird über das Land in der Administration festgelegt.',
                    ),
                    validator: (value) {
                      final parsed = parseAmount(value);
                      return parsed == null || parsed < 0 || parsed > 100
                          ? 'Wert zwischen 0 und 100 eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final gross = parseAmount(amount.text) ?? 0;
                      final rate = parseAmount(exchangeRate.text) ?? 0;
                      final tax = parseAmount(taxRate.text) ?? 0;
                      final allowance =
                          ref
                              .read(preferencesProvider)
                              .valueOrNull
                              ?.taxAllowance ??
                          1000;
                      final sourceCurrency = currency.text.trim().toUpperCase();
                      final result = calculateGermanDividendTax(
                        grossAmount: gross * investment.quantity,
                        exchangeRate: rate,
                        withholdingTaxRate: tax,
                        allowanceRemaining: allowance,
                      );
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Auszahlungsweg für die Position',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${investment.quantity.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '')} Stück × '
                                '${amount.text.trim()} $sourceCurrency = '
                                '${money(result.grossSource, currency: sourceCurrency)} brutto',
                              ),
                              Text(
                                '− ${money(result.withholdingTaxSource, currency: sourceCurrency)} Quellensteuer = '
                                '${money(result.grossSource - result.withholdingTaxSource, currency: sourceCurrency)}'
                                ' × ${rate.toStringAsFixed(4)} = '
                                '${money(result.gross - result.withholdingTax, currency: baseCurrency)}',
                              ),
                              Text(
                                '− ${money(result.germanCapitalTax, currency: baseCurrency)} Kapitalertragsteuer · '
                                '− ${money(result.solidaritySurcharge, currency: baseCurrency)} Soli',
                              ),
                              Text(
                                '${money(result.net, currency: baseCurrency)} netto',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
            amountPerShare: parseAmount(amount.text)!,
            exDate: Value(months.length == 1 ? exDate : old?.exDate),
            paymentDate: Value(
              months.length == 1 ? paymentDate : old?.paymentDate,
            ),
            paymentYear: Value(
              (paymentDate ?? exDate)?.year ?? DateTime.now().year,
            ),
            currency: Value(currency.text.trim().toUpperCase()),
            exchangeRate: Value(parseAmount(exchangeRate.text)!),
            withholdingTaxRate: Value(parseAmount(taxRate.text)!),
            createdAt: old?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }
    }
  }
  amount.dispose();
  currency.dispose();
  exchangeRate.dispose();
  taxRate.dispose();
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
