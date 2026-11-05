import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/budget_period.dart';
import 'package:wealthflow_core/finance/dividend_math.dart';
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const _defaultCardOrder = [
    'portfolio',
    'dividends',
    'cashflow',
    'vehicles',
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
    final converter = ref.watch(currencyConverterProvider);
    final derivedAccountBalance = accounts.fold<double>(
      0,
      (sum, account) =>
          sum +
          converter.toBase(
            accountBalanceAt(
              account: account,
              date: monthEnd,
              histories: balanceHistories,
              entries: entries,
              investments: investments,
              purchases: purchases,
              sales: sales,
            ),
            account.currency,
          ),
    );
    final derivedPortfolio =
        investments.fold<double>(
          0,
          (sum, item) =>
              sum +
              converter.investmentValue(
                item,
                quantity: investmentSharesAt(
                  investment: item,
                  date: monthEnd,
                  purchases: purchases,
                  sales: sales,
                ),
              ),
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
              converter.toBase(
                quantity * item.purchasePrice +
                    (item.quantity <= 0
                        ? 0
                        : item.fees * quantity / item.quantity),
                item.instrumentCurrency,
              );
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
    final wealth = WealthColors.of(context);
    final netWorth = accountBalance + portfolio;
    final previousMonthEnd = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
    ).subtract(const Duration(microseconds: 1));
    final previousSnapshot = snapshots
        .where((snapshot) => !snapshot.capturedAt.isAfter(previousMonthEnd))
        .lastOrNull;
    final now = DateTime.now();
    final plannedExpenses = thisMonth
        .where((entry) => !entry.isIncome && entry.bookingDate.isAfter(now))
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final positions = investments
        .where(
          (item) =>
              investmentSharesAt(
                investment: item,
                date: monthEnd,
                purchases: purchases,
                sales: sales,
              ) >
              0,
        )
        .length;
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 600 ? 16.0 : 24.0;
    final hero = _NetWorthHero(
      netWorth: netWorth,
      change: previousSnapshot == null
          ? null
          : netWorth - previousSnapshot.totalNetWorth,
      previousMonth: _dashboardMonths[previousMonthEnd.month - 1],
      accounts: accountBalance,
      portfolio: portfolio,
      tangible: vehicleValue,
      snapshots: snapshots,
      onTap: () => openFinance(ref, 0),
    );
    final month = _MonthCard(
      month: _selectedMonth,
      income: income,
      expenses: expenses,
      planned: plannedExpenses,
      onTap: () => selectShellDestination(ref, 2),
    );
    final recent = _RecentEntries(
      entries: entries,
      onShowAll: () => selectShellDestination(ref, 2),
    );
    final upcoming = _Upcoming(
      entries: entries,
      schedules: schedules,
      investments: investments,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Eyebrow(
                  '${weekdayName(now)}, ${now.day}. ${_dashboardMonths[now.month - 1]}',
                  color: wealth.muted,
                ),
              ),
              PageHeader(
                title:
                    '${_greeting(now)}, ${user?.displayName.split(' ').first ?? 'du'}',
                action: _MonthSwitcher(
                  month: _selectedMonth,
                  onChanged: (value) => setState(() => _selectedMonth = value),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 16.0;
                  if (constraints.maxWidth < 980) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        hero,
                        const SizedBox(height: gap),
                        month,
                        const SizedBox(height: gap),
                        recent,
                        const SizedBox(height: gap),
                        upcoming,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hero,
                            const SizedBox(height: gap),
                            recent,
                          ],
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            month,
                            const SizedBox(height: gap),
                            upcoming,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              SectionTitle(
                'Kennzahlen',
                action: PopupMenuButton<String>(
                  tooltip: 'Kennzahlen sortieren',
                  icon: const Icon(Icons.sort_rounded),
                  initialValue: _sortMode,
                  onSelected: _setSortMode,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'default',
                      child: Text('Standardreihenfolge'),
                    ),
                    PopupMenuItem(
                      value: 'custom',
                      child: Text('Eigene Reihenfolge'),
                    ),
                    PopupMenuItem(
                      value: 'alphabetical',
                      child: Text('Alphabetisch'),
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 560
                      ? 1
                      : constraints.maxWidth < 980
                      ? 2
                      : 4;
                  const spacing = 16.0;
                  final width =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  final performance = invested == 0
                      ? null
                      : (portfolio - invested) / invested * 100;
                  final cards = <({String key, String title, Widget child})>[
                    (
                      key: 'portfolio',
                      title: 'Depotwert',
                      child: MetricCard(
                        title: 'Depotwert',
                        value: money(portfolio),
                        caption: performance == null
                            ? '$positions Positionen'
                            : '${performance >= 0 ? '+' : '−'} ${performance.abs().toStringAsFixed(2).replaceAll('.', ',')} % seit Kauf',
                        captionColor: performance == null
                            ? null
                            : wealth.amount(income: performance >= 0),
                        icon: Icons.show_chart_rounded,
                        onTap: () => openFinance(ref, 1),
                      ),
                    ),
                    (
                      key: 'dividends',
                      title: 'Dividenden p. a.',
                      child: MetricCard(
                        title: 'Dividenden p. a.',
                        value: money(yearlyDividend),
                        caption: '${money(monthlyDividend)} pro Monat',
                        icon: Icons.payments_outlined,
                        onTap: () => openFinance(ref, 2),
                      ),
                    ),
                    (
                      key: 'cashflow',
                      title: 'Freier Cashflow',
                      child: MetricCard(
                        title: 'Freier Cashflow',
                        value: signedMoney(
                          income - expenses,
                          income: income >= expenses,
                        ),
                        caption: 'Einnahmen minus Ausgaben',
                        icon: Icons.waterfall_chart_rounded,
                        color: wealth.amount(income: income >= expenses),
                        onTap: () => selectShellDestination(ref, 2),
                      ),
                    ),
                    (
                      key: 'vehicles',
                      title: 'Inkl. Fahrzeuge',
                      child: MetricCard(
                        title: 'Inkl. Fahrzeuge',
                        value: money(netWorth + vehicleValue),
                        caption: '${money(vehicleValue)} Fahrzeugwert',
                        icon: Icons.directions_car_outlined,
                        color: wealth.neutral,
                        onTap: () => selectShellDestination(ref, 5),
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
                              indexed.$2.child,
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
    final accountColor = WealthColors.of(context).chart[1];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vermögensverlauf',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                    style: TextStyle(
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
                  _dashboardMonthLabel(month),
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

class _NetWorthHero extends StatelessWidget {
  const _NetWorthHero({
    required this.netWorth,
    required this.change,
    required this.previousMonth,
    required this.accounts,
    required this.portfolio,
    required this.tangible,
    required this.snapshots,
    required this.onTap,
  });

  final double netWorth;
  final double? change;
  final String previousMonth;
  final double accounts;
  final double portfolio;
  final double tangible;
  final List<NetWorthSnapshot> snapshots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final text = Theme.of(context).textTheme;
    final visible = snapshots.length > 90
        ? snapshots.sublist(snapshots.length - 90)
        : snapshots;
    final base = netWorth - (change ?? 0);
    final percent = change == null || base == 0 ? null : change! / base * 100;
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
              const Eyebrow('Nettovermögen'),
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
                  '${signedMoney(change!, income: change! >= 0)}'
                  '${percent == null ? '' : ' (${percent >= 0 ? '+' : '−'}${percent.abs().toStringAsFixed(1).replaceAll('.', ',')} %)'}'
                  ' seit $previousMonth',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.amount(income: change! >= 0),
                  ),
                ),
              ],
              if (visible.length >= 2) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 96,
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (final item in visible.indexed)
                              FlSpot(item.$1.toDouble(), item.$2.totalNetWorth),
                          ],
                          isCurved: true,
                          preventCurveOverShooting: true,
                          barWidth: 2.5,
                          color: Theme.of(context).colorScheme.primary,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .18),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: figure('Konten', accounts, colors.chart[0])),
                  const SizedBox(width: 12),
                  Expanded(child: figure('Depot', portfolio, colors.chart[2])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: figure('Fahrzeuge', tangible, colors.chart[1]),
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

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.income,
    required this.expenses,
    required this.planned,
    required this.onTap,
  });

  final DateTime month;
  final double income;
  final double expenses;
  final double planned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final saved = income - expenses;
    final rate = income <= 0 ? null : saved / income;
    final now = DateTime.now();
    final current = month.year == now.year && month.month == now.month;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    Widget line(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: colors.muted)),
          ),
          value,
        ],
      ),
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
                  Expanded(
                    child: Text(
                      _dashboardMonths[month.month - 1],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (current)
                    Text(
                      'Tag ${now.day} von $days',
                      style: TextStyle(fontSize: 12, color: colors.muted),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rate == null ? '–' : '${(rate * 100).toStringAsFixed(0)} %',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Sparquote',
                      style: TextStyle(color: colors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (rate ?? 0).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: colors.neutralSoft,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              line('Einnahmen', AmountText(income, income: true)),
              line('Ausgaben', AmountText(expenses, income: false)),
              if (planned > 0)
                line(
                  'Davon noch geplant',
                  Text(
                    signedMoney(planned, income: false),
                    style: TextStyle(
                      color: colors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Divider(height: 18, color: colors.border),
              line(
                'Übrig',
                AmountText(
                  saved.abs(),
                  income: saved >= 0,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.dateBadge,
  });

  final String title;
  final String subtitle;
  final Widget amount;
  final Widget icon;
  final DateTime? dateBadge;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (dateBadge != null)
            Container(
              width: 40,
              height: 44,
              decoration: BoxDecoration(
                color: colors.neutralSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shortMonthName(dateBadge!).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.muted,
                    ),
                  ),
                  Text(
                    '${dateBadge!.day}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          amount,
        ],
      ),
    );
  }
}

Widget _entryIcon(BuildContext context, LedgerEntry entry) {
  final colors = WealthColors.of(context);
  final linked = entry.sourceType == 'transfer' || entry.sourceType == 'saving';
  if (linked) {
    return IconTile(
      icon: entry.sourceType == 'saving'
          ? Icons.savings_outlined
          : Icons.swap_horiz_rounded,
      background: colors.neutralSoft,
      foreground: colors.neutral,
    );
  }
  return IconTile(
    icon: entry.sourceType == 'vehicle'
        ? Icons.directions_car_outlined
        : entry.isIncome
        ? Icons.south_west_rounded
        : Icons.north_east_rounded,
    background: entry.isIncome ? colors.incomeSoft : colors.expenseSoft,
    foreground: entry.isIncome ? colors.income : colors.expense,
  );
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries({required this.entries, required this.onShowAll});

  final List<LedgerEntry> entries;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final recent =
        entries
            .where(
              (entry) =>
                  !entry.bookingDate.isAfter(now) &&
                  // Show each transfer once, from the paying account.
                  !(entry.isIncome &&
                      (entry.sourceType == 'transfer' ||
                          entry.sourceType == 'saving')),
            )
            .toList()
          ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Letzte Buchungen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: onShowAll, child: const Text('Alle')),
              ],
            ),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Noch keine Buchungen. Tippe auf +, um die erste zu erfassen.',
                  style: TextStyle(color: WealthColors.of(context).muted),
                ),
              ),
            for (final entry in recent.take(5))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _EntryRow(
                  title: entry.sourceType == 'transfer'
                      ? 'Umbuchung'
                      : entry.merchant.isEmpty
                      ? (entry.description.isEmpty
                            ? entry.category
                            : entry.description)
                      : entry.merchant,
                  subtitle: [
                    if (entry.category.isNotEmpty) entry.category,
                    _dayLabel(entry.bookingDate),
                    if (entry.recurrenceId.isNotEmpty) 'Serie',
                  ].join(' · '),
                  icon: _entryIcon(context, entry),
                  amount: AmountText(
                    entry.amount,
                    income: entry.isIncome,
                    neutral:
                        entry.sourceType == 'transfer' ||
                        entry.sourceType == 'saving',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Upcoming extends StatelessWidget {
  const _Upcoming({
    required this.entries,
    required this.schedules,
    required this.investments,
  });

  final List<LedgerEntry> entries;
  final List<DividendSchedule> schedules;
  final List<Investment> investments;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final until = now.add(const Duration(days: 45));
    final items =
        <({DateTime date, String title, String subtitle, Widget amount})>[
          for (final entry in entries)
            if (entry.bookingDate.isAfter(now) &&
                entry.bookingDate.isBefore(until) &&
                !(entry.isIncome &&
                    (entry.sourceType == 'transfer' ||
                        entry.sourceType == 'saving')))
              (
                date: entry.bookingDate,
                title: entry.merchant.isEmpty
                    ? (entry.description.isEmpty
                          ? entry.category
                          : entry.description)
                    : entry.merchant,
                subtitle: [
                  if (entry.category.isNotEmpty) entry.category,
                  if (entry.recurrenceId.isNotEmpty) 'Serie',
                ].join(' · '),
                amount: AmountText(
                  entry.amount,
                  income: entry.isIncome,
                  neutral:
                      entry.sourceType == 'transfer' ||
                      entry.sourceType == 'saving',
                ),
              ),
          for (final schedule in schedules)
            if (schedule.paymentDate case final date?
                when date.isAfter(now) && date.isBefore(until))
              if (investments
                      .where((item) => item.id == schedule.investmentId)
                      .firstOrNull
                  case final investment? when investment.quantity > 0)
                (
                  date: date,
                  title: 'Dividende ${investment.name}',
                  subtitle: 'erwartet, vor Steuern',
                  amount: AmountText(
                    schedule.amountPerShare *
                        investment.quantity *
                        schedule.exchangeRate,
                    income: true,
                  ),
                ),
        ]..sort((a, b) => a.date.compareTo(b.date));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Demnächst',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'In den nächsten Wochen ist nichts geplant.',
                  style: TextStyle(color: WealthColors.of(context).muted),
                ),
              ),
            for (final item in items.take(4))
              _EntryRow(
                title: item.title,
                subtitle: item.subtitle.isEmpty
                    ? _dayLabel(item.date)
                    : item.subtitle,
                amount: item.amount,
                icon: const SizedBox.shrink(),
                dateBadge: item.date,
              ),
          ],
        ),
      ),
    );
  }
}
