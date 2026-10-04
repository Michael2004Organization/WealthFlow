import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/account_balance_math.dart';
import '../../core/finance/amount_input.dart';
import '../../core/finance/budget_period.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

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
    final householdAccounts = accounts.where((account) {
      if (account.usageType == 'household') return true;
      if (account.usageType != 'unassigned') return false;
      return !investments.any((item) => item.accountId == account.id) &&
          !physicalAssets.any((item) => item.accountId == account.id);
    }).toList();
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
      householdAccounts,
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
              title: 'Haushaltsbuch',
              subtitle: '',
              action: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (householdAccounts.isNotEmpty)
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
                        items: householdAccounts
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
            if (householdAccounts.isEmpty) ...[
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
              error: (error, stackTrace) {
                debugPrint('Buchungen konnten nicht geladen werden: $error');
                return const [
                  Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Die Buchungen konnten nicht geladen werden. '
                        'Bitte die App neu starten.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ];
              },
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
                            'Keine Buchungen im ${_monthLabel(_selectedMonth)}',
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
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < entries.length;
                            index++
                          ) ...[
                            _EntryTile(entry: entries[index]),
                            if (index < entries.length - 1)
                              const Divider(height: 1, indent: 72),
                          ],
                        ],
                      ),
                    ),
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
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            children: [
              Text(
                _shortMonths[month.month - 1],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 700
          ? (constraints.maxWidth - 16) / 2
          : (constraints.maxWidth - 48) / 4;
      final savingsRate = income <= 0
          ? 0
          : (income - expense).clamp(0, double.infinity) / income * 100;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: width,
            child: MetricCard(
              title: 'Einnahmen',
              value: money(income),
              icon: Icons.south_west_rounded,
              color: Colors.green,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              title: 'Ausgaben',
              value: money(expense),
              icon: Icons.north_east_rounded,
              color: Colors.orange,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              title: 'Saldo',
              value: money(income - expense),
              icon: Icons.balance_rounded,
              color: income >= expense
                  ? Colors.teal
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(
            width: width,
            child: Tooltip(
              message: saved > 0
                  ? '${money(saved)} wurden als Sparen/Investieren markiert. '
                        'Umbuchungen senken die Sparquote nicht.'
                  : 'Umbuchungen zwischen eigenen Konten werden nicht als Ausgabe gewertet.',
              child: MetricCard(
                title: 'Sparquote',
                value: income <= 0
                    ? '–'
                    : '${savingsRate.toStringAsFixed(1)} %',
                icon: Icons.savings_rounded,
                color: savingsRate >= 0
                    ? Colors.purple
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      );
    },
  );
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      onTap: entry.sourceType == 'vehicle' || linked
          ? null
          : () => showEntryEditor(context, ref, entry: entry),
      leading: CircleAvatar(
        backgroundColor: (positive ? Colors.green : Colors.orange).withValues(
          alpha: .15,
        ),
        child: Icon(
          entry.sourceType == 'vehicle'
              ? Icons.directions_car_rounded
              : linked
              ? entry.sourceType == 'saving'
                    ? Icons.savings_rounded
                    : Icons.swap_horiz_rounded
              : positive
              ? Icons.south_west_rounded
              : Icons.north_east_rounded,
          color: positive ? Colors.green : Colors.orange,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              entry.merchant.isEmpty ? entry.description : entry.merchant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (recurring)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Tooltip(
                message: 'Monatliche Serie',
                child: Icon(Icons.repeat_rounded, size: 18),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${entry.category} · ${DateFormat('dd.MM.yyyy').format(entry.bookingDate)}'
        '${entry.vehicleId.isEmpty ? '' : ' · Fahrzeug'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${positive ? '+' : '−'}${money(entry.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: positive
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (_) => [
              if (entry.sourceType != 'vehicle' && !linked)
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
    if (series) {
      await database.deleteLedgerSeries(entry.recurrenceId, userId);
    } else if (linked) {
      await database.deleteLinkedLedgerEntries(entry.sourceId, userId);
    } else {
      await database.deleteLedgerEntry(entry.id, userId);
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
                  onPressed: () => database.restoreLedgerEntries(restorable),
                ),
        ),
      );
  }
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
  final result = await showDialog<_EntrySubmission>(
    context: context,
    builder: (_) => _EntryEditor(
      entry: entry,
      initialDate: initialDate,
      vehicles: vehicles,
      accounts: accounts,
      defaultAccountId: defaultAccountId,
      masterData: masterData,
      ledgerEntries: ledgerEntries,
      editSeries: editSeries,
      fullscreen: MediaQuery.sizeOf(context).width < 600,
      onSaveAndNext: entry == null ? persist : null,
    ),
  );
  if (result != null) await persist(result);
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
    );
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
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Abbrechen',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title),
                Text(
                  _accountLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: form,
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
          isIncome: Value(_income),
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
        'letzte im ${_monthLabel(last)}.';
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

const _shortMonths = [
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
];

const _longMonths = [
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

String _monthLabel(DateTime value) =>
    '${_longMonths[value.month - 1]} ${value.year}';
