import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/account_balance_math.dart';
import '../../core/finance/budget_period.dart';
import '../../core/finance/dividend_math.dart';
import '../../core/finance/portfolio_tax_summary.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const _defaultCardOrder = [
    'netWorth',
    'portfolio',
    'income',
    'expenses',
    'savingsRate',
    'dividends',
    'cashflow',
  ];
  late DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  String _sortMode = 'default';
  List<String> _customOrder = [..._defaultCardOrder];
  String? _loadedForUser;

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final investments =
        ref.watch(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
    final physicalAssets =
        ref.watch(allPhysicalAssetsProvider).valueOrNull ??
        const <PhysicalAsset>[];
    final vehicles =
        ref.watch(vehiclesProvider).valueOrNull ?? const <Vehicle>[];
    final schedules =
        ref.watch(dividendSchedulesProvider).valueOrNull ??
        const <DividendSchedule>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final balanceHistories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
    final snapshots =
        ref.watch(netWorthSnapshotsProvider).valueOrNull ??
        const <NetWorthSnapshot>[];
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final sales =
        ref.watch(portfolioSalesProvider).valueOrNull ??
        const <PortfolioSale>[];
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null && _loadedForUser != userId) {
      _loadedForUser = userId;
      Future<void>.microtask(() => _loadCardLayout(userId));
    }
    final user = ref.watch(authControllerProvider).user;
    final monthEnd = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    ).subtract(const Duration(microseconds: 1));
    final derivedAccountBalance = accounts.fold<double>(
      0,
      (sum, account) =>
          sum +
          accountBalanceAt(
            account: account,
            date: monthEnd,
            histories: balanceHistories,
            entries: entries,
            investments: investments,
            purchases: purchases,
            sales: sales,
          ),
    );
    final derivedPortfolio =
        investments.fold<double>(
          0,
          (sum, item) =>
              sum +
              investmentSharesAt(
                    investment: item,
                    date: monthEnd,
                    purchases: purchases,
                    sales: sales,
                  ) *
                  item.currentPrice,
        ) +
        physicalAssets.fold<double>(
          0,
          (sum, item) => sum + _physicalAssetValueAt(item, sales, monthEnd),
        );
    final snapshotAtMonthEnd = snapshots
        .where((snapshot) => !snapshot.capturedAt.isAfter(monthEnd))
        .lastOrNull;
    final accountBalance = balanceHistories.isNotEmpty
        ? derivedAccountBalance
        : snapshotAtMonthEnd?.accountBalance ?? derivedAccountBalance;
    final portfolio = derivedPortfolio;
    final vehicleValue = vehicles.fold<double>(
      0,
      (sum, item) =>
          sum +
          ((item.purchaseDate ?? item.createdAt).isAfter(monthEnd)
              ? 0
              : item.currentValue),
    );
    final invested =
        investments.fold<double>(0, (sum, item) {
          final quantity = investmentSharesAt(
            investment: item,
            date: monthEnd,
            purchases: purchases,
            sales: sales,
          );
          return sum +
              quantity * item.purchasePrice +
              (item.quantity <= 0 ? 0 : item.fees * quantity / item.quantity);
        }) +
        physicalAssets.fold<double>(
          0,
          (sum, item) =>
              sum +
              ((item.purchaseDate ?? item.createdAt).isAfter(monthEnd)
                  ? 0
                  : item.purchasePrice),
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
            (index) => _dashboardDividendForMonth(
              item,
              schedules,
              DateTime(_selectedMonth.year, index + 1),
              purchases,
              sales,
            ),
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
                title: 'Hallo, ${user?.displayName.split(' ').first ?? 'du'}',
                subtitle:
                    'Finanzieller Überblick für ${_dashboardMonthLabel(_selectedMonth)}.',
                action: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 210,
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
                    Card(
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
                                () => _selectedMonth = DateTime(
                                  now.year,
                                  now.month,
                                ),
                              );
                            },
                            icon: const Icon(Icons.today_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 700 ? 1 : 2;
                  const spacing = 16.0;
                  final width =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  final cards = <({String key, String title, Widget child})>[
                    (
                      key: 'netWorth',
                      title: 'Gesamtvermögen',
                      child: _NetWorthPairCard(
                        netWorth: accountBalance + portfolio,
                        netWorthCaption:
                            '${accounts.length} Konten · ${investments.where((item) => investmentSharesAt(investment: item, date: monthEnd, purchases: purchases, sales: sales) > 0).length} Positionen',
                        includingVehicles:
                            accountBalance + portfolio + vehicleValue,
                        vehicleValue: vehicleValue,
                        onNetWorthTap: () => openFinance(ref, 0),
                        onVehiclesTap: () =>
                            ref.read(shellIndexProvider.notifier).state = 5,
                      ),
                    ),
                    (
                      key: 'portfolio',
                      title: 'Depotwert',
                      child: MetricCard(
                        title: 'Depotwert',
                        value: money(portfolio),
                        caption: invested == 0
                            ? 'Noch keine Performance'
                            : '${portfolio >= invested ? '+' : ''}${((portfolio - invested) / invested * 100).toStringAsFixed(2)} % Performance',
                        icon: Icons.trending_up_rounded,
                        color: portfolio >= invested
                            ? Colors.teal
                            : colors.error,
                        onTap: () => openFinance(ref, 1),
                      ),
                    ),
                    (
                      key: 'income',
                      title: 'Einnahmen im Monat',
                      child: MetricCard(
                        title: 'Einnahmen im Monat',
                        value: money(income),
                        caption:
                            '${thisMonth.where((entry) => entry.isIncome).length} Buchungen',
                        icon: Icons.account_balance_rounded,
                        color: Colors.green,
                        onTap: () =>
                            ref.read(shellIndexProvider.notifier).state = 2,
                      ),
                    ),
                    (
                      key: 'expenses',
                      title: 'Ausgaben im Monat',
                      child: MetricCard(
                        title: 'Ausgaben im Monat',
                        value: money(expenses),
                        caption:
                            '${thisMonth.where((entry) => !entry.isIncome).length} Buchungen',
                        icon: Icons.shopping_bag_rounded,
                        color: Colors.orange,
                        onTap: () =>
                            ref.read(shellIndexProvider.notifier).state = 2,
                      ),
                    ),
                    (
                      key: 'savingsRate',
                      title: 'Sparquote',
                      child: MetricCard(
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
                    ),
                    (
                      key: 'dividends',
                      title: 'Dividenden p. a.',
                      child: MetricCard(
                        title: 'Dividenden p. a.',
                        value: money(yearlyDividend),
                        caption: '${money(monthlyDividend)} pro Monat',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                        onTap: () => openFinance(ref, 2),
                      ),
                    ),
                    (
                      key: 'cashflow',
                      title: 'Freier Cashflow',
                      child: MetricCard(
                        title: 'Freier Cashflow',
                        value: money(income - expenses),
                        caption: 'Einnahmen abzüglich Ausgaben',
                        icon: Icons.waterfall_chart_rounded,
                        color: income >= expenses ? Colors.cyan : colors.error,
                        onTap: () =>
                            ref.read(shellIndexProvider.notifier).state = 2,
                      ),
                    ),
                  ];
                  if (_sortMode == 'alphabetical') {
                    cards.sort((a, b) => a.title.compareTo(b.title));
                  } else if (_sortMode == 'custom') {
                    cards.sort(
                      (a, b) => _customOrder
                          .indexOf(a.key)
                          .compareTo(_customOrder.indexOf(b.key)),
                    );
                  }
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final indexed in cards.indexed)
                        SizedBox(
                          width: width,
                          child: Column(
                            children: [
                              if (_sortMode == 'custom')
                                _CardMoveControls(
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
                              SizedBox(height: 238, child: indexed.$2.child),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _NetWorthChart(snapshots: snapshots),
              const SizedBox(height: 16),
              _MonthlyChart(entries: entries),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadCardLayout(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedOrder = preferences.getStringList(
      'dashboard.cardOrder.$userId',
    );
    if (!mounted || _loadedForUser != userId) return;
    setState(() {
      _sortMode =
          preferences.getString('dashboard.sortMode.$userId') ?? 'default';
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
    await preferences.setString('dashboard.sortMode.$userId', _sortMode);
    await preferences.setStringList(
      'dashboard.cardOrder.$userId',
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

double _physicalAssetValueAt(
  PhysicalAsset asset,
  List<PortfolioSale> sales,
  DateTime at,
) {
  final purchaseDate = asset.purchaseDate ?? asset.createdAt;
  if (purchaseDate.isAfter(at)) return 0;
  if (asset.deletedAt != null &&
      !asset.deletedAt!.isAfter(at) &&
      !sales.any(
        (sale) => sale.physicalAssetId == asset.id && !sale.soldAt.isAfter(at),
      )) {
    return 0;
  }
  final laterSales = sales
      .where(
        (sale) => sale.physicalAssetId == asset.id && sale.soldAt.isAfter(at),
      )
      .fold<double>(0, (sum, sale) => sum + sale.quantity);
  return (asset.weightGrams + laterSales) * asset.currentPricePerGram;
}

class _CardMoveControls extends StatelessWidget {
  const _CardMoveControls({
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

class _NetWorthPairCard extends StatelessWidget {
  const _NetWorthPairCard({
    required this.netWorth,
    required this.netWorthCaption,
    required this.includingVehicles,
    required this.vehicleValue,
    required this.onNetWorthTap,
    required this.onVehiclesTap,
  });

  final double netWorth;
  final String netWorthCaption;
  final double includingVehicles;
  final double vehicleValue;
  final VoidCallback onNetWorthTap;
  final VoidCallback onVehiclesTap;

  @override
  Widget build(BuildContext context) => Card(
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _NetWorthHalf(
              title: 'Gesamtvermögen',
              value: money(netWorth),
              caption: netWorthCaption,
              icon: Icons.account_balance_wallet_rounded,
              color: Theme.of(context).colorScheme.primary,
              onTap: onNetWorthTap,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: _NetWorthHalf(
              title: 'Inkl. Fahrzeuge',
              value: money(includingVehicles),
              caption: '${money(vehicleValue)} Fahrzeugwert',
              icon: Icons.directions_car_filled_rounded,
              color: Colors.indigo,
              onTap: onVehiclesTap,
            ),
          ),
        ],
      ),
    ),
  );
}

class _NetWorthHalf extends StatelessWidget {
  const _NetWorthHalf({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const Spacer(),
              const Icon(Icons.arrow_outward_rounded, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 7),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

double _dashboardDividendForMonth(
  Investment investment,
  List<DividendSchedule> schedules,
  DateTime month,
  List<InvestmentPurchase> purchases,
  List<PortfolioSale> sales,
) {
  final paymentDate = DateTime(month.year, month.month, 28, 23, 59, 59);
  final quantity = investmentSharesAt(
    investment: investment,
    date: paymentDate,
    purchases: purchases,
    sales: sales,
  );
  if (quantity <= 0) return 0;
  final exact = schedules.where(
    (row) =>
        row.investmentId == investment.id &&
        row.paymentMonth == month.month &&
        (row.paymentYear == month.year ||
            (row.paymentYear == 0 && month.year == DateTime.now().year)),
  );
  if (exact.isNotEmpty) {
    return exact.fold<double>(
      0,
      (sum, row) => sum + row.amountPerShare * quantity,
    );
  }
  final paymentMonths = dividendPaymentMonths(
    investment.dividendFrequency,
    investment.dividendStartMonth,
  );
  return paymentMonths.contains(month.month)
      ? investment.annualDividend * quantity
      : 0;
}

String _dashboardMonthLabel(DateTime date) =>
    '${_dashboardMonths[date.month - 1]} ${date.year}';

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

class _NetWorthChart extends StatefulWidget {
  const _NetWorthChart({required this.snapshots});

  final List<NetWorthSnapshot> snapshots;

  @override
  State<_NetWorthChart> createState() => _NetWorthChartState();
}

class _NetWorthChartState extends State<_NetWorthChart> {
  bool _includeVehicles = false;

  @override
  Widget build(BuildContext context) {
    final snapshots = widget.snapshots;
    final visible = snapshots.length > 60
        ? snapshots.sublist(snapshots.length - 60)
        : snapshots;
    double totalValue(NetWorthSnapshot snapshot) =>
        snapshot.totalNetWorth + (_includeVehicles ? snapshot.vehicleValue : 0);
    final totalSpots = visible.indexed
        .map((item) => FlSpot(item.$1.toDouble(), totalValue(item.$2)))
        .toList();
    final accountSpots = visible.indexed
        .map((item) => FlSpot(item.$1.toDouble(), item.$2.accountBalance))
        .toList();
    final maximum = visible.fold<double>(
      0,
      (value, item) => totalValue(item) > value ? totalValue(item) : value,
    );
    final leftInterval = maximum <= 0 ? 1.0 : maximum / 4;
    final bottomInterval = visible.length <= 4
        ? 1.0
        : (visible.length / 4).ceilToDouble();
    final totalColor = Theme.of(context).colorScheme.primary;
    const accountColor = Colors.teal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vermögensverlauf',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Tooltip(
                  message: _includeVehicles
                      ? 'Fahrzeugwert ausblenden'
                      : 'Fahrzeugwert einblenden',
                  child: Switch.adaptive(
                    value: _includeVehicles,
                    onChanged: (value) =>
                        setState(() => _includeVehicles = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _includeVehicles
                  ? 'Gesamtvermögen mit Fahrzeugen und Kontostand'
                  : 'Gesamtvermögen ohne Fahrzeuge und Kontostand',
            ),
            if (visible.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  Text(
                    'Gesamt  ${money(totalValue(visible.last))}',
                    style: TextStyle(
                      color: totalColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Konten  ${money(visible.last.accountBalance)}',
                    style: const TextStyle(
                      color: accountColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Stand  ${DateFormat('dd.MM.yyyy').format(visible.last.capturedAt)}',
                  ),
                ],
              ),
            ],
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
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 70,
                              interval: leftInterval,
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
                              reservedSize: 34,
                              interval: bottomInterval,
                              getTitlesWidget: (value, meta) {
                                final index = value.round();
                                if (index < 0 || index >= visible.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat(
                                      'dd.MM.',
                                    ).format(visible[index].capturedAt),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
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
                            color: totalColor,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: totalColor.withValues(alpha: .12),
                            ),
                          ),
                          LineChartBarData(
                            spots: accountSpots,
                            isCurved: true,
                            barWidth: 3,
                            color: accountColor,
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
