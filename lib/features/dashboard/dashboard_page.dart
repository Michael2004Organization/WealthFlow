import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/budget_period.dart';
import 'package:wealthflow_core/finance/category_budget.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';
import 'package:wealthflow_core/finance/free_to_spend.dart';
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';

import '../../app/app_lifecycle_guard.dart';
import '../../app/app_theme.dart';
import '../../app/design.dart';
import '../../app/app_shell.dart' show desktopBreakpoint;
import '../../core/providers.dart';
import '../../core/security/device_security.dart';
import '../finance/allocation_card.dart';
import 'cockpit.dart';
import '../finance/dividend_prompt.dart';
import '../household/budgets_page.dart';
import '../household/standing_orders_page.dart';
import '../search/search_page.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/privacy_button.dart';
import '../../core/widgets/design_switcher.dart';
part 'dashboard_cards.dart';
part 'dashboard_charts.dart';

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
  bool _showLightDesignHint = false;

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
    final standingOrders =
        ref.watch(standingOrdersProvider).valueOrNull ??
        const <StandingOrder>[];
    final budgets =
        ref.watch(categoryBudgetsProvider).valueOrNull ??
        const <CategoryBudget>[];
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
    final taxAllowance =
        ref.watch(preferencesProvider).valueOrNull?.taxAllowance ?? 1000;
    final accountCurrencies = {
      for (final account in accounts) account.id: account.currency,
    };
    // Several cards need the same years; compute each once per build.
    final projections = <int, List<ProjectedDividend>>{};
    List<ProjectedDividend> projectionFor(int year) => projections.putIfAbsent(
      year,
      () => buildDividendProjection(
        investments
            .where((item) => wasHeldDuringYear(item, purchases, sales, year))
            .toList(),
        schedules,
        taxAllowance,
        year,
        purchases,
        sales,
        accountCurrencies,
        includePhysicalAssets:
            ref
                .watch(preferencesProvider)
                .valueOrNull
                ?.includePhysicalAssetsInTaxAllowance ??
            false,
      ),
    );
    final yearlyDividend = projectionFor(
      _selectedMonth.year,
    ).fold<double>(0, (sum, payment) => sum + payment.tax.net);
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
    final plannedExpenses =
        thisMonth
            .where((entry) => !entry.isIncome && entry.bookingDate.isAfter(now))
            .fold<double>(0, (sum, entry) => sum + entry.amount) +
        plannedStandingOrderBookings(
              standingOrders,
              // Only due dates inside the shown month.
              after: _selectedMonth.isAfter(now)
                  ? DateTime(_selectedMonth.year, _selectedMonth.month, 0)
                  : now,
              through: monthEnd,
            )
            .where((item) => item.order.kind != 'income')
            .fold<double>(0, (sum, item) => sum + item.order.amount);
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
      previousMonth: monthNames[previousMonthEnd.month - 1],
      accounts: accountBalance,
      portfolio: portfolio,
      snapshots: snapshots,
      onTap: () => openFinance(ref, 0),
    );
    final month = _MonthCard(
      month: _selectedMonth,
      income: income,
      expenses: expenses,
      planned: plannedExpenses,
      onTap: () => selectShellDestination(ref, ShellPage.household),
    );
    final recent = _RecentEntries(
      entries: entries,
      onShowAll: () => selectShellDestination(ref, ShellPage.household),
    );
    final previousMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    );
    final budgetCard = budgets.isEmpty
        ? null
        : _BudgetsCard(
            progress: buildBudgetProgress(budgets, entries, _selectedMonth),
            // In the first week a short look back at the month before.
            review:
                now.day <= 7 &&
                    _selectedMonth.year == now.year &&
                    _selectedMonth.month == now.month
                ? (
                    month: previousMonth,
                    progress: buildBudgetProgress(
                      budgets,
                      entries,
                      previousMonth,
                    ),
                  )
                : null,
            onShowAll: () => openMore(ref, 'budgets'),
          );
    final receipts = ref.watch(dividendReceiptsProvider).valueOrNull;
    // Asked only once the confirmations are loaded, so nothing flashes.
    final pendingPayouts = receipts == null
        ? const <ProjectedDividend>[]
        : pendingDividends(
            [
              if (now.month == 1) ...projectionFor(now.year - 1),
              ...projectionFor(now.year),
            ],
            receipts,
            today: now,
          );
    final upcoming = _Upcoming(
      entries: entries,
      standingOrders: plannedStandingOrderBookings(
        standingOrders,
        after: now,
        through: now.add(const Duration(days: 45)),
      ),
      dividends: [
        ...projectionFor(now.year),
        if (now.month == 12) ...projectionFor(now.year + 1),
      ].where((payment) => payment.paymentDateKnown).toList(),
    );

    final design = DesignStyle.of(context).design;
    final cockpit = _buildCockpitData(
      now: now,
      accounts: accounts,
      investments: investments,
      physicalAssets: physicalAssets,
      balanceHistories: balanceHistories,
      entries: entries,
      purchases: purchases,
      sales: sales,
      standingOrders: standingOrders,
      budgets: budgets,
      snapshots: snapshots,
      netWorth: netWorth,
      netWorthChange: previousSnapshot == null
          ? null
          : netWorth - previousSnapshot.totalNetWorth,
      income: income,
      expenses: expenses,
      dividends: [
        ...projectionFor(now.year),
        if (now.month == 12) ...projectionFor(now.year + 1),
      ],
      pendingPayouts: pendingPayouts.length,
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
                  '${weekdayName(now)}, ${now.day}. ${monthNames[now.month - 1]}',
                  color: wealth.muted,
                ),
              ),
              PageHeader(
                title:
                    '${_greeting(now)}, ${user?.displayName.split(' ').first ?? 'du'}',
                // Wraps on narrow phones instead of overflowing.
                action: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (width < desktopBreakpoint)
                      IconButton(
                        onPressed: () => showSearchOverlay(context, ref),
                        icon: const Icon(Icons.search_rounded),
                        tooltip: 'Suchen',
                      ),
                    if (width < desktopBreakpoint) const DesignSwitcher(),
                    if (width < desktopBreakpoint) const PrivacyButton(),
                    _MonthSwitcher(
                      month: _selectedMonth,
                      onChanged: (value) =>
                          setState(() => _selectedMonth = value),
                    ),
                  ],
                ),
              ),
              if (pendingPayouts.isNotEmpty) ...[
                DividendPromptCard(pending: pendingPayouts),
                const SizedBox(height: 16),
              ],
              if (_showLightDesignHint) ...[
                _LightDesignHint(
                  onTry: () => _answerLightDesignHint(tryIt: true),
                  onDismiss: () => _answerLightDesignHint(tryIt: false),
                ),
                const SizedBox(height: 16),
              ],
              Cockpit(data: cockpit),
              const SizedBox(height: 16),
              // Bento and Terminal show all of this inside the cockpit; the
              // classic design keeps its familiar cards below.
              if (design == AppDesign.classic)
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
                          if (budgetCard != null) ...[
                            const SizedBox(height: gap),
                            budgetCard,
                          ],
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
                              if (budgetCard != null) ...[
                                const SizedBox(height: gap),
                                budgetCard,
                              ],
                              const SizedBox(height: gap),
                              upcoming,
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 16),
              const AllocationCard(),
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
                        onTap: () =>
                            selectShellDestination(ref, ShellPage.household),
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
                        onTap: () =>
                            selectShellDestination(ref, ShellPage.vehicles),
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
              _MonthlyChart(entries: entries),
            ],
          ),
        ),
      ),
    );
  }

  CockpitData _buildCockpitData({
    required DateTime now,
    required List<Account> accounts,
    required List<Investment> investments,
    required List<PhysicalAsset> physicalAssets,
    required List<AccountBalanceHistory> balanceHistories,
    required List<LedgerEntry> entries,
    required List<InvestmentPurchase> purchases,
    required List<PortfolioSale> sales,
    required List<StandingOrder> standingOrders,
    required List<CategoryBudget> budgets,
    required List<NetWorthSnapshot> snapshots,
    required double netWorth,
    required double? netWorthChange,
    required double income,
    required double expenses,
    required List<ProjectedDividend> dividends,
    required int pendingPayouts,
  }) {
    final converter = ref.read(currencyConverterProvider);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(microseconds: 1));

    // Free until the end of the current month, from the household accounts.
    final household = householdAccounts(
      accounts,
      investments: investments,
      physicalAssets: physicalAssets,
    );
    final balance = household.fold<double>(
      0,
      (sum, account) =>
          sum +
          converter.toBase(
            accountBalanceAt(
              account: account,
              date: now,
              histories: balanceHistories,
              entries: entries,
              investments: investments,
              purchases: purchases,
              sales: sales,
            ),
            account.currency,
          ),
    );
    bool counts(LedgerEntry entry) =>
        entry.sourceType != 'transfer' && entry.sourceType != 'saving';
    final upcomingOrders = plannedStandingOrderBookings(
      standingOrders,
      after: now,
      through: now.add(const Duration(days: 30)),
    );
    final planned =
        entries
            .where(
              (e) =>
                  counts(e) &&
                  !e.isIncome &&
                  e.bookingDate.isAfter(now) &&
                  !e.bookingDate.isAfter(monthEnd),
            )
            .fold<double>(0, (sum, e) => sum + e.amount) +
        upcomingOrders
            .where(
              (item) =>
                  item.order.kind != 'income' && !item.date.isAfter(monthEnd),
            )
            .fold<double>(0, (sum, item) => sum + item.order.amount);
    final budgetProgress = buildBudgetProgress(
      budgets,
      entries,
      DateTime(now.year, now.month),
    );
    final free = calculateFreeToSpend(
      balance: balance,
      plannedExpenses: planned,
      budgets: budgetProgress,
      today: now,
    );

    // Net worth over the last six months.
    final since = DateTime(now.year, now.month - 6, now.day);
    final history = [
      for (final snapshot in snapshots)
        if (snapshot.capturedAt.isAfter(since)) snapshot.totalNetWorth,
      netWorth,
    ];

    // Income and expenses of the last six months.
    final cashflow = [
      for (var back = 5; back >= 0; back--)
        () {
          final month = DateTime(
            _selectedMonth.year,
            _selectedMonth.month - back,
          );
          var monthIncome = 0.0;
          var monthExpenses = 0.0;
          for (final entry in entries) {
            if (!counts(entry)) continue;
            final period = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
            if (period.year != month.year || period.month != month.month) {
              continue;
            }
            if (entry.isIncome) {
              monthIncome += entry.amount;
            } else {
              monthExpenses += entry.amount;
            }
          }
          return CockpitMonth(
            monthNames[month.month - 1].substring(0, 3),
            monthIncome,
            monthExpenses,
          );
        }(),
    ];

    String orderTitle(StandingOrder order) => order.merchant.isNotEmpty
        ? order.merchant
        : order.description.isNotEmpty
        ? order.description
        : order.category;
    final until = now.add(const Duration(days: 30));
    final due = <CockpitDue>[
      for (final (:order, :date) in upcomingOrders)
        if (order.kind != 'transfer' && order.kind != 'saving')
          CockpitDue(
            date: date,
            title: orderTitle(order),
            amount: order.amount,
            income: order.kind == 'income',
          ),
      for (final entry in entries)
        if (counts(entry) &&
            entry.bookingDate.isAfter(now) &&
            entry.bookingDate.isBefore(until))
          CockpitDue(
            date: entry.bookingDate,
            title: entry.merchant.isEmpty ? entry.category : entry.merchant,
            amount: entry.amount,
            income: entry.isIncome,
          ),
      for (final payment in dividends)
        if (payment.paymentDateKnown &&
            payment.date.isAfter(now) &&
            payment.date.isBefore(until))
          CockpitDue(
            date: payment.date,
            title: 'Dividende ${payment.investment.name}',
            amount: payment.tax.net,
            income: true,
          ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    final review = <CockpitReview>[
      if (pendingPayouts > 0)
        CockpitReview(
          pendingPayouts == 1
              ? 'Dividende bestätigen'
              : '$pendingPayouts Dividenden bestätigen',
          (ref) => openFinance(ref, 2),
        ),
      for (final progress in budgetProgress)
        if (progress.ratio > 1)
          CockpitReview(
            'Budget ${progress.budget.category} überzogen',
            (ref) => openMore(ref, 'budgets'),
          ),
      for (final (:order, :date) in upcomingOrders)
        if (order.kind != 'income' &&
            date.difference(now) <= const Duration(days: 3))
          CockpitReview(
            '${orderTitle(order)} fällig am ${date.day}.${date.month}.',
            (ref) => openMore(ref, 'standingOrders'),
          ),
    ];

    final backup = ref.watch(backupStatusProvider).valueOrNull;
    return CockpitData(
      free: free,
      netWorth: netWorth,
      netWorthChange: netWorthChange,
      netWorthHistory: history,
      income: income,
      expenses: expenses,
      cashflow: cashflow,
      due: due,
      budgets: budgetProgress,
      recent: entries
          .where((e) => counts(e) && !e.bookingDate.isAfter(now))
          .take(8)
          .toList(),
      review: review,
      security: CockpitSecurity(
        appLock: ref.watch(appPinProvider).valueOrNull != null,
        lockAfter:
            ref.watch(lockDelayProvider).valueOrNull ??
            AppLifecycleGuard.lockAfter,
        lastBackup: backup?.writtenAt,
        backupFailed: backup != null && !backup.succeeded,
        serverConnected: ref.watch(serverConnectionProvider).isConnected,
      ),
    );
  }

  Future<void> _loadCardLayout(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedOrder = preferences.getStringList(
      'dashboard.cardOrder.$userId',
    );
    final themeMode =
        (await ref.read(databaseProvider).preferencesFor(userId)).themeMode;
    if (!mounted || _loadedForUser != userId) return;
    setState(() {
      _showLightDesignHint =
          themeMode == 'dark' &&
          !(preferences.getBool('dashboard.lightDesignHint.$userId') ?? false);
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

  Future<void> _answerLightDesignHint({required bool tryIt}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    setState(() => _showLightDesignHint = false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dashboard.lightDesignHint.$userId', true);
    if (tryIt) await ref.read(databaseProvider).setThemeMode(userId, 'light');
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
