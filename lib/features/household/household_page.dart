import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
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
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final masterData =
        ref.watch(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
    final categories = {
      ..._categories.skip(1),
      ...masterData
          .where((item) => item.kind == 'category')
          .map((item) => item.value),
    }.toList()..sort();
    final selectedAccountId = _effectiveAccountId(accounts, preference);
    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Haushaltsbuch',
                subtitle: 'Einnahmen, Ausgaben und Monatsserien planen.',
                action: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 270,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(selectedAccountId),
                        initialValue: selectedAccountId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Haushaltskonto',
                          prefixIcon: Icon(Icons.account_balance_rounded),
                        ),
                        items: accounts
                            .map(
                              (account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(
                                  account.label +
                                      ' · ' +
                                      money(account.balance),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => _selectAccount(value, preference),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: selectedAccountId == null
                          ? null
                          : () => showEntryEditor(
                              context,
                              ref,
                              defaultAccountId: selectedAccountId,
                            ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Buchung'),
                    ),
                  ],
                ),
              ),
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
                    child: DropdownButtonFormField<String>(
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
              Expanded(
                child: asyncEntries.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Buchungen konnten nicht geladen werden: $error',
                    ),
                  ),
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
                    return ListView(
                      children: [
                        _MonthSummary(
                          income: income,
                          expense: expense,
                          saved: saved,
                        ),
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
                                onPressed: () => showEntryEditor(
                                  context,
                                  ref,
                                  initialDate: _selectedMonth,
                                  defaultAccountId: selectedAccountId,
                                ),
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
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return accounts.first.id;
  }

  Future<void> _selectAccount(
    String? accountId,
    UserPreference? preference,
  ) async {
    if (accountId == null) return;
    setState(() => _selectedAccountId = accountId);
    if (preference == null) return;
    await ref
        .read(databaseProvider)
        .savePreferences(
          UserPreferencesCompanion(
            userId: Value(preference.userId),
            themeMode: Value(preference.themeMode),
            locale: Value(preference.locale),
            currency: Value(preference.currency),
            dateFormat: Value(preference.dateFormat),
            serverMode: Value(preference.serverMode),
            serverUrl: Value(preference.serverUrl),
            serverPort: Value(preference.serverPort),
            serverUsername: Value(preference.serverUsername),
            selectedHouseholdAccountId: Value(accountId),
            dataFilePath: Value(preference.dataFilePath),
            freedomAge: Value(preference.freedomAge),
            freedomStartCapital: Value(preference.freedomStartCapital),
            freedomUsePortfolio: Value(preference.freedomUsePortfolio),
            lastSyncAt: Value(preference.lastSyncAt),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  bool _matches(LedgerEntry entry, String? selectedAccountId) {
    final period = budgetMonthOf(entry.bookingDate, entry.budgetMonth);
    final sameMonth =
        period.year == _selectedMonth.year &&
        period.month == _selectedMonth.month;
    final text = (entry.merchant + ' ' + entry.description).toLowerCase();
    return sameMonth &&
        selectedAccountId != null &&
        entry.accountId == selectedAccountId &&
        text.contains(_query) &&
        (_category == 'Alle' || entry.category == _category);
  }
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
          ? constraints.maxWidth
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
                  ? money(saved) +
                        ' wurden als Sparen/Investieren markiert. '
                            'Umbuchungen senken die Sparquote nicht.'
                  : 'Umbuchungen zwischen eigenen Konten werden nicht als Ausgabe gewertet.',
              child: MetricCard(
                title: 'Sparquote',
                value: income <= 0
                    ? '–'
                    : savingsRate.toStringAsFixed(1) + ' %',
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
    if (series) {
      await ref
          .read(databaseProvider)
          .deleteLedgerSeries(entry.recurrenceId, userId);
    } else if ((entry.sourceType == 'transfer' ||
            entry.sourceType == 'saving') &&
        entry.sourceId.isNotEmpty) {
      await ref
          .read(databaseProvider)
          .deleteLinkedLedgerEntries(entry.sourceId, userId);
    } else {
      await ref.read(databaseProvider).deleteLedgerEntry(entry.id, userId);
    }
  }
}

Future<void> showEntryEditor(
  BuildContext context,
  WidgetRef ref, {
  LedgerEntry? entry,
  DateTime? initialDate,
  String? defaultAccountId,
}) async {
  final vehicles = ref.read(vehiclesProvider).valueOrNull ?? const <Vehicle>[];
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final result = await showDialog<_EntrySubmission>(
    context: context,
    builder: (_) => _EntryEditor(
      entry: entry,
      initialDate: initialDate,
      vehicles: vehicles,
      accounts: accounts,
      defaultAccountId: defaultAccountId,
      masterData: masterData,
    ),
  );
  if (result != null) {
    final database = ref.read(databaseProvider);
    await database.saveLedgerEntries(result.entries);
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
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
        if (result.paymentMethod.isNotEmpty)
          'paymentMethod': result.paymentMethod,
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
    this.entry,
    this.initialDate,
  });

  final LedgerEntry? entry;
  final DateTime? initialDate;
  final List<Vehicle> vehicles;
  final List<Account> accounts;
  final String? defaultAccountId;
  final List<MasterDataData> masterData;

  @override
  State<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<_EntryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.entry?.amount.toString(),
  );
  late final _merchant = TextEditingController(text: widget.entry?.merchant);
  late final _description = TextEditingController(
    text: widget.entry?.description,
  );
  late final _payment = TextEditingController(
    text: widget.entry?.paymentMethod,
  );
  late final _category = TextEditingController(
    text: widget.entry?.category ?? 'Einkaufen',
  );
  final _reminderTitle = TextEditingController();
  late bool _income = widget.entry?.isIncome ?? false;
  late DateTime _date =
      widget.entry?.bookingDate ?? widget.initialDate ?? DateTime.now();
  late String _vehicleId = widget.entry?.vehicleId ?? '';
  late final String _accountId =
      widget.entry?.accountId ?? widget.defaultAccountId ?? '';
  late String _bookingKind = switch (widget.entry?.sourceType) {
    'transfer' => 'transfer',
    'saving' => 'saving',
    _ => 'standard',
  };
  String _targetAccountId = '';
  late int _budgetOffset = _initialBudgetOffset();
  bool _repeatMonthly = false;
  String _timing = 'selected';
  int _months = 3;
  bool _addReminder = false;
  DateTime _reminderAt = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    _payment.dispose();
    _category.dispose();
    _reminderTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    title: Text(
      widget.entry == null ? 'Buchung erfassen' : 'Buchung bearbeiten',
    ),
    content: SizedBox(
      width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 560.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.north_east_rounded),
                    label: Text('Ausgabe'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.south_west_rounded),
                    label: Text('Einnahme'),
                  ),
                ],
                selected: {_income},
                onSelectionChanged: (value) =>
                    setState(() => _income = value.first),
              ),
              const SizedBox(height: 16),
              if (widget.entry == null) ...[
                DropdownButtonFormField<String>(
                  initialValue: _bookingKind,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Buchungsart',
                    prefixIcon: Icon(Icons.swap_horiz_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'standard',
                      child: Text('Einnahme oder Ausgabe'),
                    ),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Auf eigenes Konto verschieben'),
                    ),
                    DropdownMenuItem(
                      value: 'saving',
                      child: Text('Sparen / Investieren'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _bookingKind = value ?? 'standard';
                    if (_bookingKind != 'standard') _income = false;
                  }),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Betrag',
                  prefixText: '€ ',
                ),
                validator: (value) => (_parse(value) ?? 0) <= 0
                    ? 'Bitte einen positiven Betrag eingeben.'
                    : null,
              ),
              const SizedBox(height: 12),
              _EditableSuggestionField(
                controller: _category,
                label: 'Kategorie',
                suggestions: {
                  ..._categories.skip(1),
                  ...widget.masterData
                      .where((item) => item.kind == 'category')
                      .map((item) => item.value),
                }.toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _vehicleId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Fahrzeug (optional)',
                  prefixIcon: Icon(Icons.directions_car_rounded),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Kein Fahrzeug'),
                  ),
                  for (final vehicle in widget.vehicles)
                    DropdownMenuItem(
                      value: vehicle.id,
                      child: Text('${vehicle.make} ${vehicle.model}'),
                    ),
                ],
                onChanged: (value) => _vehicleId = value ?? '',
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.account_balance_rounded),
                title: Text(_selectedAccount?.label ?? 'Kein Haushaltskonto'),
                subtitle: Text(
                  _selectedAccount == null
                      ? 'Bitte zuerst ein Haushaltskonto auswählen.'
                      : 'Aktueller Kontostand: ' +
                            money(
                              _selectedAccount!.balance,
                              currency: _selectedAccount!.currency,
                            ),
                ),
              ),
              if (widget.entry == null && _bookingKind != 'standard') ...[
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _targetAccountId.isEmpty
                      ? null
                      : _targetAccountId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _bookingKind == 'saving'
                        ? 'Zielkonto / Investkonto'
                        : 'Zielkonto',
                    prefixIcon: const Icon(Icons.redo_rounded),
                  ),
                  items: widget.accounts
                      .where((account) => account.id != _accountId)
                      .map(
                        (account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(
                            account.label +
                                ' · ' +
                                money(
                                  account.balance,
                                  currency: account.currency,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      _bookingKind != 'standard' &&
                          (value == null || value.isEmpty)
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
                ),
                _EditableSuggestionField(
                  controller: _payment,
                  label: 'Zahlungsmethode',
                  suggestions: _masterEntries('paymentMethod'),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Erinnerung zu dieser Buchung'),
                subtitle: const Text(
                  'Plant optional eine Systembenachrichtigung.',
                ),
                value: _addReminder,
                onChanged: (value) => setState(() => _addReminder = value),
              ),
              if (_addReminder) ...[
                TextFormField(
                  controller: _reminderTitle,
                  decoration: const InputDecoration(
                    labelText: 'Erinnerung',
                    hintText: 'z. B. Abo kündigen',
                    prefixIcon: Icon(Icons.notifications_outlined),
                  ),
                  validator: (value) =>
                      _addReminder && (value?.trim().isEmpty ?? true)
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
                    label: Text(
                      '${DateFormat('HH:mm').format(_reminderAt)} Uhr',
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(
                    '${_repeatMonthly ? 'Start' : 'Datum'}: '
                    '${DateFormat('dd.MM.yyyy').format(_date)}',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: ValueKey('budget-$_budgetOffset-$_timing'),
                initialValue: _timing == 'end' ? 1 : _budgetOffset,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Wirtschaftlicher Buchungsmonat',
                  helperText:
                      'Steuert Monatsübersichten, Statistiken und Auswertungen.',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Tatsächlicher Buchungsmonat'),
                  ),
                  DropdownMenuItem(value: 1, child: Text('Nächster Monat')),
                ],
                onChanged: _timing == 'end'
                    ? null
                    : (value) => setState(() => _budgetOffset = value ?? 0),
              ),
              if (widget.entry == null) ...[
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Automatisch monatlich buchen'),
                  subtitle: const Text(
                    'Datum und Budgetmonat werden gemeinsam je Monat fortgeschrieben.',
                  ),
                  value: _repeatMonthly,
                  onChanged: (value) => setState(() => _repeatMonthly = value),
                ),
                if (_repeatMonthly) ...[
                  const SizedBox(height: 8),
                  _responsiveFields([
                    DropdownButtonFormField<String>(
                      initialValue: _timing,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Zeitpunkt'),
                      items: const [
                        DropdownMenuItem(
                          value: 'selected',
                          child: Text('Gewählter Tag'),
                        ),
                        DropdownMenuItem(
                          value: 'start',
                          child: Text('Monatsanfang (erster Werktag)'),
                        ),
                        DropdownMenuItem(
                          value: 'middle',
                          child: Text('Monatsmitte (15.)'),
                        ),
                        DropdownMenuItem(
                          value: 'end',
                          child: Text('Vormonat (letzter Werktag)'),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _timing = value ?? 'selected';
                        if (_timing == 'end') _budgetOffset = 1;
                      }),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _months,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Laufzeit'),
                      items: const [1, 2, 3, 6, 12, 24, 36, 60]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value Monate'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => _months = value ?? 3,
                    ),
                  ]),
                ],
                if (_repeatMonthly) ...[
                  const SizedBox(height: 8),
                  Text(
                    _seriesPreview(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton(onPressed: _save, child: const Text('Speichern')),
    ],
  );

  Widget _responsiveFields(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 560) {
        return Column(
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              fields[index],
              if (index < fields.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return Row(
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

  double? _parse(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date,
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    final repeatCount = widget.entry == null && _repeatMonthly ? _months : 1;
    final recurrenceId = repeatCount > 1 ? const Uuid().v4() : '';
    final entries = <LedgerEntriesCompanion>[];
    for (var index = 0; index < repeatCount; index++) {
      final transferId = _bookingKind == 'standard' ? '' : const Uuid().v4();
      final seriesMonth = DateTime(_date.year, _date.month + index);
      final date = _repeatMonthly
          ? paymentDateForBudgetMonth(
              budgetMonth: seriesMonth,
              timing: _timing,
              selectedDay: _date.day,
            )
          : _date;
      final budgetMonth = _repeatMonthly && _timing == 'end'
          ? seriesMonth
          : DateTime(date.year, date.month + _budgetOffset);
      entries.add(
        LedgerEntriesCompanion.insert(
          id: widget.entry?.id ?? const Uuid().v4(),
          userId: userId,
          bookingDate: date,
          budgetMonth: Value(budgetMonth),
          amount: _parse(_amount.text) ?? 0,
          isIncome: Value(_income),
          category: _category.text.trim().isEmpty
              ? 'Sonstiges'
              : _category.text.trim(),
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
      if (widget.entry == null && _bookingKind != 'standard') {
        entries.add(
          LedgerEntriesCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            bookingDate: date,
            budgetMonth: Value(budgetMonth),
            amount: _parse(_amount.text) ?? 0,
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
    Navigator.pop(
      context,
      _EntrySubmission(
        entries,
        merchant: _merchant.text.trim(),
        paymentMethod: _payment.text.trim(),
        category: _category.text.trim().isEmpty
            ? 'Sonstiges'
            : _category.text.trim(),
        reminderTitle: _addReminder ? _reminderTitle.text.trim() : null,
        reminderAt: _addReminder ? _reminderAt : null,
      ),
    );
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
    final seriesMonth = DateTime(_date.year, _date.month);
    final bookingDate = paymentDateForBudgetMonth(
      budgetMonth: seriesMonth,
      timing: _timing,
      selectedDay: _date.day,
    );
    final budgetMonth = _timing == 'end'
        ? seriesMonth
        : DateTime(bookingDate.year, bookingDate.month + _budgetOffset);
    return 'Erste Kontobuchung: '
        '${DateFormat('dd.MM.yyyy').format(bookingDate)}'
        ' · zählt wirtschaftlich für ${_monthLabel(budgetMonth)}';
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

class _EditableSuggestionField extends StatelessWidget {
  const _EditableSuggestionField({
    required this.controller,
    required this.label,
    required this.suggestions,
  });

  final TextEditingController controller;
  final String label;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
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
