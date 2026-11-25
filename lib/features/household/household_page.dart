import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/budget_period.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../search/search_page.dart';
import 'standing_orders_page.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';
part 'entry_editor.dart';

class HouseholdPage extends ConsumerStatefulWidget {
  const HouseholdPage({super.key});

  @override
  ConsumerState<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends ConsumerState<HouseholdPage> {
  late DateTime _selectedMonth = _month(DateTime.now());
  String _query = '';
  String _category = 'Alle';
  bool _showFilters = false;
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final asyncEntries = ref.watch(ledgerEntriesProvider);
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final balanceHistories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final investments =
        ref.watch(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final sales =
        ref.watch(portfolioSalesProvider).valueOrNull ??
        const <PortfolioSale>[];
    final entries = asyncEntries.valueOrNull ?? const <LedgerEntry>[];
    final physicalAssets =
        ref.watch(physicalAssetsProvider).valueOrNull ??
        const <PhysicalAsset>[];
    final masterData =
        ref.watch(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
    final categories = {
      ..._categories.skip(1),
      ...masterData
          .where((item) => item.kind == 'category')
          .map((item) => item.value),
    }.toList()..sort();
    final bookingAccounts = householdAccounts(
      accounts,
      investments: investments,
      physicalAssets: physicalAssets,
    );
    final monthEnd = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    ).subtract(const Duration(microseconds: 1));
    double balanceAtMonthEnd(Account account) => accountBalanceAt(
      account: account,
      date: monthEnd,
      histories: balanceHistories,
      entries: entries,
      investments: investments,
      purchases: purchases,
      sales: sales,
    );
    final selectedAccountId = _effectiveAccountId(bookingAccounts, preference);
    final phone = MediaQuery.sizeOf(context).width < 600;
    final padding = phone ? 16.0 : 24.0;
    final newEntry = selectedAccountId == null
        ? null
        : () => showEntryEditor(
            context,
            ref,
            initialDate: _initialBookingDate,
            defaultAccountId: selectedAccountId,
          );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1220),
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            if (phone) ...[
              PageHeader(
                title: 'Haushalt',
                actionInline: true,
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => showSearchOverlay(context, ref),
                      icon: const Icon(Icons.search_rounded),
                      tooltip: 'Suchen',
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _showFilters = !_showFilters),
                      isSelected: _showFilters,
                      icon: Badge(
                        isLabelVisible:
                            !_showFilters &&
                            (_query.isNotEmpty || _category != 'Alle'),
                        smallSize: 8,
                        child: const Icon(Icons.tune_rounded),
                      ),
                      tooltip: 'Filter',
                    ),
                    const _HouseholdMenu(),
                  ],
                ),
              ),
              if (bookingAccounts.isNotEmpty)
                _AccountRow(
                  accounts: bookingAccounts,
                  selectedId: selectedAccountId,
                  balanceOf: balanceAtMonthEnd,
                  onSelected: _selectAccount,
                ),
            ] else
              PageHeader(
                title: 'Haushalt',
                action: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (bookingAccounts.isNotEmpty)
                      SizedBox(
                        width: 270,
                        child: SearchableDropdownButtonFormField<String>(
                          key: ValueKey(selectedAccountId),
                          initialValue: selectedAccountId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Haushaltskonto',
                            prefixIcon: Icon(Icons.account_balance_rounded),
                          ),
                          items: bookingAccounts
                              .map(
                                (account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(
                                    '${account.label} · ${money(balanceAtMonthEnd(account))}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _selectAccount,
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: newEntry,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Buchung'),
                    ),
                    const _HouseholdMenu(),
                  ],
                ),
              ),
            if (bookingAccounts.isEmpty) ...[
              const _MissingAccountHint(),
              const SizedBox(height: 14),
            ],
            _MonthNavigation(
              selected: _selectedMonth,
              onSelected: (value) => setState(() => _selectedMonth = value),
            ),
            const SizedBox(height: 14),
            if (!phone || _showFilters)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: phone ? double.infinity : 280,
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _query = value.toLowerCase()),
                      decoration: const InputDecoration(
                        labelText: 'Quelle oder Beschreibung',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: phone ? double.infinity : 210,
                    child: SearchableDropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Kategorie'),
                      items: ['Alle', ...categories]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _category = value ?? 'Alle'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            ...asyncEntries.when<List<Widget>>(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                SizedBox(
                  height: 200,
                  child: LoadErrorMessage(
                    'Buchungen konnten nicht geladen werden',
                    error: error,
                  ),
                ),
              ],
              data: (allEntries) {
                final entries = allEntries
                    .where((entry) => _matches(entry, selectedAccountId))
                    .toList();
                final income = entries
                    .where(
                      (entry) =>
                          entry.isIncome &&
                          entry.sourceType != 'transfer' &&
                          entry.sourceType != 'saving',
                    )
                    .fold<double>(0, (sum, entry) => sum + entry.amount);
                final expense = entries
                    .where(
                      (entry) =>
                          !entry.isIncome &&
                          entry.sourceType != 'transfer' &&
                          entry.sourceType != 'saving',
                    )
                    .fold<double>(0, (sum, entry) => sum + entry.amount);
                final saved = entries
                    .where(
                      (entry) =>
                          !entry.isIncome && entry.sourceType == 'saving',
                    )
                    .fold<double>(0, (sum, entry) => sum + entry.amount);
                return [
                  _MonthSummary(income: income, expense: expense, saved: saved),
                  const SizedBox(height: 16),
                  if (entries.isEmpty)
                    SizedBox(
                      height: 300,
                      child: EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title:
                            'Keine Buchungen im ${monthLabel(_selectedMonth)}',
                        message: allEntries.isEmpty
                            ? 'Erfasse eine einzelne Buchung oder plane eine monatliche Serie.'
                            : 'Lege eine Buchung an oder passe die Filter an.',
                        action: FilledButton.icon(
                          onPressed: newEntry,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Buchung erfassen'),
                        ),
                      ),
                    )
                  else
                    for (final day in _groupByDay(entries)) ...[
                      _DayHeader(day: day.day, entries: day.entries),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < day.entries.length;
                              index++
                            ) ...[
                              _EntryTile(entry: day.entries[index]),
                              if (index < day.entries.length - 1)
                                const Divider(height: 1, indent: 68),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  DateTime get _initialBookingDate {
    final now = DateTime.now();
    return now.year == _selectedMonth.year && now.month == _selectedMonth.month
        ? now
        : DateTime(_selectedMonth.year, _selectedMonth.month);
  }

  String? _effectiveAccountId(
    List<Account> accounts,
    UserPreference? preference,
  ) {
    if (accounts.isEmpty) return null;
    final validIds = accounts.map((e) => e.id).toSet();
    if (_selectedAccountId != null && validIds.contains(_selectedAccountId)) {
      return _selectedAccountId;
    }
    if (preference != null &&
        validIds.contains(preference.selectedHouseholdAccountId)) {
      return preference.selectedHouseholdAccountId;
    }
    return accounts
        .where((account) => account.usageType == 'household')
        .firstOrNull
        ?.id;
  }

  Future<void> _selectAccount(String? accountId) async {
    if (accountId == null) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      await ref
          .read(databaseProvider)
          .selectAccountForUsage(
            userId: userId,
            accountId: accountId,
            usageType: 'household',
          );
      if (mounted) setState(() => _selectedAccountId = accountId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  bool _matches(LedgerEntry entry, String? selectedAccountId) {
    final period = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
    final sameMonth =
        period.year == _selectedMonth.year &&
        period.month == _selectedMonth.month;
    final text = '${entry.merchant} ${entry.description}'.toLowerCase();
    return sameMonth &&
        selectedAccountId != null &&
        entry.accountId == selectedAccountId &&
        text.contains(_query) &&
        (_category == 'Alle' || entry.category == _category);
  }
}

class _MissingAccountHint extends ConsumerWidget {
  const _MissingAccountHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded),
          const Text('Für Buchungen wird ein Haushaltskonto benötigt.'),
          FilledButton.tonalIcon(
            onPressed: () => selectShellDestination(ref, ShellPage.assets),
            icon: const Icon(Icons.account_balance_rounded),
            label: const Text('Konto anlegen'),
          ),
        ],
      ),
    ),
  );
}

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final months = [
      _month(DateTime(selected.year, selected.month - 1)),
      selected,
      _month(DateTime(selected.year, selected.month + 1)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Vorheriger Monat',
              onPressed: () => onSelected(months.first),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            for (var index = 0; index < months.length; index++) ...[
              Expanded(
                child: _MonthButton(
                  month: months[index],
                  selected: index == 1,
                  onTap: () => onSelected(months[index]),
                ),
              ),
              if (index < months.length - 1) const SizedBox(width: 6),
            ],
            IconButton(
              tooltip: 'Nächster Monat',
              onPressed: () => onSelected(months.last),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.month,
    required this.selected,
    required this.onTap,
  });

  final DateTime month;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Material(
      color: selected ? colors.incomeSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            children: [
              Text(
                shortMonthNames[month.month - 1],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colors.income : null,
                ),
              ),
              Text(
                '${month.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.income,
    required this.expense,
    required this.saved,
  });

  final double income;
  final double expense;
  final double saved;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final balance = income - expense;
    final savingsRate = income <= 0
        ? null
        : balance.clamp(0, double.infinity) / income * 100;
    Widget figure(String label, Widget value, {String? tooltip}) {
      final child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.muted)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: value,
          ),
        ],
      );
      return tooltip == null ? child : Tooltip(message: tooltip, child: child);
    }

    const valueStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w800);
    final figures = [
      figure('Einnahmen', AmountText(income, income: true, style: valueStyle)),
      figure('Ausgaben', AmountText(expense, income: false, style: valueStyle)),
      figure(
        'Saldo',
        AmountText(balance.abs(), income: balance >= 0, style: valueStyle),
      ),
      figure(
        'Sparquote',
        Text(
          savingsRate == null
              ? '–'
              : '${savingsRate.toStringAsFixed(1).replaceAll('.', ',')} %',
          style: valueStyle,
        ),
        tooltip: saved > 0
            ? '${money(saved)} wurden als Sparen/Investieren markiert. '
                  'Umbuchungen senken die Sparquote nicht.'
            : 'Umbuchungen zwischen eigenen Konten werden nicht als Ausgabe gewertet.',
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: figures[0]),
                      Expanded(child: figures[1]),
                    ],
                  ),
                  Divider(height: 24, color: colors.border),
                  Row(
                    children: [
                      Expanded(child: figures[2]),
                      Expanded(child: figures[3]),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                for (var index = 0; index < figures.length; index++) ...[
                  Expanded(child: figures[index]),
                  if (index < figures.length - 1)
                    Container(
                      width: 1,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: colors.border,
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

List<({DateTime day, List<LedgerEntry> entries})> _groupByDay(
  List<LedgerEntry> entries,
) {
  final groups = <DateTime, List<LedgerEntry>>{};
  for (final entry in entries) {
    final date = entry.bookingDate;
    groups
        .putIfAbsent(DateTime(date.year, date.month, date.day), () => [])
        .add(entry);
  }
  final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final day in days) (day: day, entries: groups[day]!)];
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.entries});

  final DateTime day;
  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final today = DateTime.now();
    final difference = day
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    final date = shortDate(day);
    final label = switch (difference) {
      0 => 'Heute, $date',
      -1 => 'Gestern, $date',
      1 => 'Morgen, $date',
      _ => '${weekdayName(day)}, $date',
    };
    final total = entries
        .where(
          (entry) =>
              entry.sourceType != 'transfer' && entry.sourceType != 'saving',
        )
        .fold<double>(
          0,
          (sum, entry) => sum + (entry.isIncome ? entry.amount : -entry.amount),
        );
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: .5,
      color: colors.muted,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      child: Row(
        children: [
          Expanded(child: Text(label.toUpperCase(), style: style)),
          if (total != 0)
            Text(signedMoney(total, income: total > 0), style: style),
        ],
      ),
    );
  }
}

const _categories = [
  'Alle',
  'Einkaufen',
  'Wohnen',
  'Auto',
  'Motorrad',
  'Tanken',
  'Laden',
  'Streaming',
  'Versicherungen',
  'Freizeit',
  'Urlaub',
  'Gesundheit',
  'Gehalt',
  'Dividende',
  'Sonstiges',
];

/// Standing orders and budgets, reachable from the household page.
class _HouseholdMenu extends ConsumerWidget {
  const _HouseholdMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    tooltip: 'Mehr',
    icon: const Icon(Icons.more_vert_rounded),
    onSelected: (value) => openMore(ref, value),
    itemBuilder: (_) => const [
      PopupMenuItem(
        value: 'standingOrders',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.event_repeat_rounded),
          title: Text('Daueraufträge'),
        ),
      ),
      PopupMenuItem(
        value: 'budgets',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.donut_large_rounded),
          title: Text('Budgets'),
        ),
      ),
    ],
  );
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positive = entry.isIncome;
    final recurring = entry.recurrenceId.isNotEmpty;
    final fromOrder = entry.id.startsWith('so-');
    final linked =
        entry.sourceType == 'transfer' || entry.sourceType == 'saving';
    final colors = WealthColors.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      onTap: entry.sourceType == 'vehicle'
          ? null
          : () => showEntryEditor(context, ref, entry: entry),
      leading: IconTile(
        icon: entry.sourceType == 'vehicle'
            ? Icons.directions_car_outlined
            : linked
            ? entry.sourceType == 'saving'
                  ? Icons.savings_outlined
                  : Icons.swap_horiz_rounded
            : positive
            ? Icons.south_west_rounded
            : Icons.north_east_rounded,
        background: linked
            ? colors.neutralSoft
            : positive
            ? colors.incomeSoft
            : colors.expenseSoft,
        foreground: linked
            ? colors.neutral
            : positive
            ? colors.income
            : colors.expense,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              entry.merchant.isEmpty ? entry.description : entry.merchant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (recurring)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Tooltip(
                message: fromOrder ? 'Dauerauftrag' : 'Monatliche Serie',
                child: Icon(
                  fromOrder ? Icons.event_repeat_rounded : Icons.repeat_rounded,
                  size: 16,
                  color: colors.muted,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        [
          if (entry.category.isNotEmpty) entry.category,
          if (entry.merchant.isNotEmpty && entry.description.isNotEmpty)
            entry.description,
          if (entry.vehicleId.isNotEmpty) 'Fahrzeug',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: colors.muted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(
            entry.amount,
            income: positive,
            neutral: linked,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (_) => [
              if (entry.sourceType != 'vehicle')
                const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
              if (fromOrder)
                const PopupMenuItem(
                  value: 'standing-order',
                  child: Text('Dauerauftrag bearbeiten'),
                )
              else if (recurring && entry.sourceType != 'vehicle') ...[
                if (!linked)
                  const PopupMenuItem(
                    value: 'edit-series',
                    child: Text('Ganze Serie bearbeiten'),
                  ),
                const PopupMenuItem(
                  value: 'convert',
                  child: Text('In Dauerauftrag umwandeln'),
                ),
              ],
              const PopupMenuItem(value: 'delete', child: Text('Löschen')),
              if (recurring && !fromOrder)
                const PopupMenuItem(
                  value: 'delete-series',
                  child: Text('Ganze Serie löschen'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    if (value == 'edit') {
      await showEntryEditor(context, ref, entry: entry);
      return;
    }
    if (value == 'edit-series') {
      await showEntryEditor(context, ref, entry: entry, editSeries: true);
      return;
    }
    if (value == 'standing-order') {
      final order = ref
          .read(standingOrdersProvider)
          .valueOrNull
          ?.where((item) => item.id == entry.recurrenceId)
          .firstOrNull;
      if (order != null) {
        await showStandingOrderEditor(context, ref, order: order);
      } else {
        openMore(ref, 'standingOrders');
      }
      return;
    }
    if (value == 'convert') {
      await _convertToStandingOrder(context, ref);
      return;
    }
    final series = value == 'delete-series';
    final confirmed = await confirmDelete(
      context,
      title: series ? 'Ganze Serie löschen?' : 'Buchung löschen?',
      message: series
          ? 'Alle geplanten Buchungen dieser Monatsserie werden entfernt.'
          : entry.sourceType == 'transfer' || entry.sourceType == 'saving'
          ? 'Beide Seiten der Umbuchung werden entfernt und beide Kontostände korrigiert.'
          : 'Diese Buchung wird aus allen Auswertungen entfernt.',
    );
    if (!confirmed || !context.mounted) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final database = ref.read(databaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final allEntries =
        ref.read(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final linked =
        (entry.sourceType == 'transfer' || entry.sourceType == 'saving') &&
        entry.sourceId.isNotEmpty;
    final removed = series
        ? allEntries.where((item) => item.recurrenceId == entry.recurrenceId)
        : linked
        ? allEntries.where((item) => item.sourceId == entry.sourceId)
        : [entry];
    final restorable = removed.toList();
    final deleted = await saveWithFeedback(
      context,
      () async {
        if (series) {
          await database.deleteLedgerSeries(entry.recurrenceId, userId);
        } else if (linked) {
          await database.deleteLinkedLedgerEntries(entry.sourceId, userId);
        } else {
          await database.deleteLedgerEntry(entry.id, userId);
        }
      },
      failure: 'Löschen fehlgeschlagen',
      source: 'Buchung löschen',
    );
    if (!deleted) return;
    // Reminders of deleted bookings must not fire any more.
    final removedIds = restorable.map((item) => item.id).toSet();
    final reminders = (await database.watchReminders(userId).first)
        .where((reminder) => removedIds.contains(reminder.ledgerEntryId))
        .toList();
    for (final reminder in reminders) {
      await database.deleteReminder(reminder.id, userId);
      await notifications.cancel(reminder.id);
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(series ? 'Serie gelöscht' : 'Buchung gelöscht'),
          persist: false,
          duration: const Duration(seconds: 6),
          action: restorable.isEmpty
              ? null
              : SnackBarAction(
                  label: 'Rückgängig',
                  onPressed: () async {
                    await database.restoreLedgerEntries(restorable);
                    for (final reminder in reminders) {
                      await database.saveReminder(
                        reminder
                            .toCompanion(false)
                            .copyWith(
                              deletedAt: const Value(null),
                              updatedAt: Value(DateTime.now().toUtc()),
                            ),
                      );
                      await notifications.schedule(
                        id: reminder.id,
                        title: reminder.title,
                        scheduledAt: reminder.scheduledAt.toLocal(),
                      );
                    }
                  },
                ),
        ),
      );
  }
}

extension on _EntryTile {
  Future<void> _convertToStandingOrder(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.event_repeat_rounded),
        title: const Text('In Dauerauftrag umwandeln?'),
        content: const Text(
          'Bereits gebuchte Monate bleiben. Die geplanten Buchungen der '
          'Serie werden entfernt; der Dauerauftrag legt sie ab jetzt '
          'jeden Monat selbst an, ohne festes Ende.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Umwandeln'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final done = await saveWithFeedback(
      context,
      () => ref
          .read(databaseProvider)
          .convertSeriesToStandingOrder(entry.recurrenceId, userId),
      failure: 'Umwandeln fehlgeschlagen',
      source: 'Serie umwandeln',
    );
    if (!done) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Serie ist jetzt ein Dauerauftrag'),
        action: SnackBarAction(
          label: 'Anzeigen',
          onPressed: () => openMore(ref, 'standingOrders'),
        ),
      ),
    );
  }
}
