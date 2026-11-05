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
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

class HouseholdPage extends ConsumerStatefulWidget {
  const HouseholdPage({super.key});

  @override
  ConsumerState<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends ConsumerState<HouseholdPage> {
  late DateTime _selectedMonth = _month(DateTime.now());
  String _query = '';
  String _category = 'Alle';
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
    final selectedAccountId = _effectiveAccountId(
      bookingAccounts,
      preference,
    );
    final padding = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
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
                  width: 210,
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
            onPressed: () => selectShellDestination(ref, 1),
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

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positive = entry.isIncome;
    final recurring = entry.recurrenceId.isNotEmpty;
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
                message: 'Monatliche Serie',
                child: Icon(
                  Icons.repeat_rounded,
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
              if (recurring && entry.sourceType != 'vehicle' && !linked)
                const PopupMenuItem(
                  value: 'edit-series',
                  child: Text('Ganze Serie bearbeiten'),
                ),
              const PopupMenuItem(value: 'delete', child: Text('Löschen')),
              if (recurring)
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

/// Opens the booking editor from anywhere in the app, on the household
/// account the user last chose.
Future<void> startNewBooking(BuildContext context, WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  final investments =
      ref.read(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
  final physicalAssets =
      ref.read(physicalAssetsProvider).valueOrNull ?? const <PhysicalAsset>[];
  final preference = ref.read(preferencesProvider).valueOrNull;
  final household = householdAccounts(
    accounts,
    investments: investments,
    physicalAssets: physicalAssets,
  );
  final preferred = household
      .where((account) => account.id == preference?.selectedHouseholdAccountId)
      .firstOrNull;
  final account =
      preferred ??
      household.where((item) => item.usageType == 'household').firstOrNull ??
      household.firstOrNull;
  if (account == null) {
    selectShellDestination(ref, 2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lege zuerst ein Haushaltskonto unter Vermögen an.'),
      ),
    );
    return;
  }
  await showEntryEditor(context, ref, defaultAccountId: account.id);
}

Future<void> showEntryEditor(
  BuildContext context,
  WidgetRef ref, {
  LedgerEntry? entry,
  DateTime? initialDate,
  String? defaultAccountId,
  bool editSeries = false,
}) async {
  final vehicles = ref.read(vehiclesProvider).valueOrNull ?? const <Vehicle>[];
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final ledgerEntries =
      ref.read(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
  Future<void> persist(_EntrySubmission result) =>
      _persistSubmission(ref, result, entry: entry, editSeries: editSeries);
  final phone = MediaQuery.sizeOf(context).width < 600;
  Widget editor(BuildContext _) => _EntryEditor(
    entry: entry,
    initialDate: initialDate,
    vehicles: vehicles,
    accounts: accounts,
    defaultAccountId: defaultAccountId,
    masterData: masterData,
    ledgerEntries: ledgerEntries,
    editSeries: editSeries,
    fullscreen: phone,
    onSaveAndNext: entry == null ? persist : null,
  );
  final result = phone
      ? await showModalBottomSheet<_EntrySubmission>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: false,
          builder: editor,
        )
      : await showDialog<_EntrySubmission>(context: context, builder: editor);
  if (result != null && context.mounted) {
    await saveWithFeedback(
      context,
      () => persist(result),
      failure: 'Buchung nicht gespeichert',
      source: 'Buchung speichern',
    );
  }
}

Future<void> _persistSubmission(
  WidgetRef ref,
  _EntrySubmission result, {
  required LedgerEntry? entry,
  required bool editSeries,
}) async {
  final database = ref.read(databaseProvider);
  final userId = ref.read(currentUserIdProvider);
  if (editSeries && entry != null && userId != null) {
    await database.updateLedgerSeries(
      entry.recurrenceId,
      userId,
      result.entries.first,
      edited: entry,
    );
  } else if (entry != null && result.entries.length == 1) {
    await database.saveLedgerEntryWithCounterpart(result.entries.first);
  } else {
    await database.saveLedgerEntries(result.entries);
  }
  if (userId == null) return;
  if (result.reminderTitle != null && result.reminderAt != null) {
    final reminderId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    await database.saveReminder(
      RemindersCompanion.insert(
        id: reminderId,
        userId: userId,
        title: result.reminderTitle!,
        scheduledAt: result.reminderAt!.toUtc(),
        ledgerEntryId: Value(result.entries.first.id.value),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final notifications = ref.read(notificationServiceProvider);
    await notifications.requestPermissions();
    await notifications.schedule(
      id: reminderId,
      title: result.reminderTitle!,
      scheduledAt: result.reminderAt!,
    );
  }
  for (final item in {
    if (result.merchant.isNotEmpty) 'merchant': result.merchant,
    if (result.paymentMethod.isNotEmpty) 'paymentMethod': result.paymentMethod,
    if (result.category.isNotEmpty) 'category': result.category,
  }.entries) {
    await database.saveMasterDatum(
      MasterDataCompanion.insert(
        id: const Uuid().v4(),
        userId: userId,
        kind: item.key,
        value: item.value,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}

class _EntrySubmission {
  const _EntrySubmission(
    this.entries, {
    required this.merchant,
    required this.paymentMethod,
    required this.category,
    this.reminderTitle,
    this.reminderAt,
  });
  final List<LedgerEntriesCompanion> entries;
  final String merchant;
  final String paymentMethod;
  final String category;
  final String? reminderTitle;
  final DateTime? reminderAt;
}

class _EntryEditor extends StatefulWidget {
  const _EntryEditor({
    required this.vehicles,
    required this.accounts,
    required this.defaultAccountId,
    required this.masterData,
    required this.ledgerEntries,
    required this.editSeries,
    required this.fullscreen,
    this.entry,
    this.initialDate,
    this.onSaveAndNext,
  });

  final LedgerEntry? entry;
  final DateTime? initialDate;
  final List<Vehicle> vehicles;
  final List<Account> accounts;
  final String? defaultAccountId;
  final List<MasterDataData> masterData;
  final List<LedgerEntry> ledgerEntries;
  final bool editSeries;
  final bool fullscreen;

  /// Saves without closing the editor; only offered for new entries.
  final Future<void> Function(_EntrySubmission)? onSaveAndNext;

  @override
  State<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<_EntryEditor> {
  final _formKey = GlobalKey<FormState>();
  final _amountFocus = FocusNode();
  late final _amount = TextEditingController(
    text: widget.entry == null ? '' : formatAmountInput(widget.entry!.amount),
  );
  late final _merchant = TextEditingController(text: widget.entry?.merchant);
  late final _description = TextEditingController(
    text: widget.entry?.description,
  );
  late final _payment = TextEditingController(
    text: widget.entry?.paymentMethod,
  );
  late final _category = TextEditingController(
    text: widget.entry?.category ?? '',
  );
  final _reminderTitle = TextEditingController();
  final _months = TextEditingController(text: '12');

  /// One of `expense`, `income`, `transfer` or `saving`.
  late String _kind = switch (widget.entry?.sourceType) {
    'transfer' => 'transfer',
    'saving' => 'saving',
    _ => (widget.entry?.isIncome ?? false) ? 'income' : 'expense',
  };
  late DateTime _date =
      widget.entry?.bookingDate ?? widget.initialDate ?? DateTime.now();
  late String _vehicleId = widget.entry?.vehicleId ?? '';
  late final String _accountId =
      widget.entry?.accountId ?? widget.defaultAccountId ?? '';
  String _targetAccountId = '';
  late int _budgetOffset = _initialBudgetOffset();
  bool _repeatMonthly = false;
  String _timing = 'selected';
  bool _addReminder = false;
  bool _categoryEdited = false;
  bool _saving = false;
  String? _notice;
  DateTime _reminderAt = DateTime.now().add(const Duration(days: 1));

  bool get _isNew => widget.entry == null;

  /// Editing one side of a transfer or saving booking; the other side
  /// follows on save.
  bool get _isLinkedEdit =>
      !_isNew &&
      (widget.entry!.sourceType == 'transfer' ||
          widget.entry!.sourceType == 'saving');
  bool get _income => _kind == 'income';
  String get _bookingKind => switch (_kind) {
    'transfer' => 'transfer',
    'saving' => 'saving',
    _ => 'standard',
  };
  int get _monthCount => int.tryParse(_months.text.trim()) ?? 0;

  @override
  void dispose() {
    _amountFocus.dispose();
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    _payment.dispose();
    _category.dispose();
    _reminderTitle.dispose();
    _months.dispose();
    super.dispose();
  }

  String get _title => _isNew
      ? 'Buchung erfassen'
      : widget.editSeries
      ? 'Ganze Serie bearbeiten'
      : 'Buchung bearbeiten';

  String get _accountLine {
    final account = _selectedAccount;
    if (account == null) return 'Kein Haushaltskonto ausgewählt';
    return '${account.label} · ${money(account.balance, currency: account.currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(key: _formKey, child: _formFields(context));
    if (widget.fullscreen) {
      final colors = WealthColors.of(context);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .94,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(color: colors.neutral),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _accountLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 88),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: form,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      if (widget.onSaveAndNext != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _saveAndNext,
                            child: const Text('Speichern & nächste'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: const Text('Speichern'),
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
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title),
          const SizedBox(height: 2),
          Text(_accountLine, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 560.0),
        child: SingleChildScrollView(child: form),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        if (widget.onSaveAndNext != null)
          OutlinedButton(
            onPressed: _saving ? null : _saveAndNext,
            child: const Text('Speichern & nächste'),
          ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  Widget _formFields(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_notice != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_notice!)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      _kindSelector(),
      const SizedBox(height: 12),
      _responsiveFields([
        TextFormField(
          controller: _amount,
          focusNode: _amountFocus,
          autofocus: _isNew,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          style: widget.fullscreen
              ? TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _kind == 'expense'
                      ? WealthColors.of(context).expense
                      : _kind == 'income'
                      ? WealthColors.of(context).income
                      : null,
                )
              : null,
          decoration: InputDecoration(
            labelText: 'Betrag *',
            hintText: '0,00',
            suffixText: _selectedAccount?.currency ?? 'EUR',
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          validator: (value) => (parseAmount(value) ?? 0) <= 0
              ? 'Bitte einen positiven Betrag eingeben.'
              : null,
        ),
        _DateField(
          label: 'Datum',
          value: DateFormat('dd.MM.yyyy').format(_date),
          onTap: _pickDate,
        ),
      ]),
      if (_isNew && _bookingKind != 'standard') ...[
        const SizedBox(height: 12),
        SearchableDropdownButtonFormField<String>(
          initialValue: _targetAccountId.isEmpty ? null : _targetAccountId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _bookingKind == 'saving'
                ? 'Zielkonto / Investkonto *'
                : 'Zielkonto *',
            prefixIcon: const Icon(Icons.redo_rounded),
          ),
          items: widget.accounts
              .where((account) => account.id != _accountId)
              .map(
                (account) => DropdownMenuItem(
                  value: account.id,
                  child: Text(
                    '${account.label} · ${money(account.balance, currency: account.currency)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          validator: (value) =>
              _bookingKind != 'standard' && (value == null || value.isEmpty)
              ? 'Bitte ein Zielkonto auswählen.'
              : null,
          onChanged: (value) => _targetAccountId = value ?? '',
        ),
      ],
      const SizedBox(height: 12),
      _responsiveFields([
        _EditableSuggestionField(
          controller: _merchant,
          label: 'Händler / Quelle',
          suggestions: _masterEntries('merchant'),
          onChanged: _suggestCategory,
        ),
        _EditableSuggestionField(
          controller: _category,
          label: 'Kategorie',
          suggestions: {
            ..._categories.skip(1),
            ...widget.masterData
                .where((item) => item.kind == 'category')
                .map((item) => item.value),
          }.toList(),
          onChanged: (_) => _categoryEdited = true,
        ),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        controller: _description,
        decoration: const InputDecoration(
          labelText: 'Beschreibung',
          prefixIcon: Icon(Icons.notes_rounded),
        ),
        minLines: 1,
        maxLines: 3,
      ),
      const SizedBox(height: 4),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          initiallyExpanded: _hasExtraOptions,
          title: const Text('Weitere Optionen'),
          children: _extraOptions(context),
        ),
      ),
    ],
  );

  bool get _hasExtraOptions =>
      _vehicleId.isNotEmpty ||
      _payment.text.trim().isNotEmpty ||
      _budgetOffset != 0;

  Widget _kindSelector() {
    if (_isLinkedEdit) {
      final saving = _kind == 'saving';
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          saving ? Icons.savings_rounded : Icons.swap_horiz_rounded,
        ),
        title: Text(saving ? 'Sparbuchung' : 'Umbuchung'),
        subtitle: const Text(
          'Betrag, Datum und Texte werden auch auf der Gegenseite angepasst.',
        ),
      );
    }
    final segments = [
      const ButtonSegment(
        value: 'expense',
        icon: Icon(Icons.north_east_rounded),
        label: _SegmentLabel('Ausgabe'),
      ),
      const ButtonSegment(
        value: 'income',
        icon: Icon(Icons.south_west_rounded),
        label: _SegmentLabel('Einnahme'),
      ),
      if (_isNew) ...[
        const ButtonSegment(
          value: 'transfer',
          icon: Icon(Icons.swap_horiz_rounded),
          label: _SegmentLabel('Umbuchung'),
        ),
        const ButtonSegment(
          value: 'saving',
          icon: Icon(Icons.savings_rounded),
          label: _SegmentLabel('Sparen'),
        ),
      ],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        return SegmentedButton<String>(
          showSelectedIcon: false,
          style: compact
              ? const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
              : null,
          segments: [
            for (final segment in segments)
              ButtonSegment(
                value: segment.value,
                icon: compact ? null : segment.icon,
                label: segment.label,
                tooltip: compact && segment.label is _SegmentLabel
                    ? (segment.label! as _SegmentLabel).text
                    : null,
              ),
          ],
          selected: {_kind},
          onSelectionChanged: (value) => setState(() => _kind = value.first),
        );
      },
    );
  }

  List<Widget> _extraOptions(BuildContext context) => [
    _responsiveFields([
      _EditableSuggestionField(
        controller: _payment,
        label: 'Zahlungsmethode',
        suggestions: _masterEntries('paymentMethod'),
      ),
      SearchableDropdownButtonFormField<String>(
        initialValue: _vehicleId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Fahrzeug',
          prefixIcon: Icon(Icons.directions_car_rounded),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('Kein Fahrzeug')),
          for (final vehicle in widget.vehicles)
            DropdownMenuItem(
              value: vehicle.id,
              child: Text('${vehicle.make} ${vehicle.model}'),
            ),
        ],
        onChanged: (value) => _vehicleId = value ?? '',
      ),
    ]),
    const SizedBox(height: 12),
    SearchableDropdownButtonFormField<int>(
      key: ValueKey('budget-$_budgetOffset'),
      initialValue: _budgetOffset,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Wirtschaftlicher Buchungsmonat',
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Monat des Datums')),
        DropdownMenuItem(value: 1, child: Text('Nächster Monat')),
      ],
      onChanged: (value) => setState(() => _budgetOffset = value ?? 0),
    ),
    const SizedBox(height: 4),
    SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Erinnerung'),
      value: _addReminder,
      onChanged: (value) => setState(() => _addReminder = value),
    ),
    if (_addReminder) ...[
      TextFormField(
        controller: _reminderTitle,
        decoration: const InputDecoration(
          labelText: 'Erinnerung *',
          hintText: 'z. B. Abo kündigen',
        ),
        validator: (value) => _addReminder && (value?.trim().isEmpty ?? true)
            ? 'Bitte einen Erinnerungstext eingeben.'
            : null,
      ),
      const SizedBox(height: 10),
      _responsiveFields([
        OutlinedButton.icon(
          onPressed: _pickReminderDate,
          icon: const Icon(Icons.event_rounded),
          label: Text(DateFormat('dd.MM.yyyy').format(_reminderAt)),
        ),
        OutlinedButton.icon(
          onPressed: _pickReminderTime,
          icon: const Icon(Icons.schedule_rounded),
          label: Text('${DateFormat('HH:mm').format(_reminderAt)} Uhr'),
        ),
      ]),
      const SizedBox(height: 8),
    ],
    if (_isNew) ...[
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.repeat_rounded),
        title: const Text('Mehrere Monate buchen'),
        value: _repeatMonthly,
        onChanged: (value) => setState(() => _repeatMonthly = value),
      ),
      if (_repeatMonthly) ...[
        _responsiveFields([
          SearchableDropdownButtonFormField<String>(
            key: ValueKey(_timing),
            initialValue: _timing,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Buchungstag'),
            items: [
              DropdownMenuItem(
                value: 'selected',
                child: Text('Am ${_date.day}. jedes Monats'),
              ),
              const DropdownMenuItem(
                value: 'start',
                child: Text('Erster Werktag'),
              ),
              const DropdownMenuItem(
                value: 'middle',
                child: Text('Monatsmitte (15.)'),
              ),
              const DropdownMenuItem(
                value: 'end',
                child: Text('Letzter Werktag'),
              ),
            ],
            onChanged: (value) => setState(() => _timing = value ?? 'selected'),
          ),
          TextFormField(
            controller: _months,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Laufzeit (Monate)'),
            onChanged: (_) => setState(() {}),
            validator: (_) =>
                _repeatMonthly && (_monthCount < 2 || _monthCount > 120)
                ? 'Bitte 2 bis 120 Monate eingeben.'
                : null,
          ),
        ]),
        const SizedBox(height: 8),
        Text(_seriesPreview(), style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  ];

  Widget _responsiveFields(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 440) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              fields[index],
              if (index < fields.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            Expanded(child: fields[index]),
            if (index < fields.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    },
  );

  Account? get _selectedAccount =>
      widget.accounts.where((account) => account.id == _accountId).firstOrNull;

  void _suggestCategory(String merchant) {
    if (!_isNew || _categoryEdited) return;
    final key = merchant.trim().toLowerCase();
    if (key.isEmpty) return;
    final previous = widget.ledgerEntries
        .where(
          (entry) =>
              entry.merchant.trim().toLowerCase() == key &&
              entry.category.isNotEmpty &&
              entry.sourceType != 'transfer' &&
              entry.sourceType != 'saving',
        )
        .firstOrNull;
    if (previous == null) return;
    _category.text = previous.category;
    if (_payment.text.trim().isEmpty && previous.paymentMethod.isNotEmpty) {
      _payment.text = previous.paymentMethod;
    }
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date,
    );
    if (value != null) setState(() => _date = value);
  }

  _EntrySubmission? _submission() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return null;
    final now = DateTime.now().toUtc();
    final amount = parseAmount(_amount.text) ?? 0;
    final category = _category.text.trim().isEmpty
        ? 'Sonstiges'
        : _category.text.trim();
    final repeatCount = _isNew && _repeatMonthly ? _monthCount : 1;
    final timing = _repeatMonthly ? _timing : 'selected';
    final recurrenceId = repeatCount > 1 ? const Uuid().v4() : '';
    final entries = <LedgerEntriesCompanion>[];
    for (var index = 0; index < repeatCount; index++) {
      final transferId = _bookingKind == 'standard' ? '' : const Uuid().v4();
      final seriesMonth = DateTime(_date.year, _date.month + index);
      final date = !_isNew
          ? _date
          : paymentDateForBudgetMonth(
              budgetMonth: seriesMonth,
              timing: timing,
              selectedDay: _date.day,
            );
      final budgetMonth = DateTime(date.year, date.month + _budgetOffset);
      entries.add(
        LedgerEntriesCompanion.insert(
          id: widget.entry?.id ?? const Uuid().v4(),
          userId: userId,
          bookingDate: date,
          budgetMonth: Value(budgetMonth),
          amount: amount,
          // A linked edit keeps the side it is on (outgoing or incoming).
          isIncome: Value(_isLinkedEdit ? widget.entry!.isIncome : _income),
          category: category,
          merchant: Value(_merchant.text.trim()),
          description: Value(_description.text.trim()),
          paymentMethod: Value(_payment.text.trim()),
          recurrenceId: Value(widget.entry?.recurrenceId ?? recurrenceId),
          sourceType: Value(
            widget.entry?.sourceType ??
                (_bookingKind == 'standard' ? 'manual' : _bookingKind),
          ),
          sourceId: Value(widget.entry?.sourceId ?? transferId),
          vehicleId: Value(_vehicleId),
          accountId: Value(_accountId),
          createdAt: widget.entry?.createdAt ?? now,
          updatedAt: now,
        ),
      );
      if (_isNew && _bookingKind != 'standard') {
        entries.add(
          LedgerEntriesCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            bookingDate: date,
            budgetMonth: Value(budgetMonth),
            amount: amount,
            isIncome: const Value(true),
            category: _bookingKind == 'saving'
                ? 'Sparen / Investieren'
                : 'Umbuchung',
            merchant: Value(_merchant.text.trim()),
            description: Value(_description.text.trim()),
            paymentMethod: Value(_payment.text.trim()),
            recurrenceId: Value(recurrenceId),
            sourceType: Value(_bookingKind),
            sourceId: Value(transferId),
            accountId: Value(_targetAccountId),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
    return _EntrySubmission(
      entries,
      merchant: _merchant.text.trim(),
      paymentMethod: _payment.text.trim(),
      category: category,
      reminderTitle: _addReminder ? _reminderTitle.text.trim() : null,
      reminderAt: _addReminder ? _reminderAt : null,
    );
  }

  void _save() {
    final submission = _submission();
    if (submission != null) Navigator.pop(context, submission);
  }

  Future<void> _saveAndNext() async {
    final submission = _submission();
    if (submission == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSaveAndNext!(submission);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _notice = error.toString().replaceFirst('Bad state: ', '');
      });
      return;
    }
    if (!mounted) return;
    final label = submission.merchant.isNotEmpty
        ? submission.merchant
        : submission.category;
    final amount = money(
      parseAmount(_amount.text) ?? 0,
      currency: _selectedAccount?.currency ?? 'EUR',
    );
    setState(() {
      _saving = false;
      _notice = 'Gespeichert: $label · $amount';
      _amount.clear();
      _merchant.clear();
      _category.clear();
      _description.clear();
      _reminderTitle.clear();
      _categoryEdited = false;
      _addReminder = false;
      _repeatMonthly = false;
    });
    _amountFocus.requestFocus();
  }

  List<String> _masterEntries(String kind) => widget.masterData
      .where((item) => item.kind == kind)
      .map((item) => item.value)
      .toList();

  int _initialBudgetOffset() {
    final budgetMonth = widget.entry?.budgetMonth;
    final bookingDate = widget.entry?.bookingDate;
    if (budgetMonth == null || bookingDate == null) return 0;
    return ((budgetMonth.year - bookingDate.year) * 12 +
            budgetMonth.month -
            bookingDate.month)
        .clamp(0, 1);
  }

  String _seriesPreview() {
    final first = paymentDateForBudgetMonth(
      budgetMonth: DateTime(_date.year, _date.month),
      timing: _timing,
      selectedDay: _date.day,
    );
    final count = _monthCount.clamp(2, 120);
    final last = DateTime(_date.year, _date.month + count - 1);
    return 'Erste Buchung am ${DateFormat('dd.MM.yyyy').format(first)}, '
        'letzte im ${monthLabel(last)}.';
  }

  Future<void> _pickReminderDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _reminderAt,
    );
    if (selected != null) {
      setState(
        () => _reminderAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _reminderAt.hour,
          _reminderAt.minute,
        ),
      );
    }
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt),
    );
    if (selected != null) {
      setState(
        () => _reminderAt = DateTime(
          _reminderAt.year,
          _reminderAt.month,
          _reminderAt.day,
          selected.hour,
          selected.minute,
        ),
      );
    }
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_rounded),
      ),
      child: Text(value),
    ),
  );
}

class _EditableSuggestionField extends StatelessWidget {
  const _EditableSuggestionField({
    required this.controller,
    required this.label,
    required this.suggestions,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suggestions.isEmpty
          ? null
          : PopupMenuButton<String>(
              tooltip: 'Vorhandene Werte anzeigen',
              icon: const Icon(Icons.arrow_drop_down_rounded),
              onSelected: (value) {
                controller
                  ..text = value
                  ..selection = TextSelection.collapsed(offset: value.length);
                onChanged?.call(value);
              },
              itemBuilder: (context) => suggestions
                  .map(
                    (value) =>
                        PopupMenuItem<String>(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
    ),
  );
}

DateTime _month(DateTime value) => DateTime(value.year, value.month);
