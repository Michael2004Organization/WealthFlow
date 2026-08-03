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
                        .where((entry) => entry.isIncome)
                        .fold<double>(0, (sum, entry) => sum + entry.amount);
                    final expense = entries
                        .where((entry) => !entry.isIncome)
                        .fold<double>(0, (sum, entry) => sum + entry.amount);
                    return ListView(
                      children: [
                        _MonthSummary(income: income, expense: expense),
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
  const _MonthSummary({required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 700
          ? constraints.maxWidth
          : (constraints.maxWidth - 48) / 4;
      final savingsRate = income <= 0 ? 0 : (income - expense) / income * 100;
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
              message:
                  'Überschuss geteilt durch Einnahmen: ' +
                  money(income - expense) +
                  ' / ' +
                  money(income),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      onTap: entry.sourceType == 'vehicle'
          ? null
          : () => showEntryEditor(context, ref, entry: entry),
      leading: CircleAvatar(
        backgroundColor: (positive ? Colors.green : Colors.orange).withValues(
          alpha: .15,
        ),
        child: Icon(
          entry.sourceType == 'vehicle'
              ? Icons.directions_car_rounded
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
              if (entry.sourceType != 'vehicle')
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
          : 'Diese Buchung wird aus allen Auswertungen entfernt.',
    );
    if (!confirmed || !context.mounted) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    if (series) {
      await ref
          .read(databaseProvider)
          .deleteLedgerSeries(entry.recurrenceId, userId);
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
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final result = await showDialog<_EntrySubmission>(
    context: context,
    builder: (_) => _EntryEditor(
      entry: entry,
      initialDate: initialDate,
      vehicles: vehicles,
      defaultAccountId: defaultAccountId,
      masterData: masterData,
    ),
  );
  if (result != null) {
    final database = ref.read(databaseProvider);
    await database.saveLedgerEntries(result.entries);
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
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
  });
  final List<LedgerEntriesCompanion> entries;
  final String merchant;
  final String paymentMethod;
  final String category;
}

class _EntryEditor extends StatefulWidget {
  const _EntryEditor({
    required this.vehicles,
    required this.defaultAccountId,
    required this.masterData,
    this.entry,
    this.initialDate,
  });

  final LedgerEntry? entry;
  final DateTime? initialDate;
  final List<Vehicle> vehicles;
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
  late bool _income = widget.entry?.isIncome ?? false;
  late DateTime _date =
      widget.entry?.bookingDate ?? widget.initialDate ?? DateTime.now();
  late String _vehicleId = widget.entry?.vehicleId ?? '';
  late final String _accountId =
      widget.entry?.accountId ?? widget.defaultAccountId ?? '';
  late int _budgetOffset = _initialBudgetOffset();
  bool _repeatMonthly = false;
  String _timing = 'selected';
  int _months = 3;

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    _payment.dispose();
    _category.dispose();
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
              DropdownMenu<String>(
                controller: _category,
                enableFilter: true,
                requestFocusOnTap: true,
                label: const Text('Kategorie'),
                helperText: 'Auswählen oder neue Kategorie eingeben',
                dropdownMenuEntries:
                    {
                          ..._categories.skip(1),
                          ...widget.masterData
                              .where((item) => item.kind == 'category')
                              .map((item) => item.value),
                        }
                        .map(
                          (value) =>
                              DropdownMenuEntry(value: value, label: value),
                        )
                        .toList(),
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
              const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                leading: Icon(Icons.account_balance_rounded),
                title: Text('Ausgewähltes Haushaltskonto'),
                subtitle: Text(
                  'Diese Buchung aktualisiert dessen Kontostand automatisch.',
                ),
              ),
              const SizedBox(height: 12),
              _responsiveFields([
                DropdownMenu<String>(
                  controller: _merchant,
                  enableFilter: true,
                  label: const Text('Händler / Quelle'),
                  dropdownMenuEntries: _masterEntries('merchant'),
                ),
                DropdownMenu<String>(
                  controller: _payment,
                  enableFilter: true,
                  label: const Text('Zahlungsmethode'),
                  dropdownMenuEntries: _masterEntries('paymentMethod'),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                maxLines: 2,
              ),
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
              if (!_repeatMonthly) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _budgetOffset,
                  decoration: const InputDecoration(
                    labelText: 'In welchem Budgetmonat berücksichtigen?',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: -1,
                      child: Text('Im vorherigen Monat'),
                    ),
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Im Monat des Buchungstags'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Im nächsten Monat (im Voraus bezahlt)'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _budgetOffset = value ?? 0),
                ),
              ],
              if (widget.entry == null) ...[
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Automatisch monatlich buchen'),
                  subtitle: const Text(
                    'Mit festem Beginn und begrenzter Laufzeit',
                  ),
                  value: _repeatMonthly,
                  onChanged: (value) => setState(() => _repeatMonthly = value),
                ),
                if (_repeatMonthly) ...[
                  const SizedBox(height: 8),
                  _responsiveFields([
                    DropdownButtonFormField<String>(
                      initialValue: _timing,
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
                          child: Text('Vormonat (vorletzter Werktag)'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _timing = value ?? 'selected'),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _months,
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
                    'Erste Kontobuchung: ' +
                        DateFormat('dd.MM.yyyy').format(
                          paymentDateForBudgetMonth(
                            budgetMonth: DateTime(_date.year, _date.month),
                            timing: _timing,
                            selectedDay: _date.day,
                          ),
                        ) +
                        ' · zählt für ' +
                        _monthLabel(DateTime(_date.year, _date.month)),
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

  Widget _responsiveFields(List<Widget> fields) {
    if (MediaQuery.sizeOf(context).width < 620) {
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
  }

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
      final budgetMonth = _repeatMonthly
          ? DateTime(_date.year, _date.month + index)
          : DateTime(_date.year, _date.month + _budgetOffset);
      final date = _repeatMonthly
          ? paymentDateForBudgetMonth(
              budgetMonth: budgetMonth,
              timing: _timing,
              selectedDay: _date.day,
            )
          : _date;
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
          sourceType: Value(widget.entry?.sourceType ?? 'manual'),
          sourceId: Value(widget.entry?.sourceId ?? ''),
          vehicleId: Value(_vehicleId),
          accountId: Value(_accountId),
          createdAt: widget.entry?.createdAt ?? now,
          updatedAt: now,
        ),
      );
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
      ),
    );
  }

  List<DropdownMenuEntry<String>> _masterEntries(String kind) => widget
      .masterData
      .where((item) => item.kind == kind)
      .map(
        (item) =>
            DropdownMenuEntry<String>(value: item.value, label: item.value),
      )
      .toList();

  int _initialBudgetOffset() {
    final budgetMonth = widget.entry?.budgetMonth;
    final bookingDate = widget.entry?.bookingDate;
    if (budgetMonth == null || bookingDate == null) return 0;
    return ((budgetMonth.year - bookingDate.year) * 12 +
            budgetMonth.month -
            bookingDate.month)
        .clamp(-1, 1);
  }
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
