import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class HouseholdPage extends ConsumerStatefulWidget {
  const HouseholdPage({super.key});
  @override
  ConsumerState<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends ConsumerState<HouseholdPage> {
  String _query = '';
  String _category = 'Alle';
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final asyncEntries = ref.watch(ledgerEntriesProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Haushaltsbuch',
                subtitle: 'Einnahmen und Ausgaben transparent erfassen.',
                action: FilledButton.icon(
                  onPressed: () => showEntryEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buchung'),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _query = value.toLowerCase()),
                      decoration: const InputDecoration(
                        labelText: 'Händler oder Beschreibung',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Kategorie'),
                      items: _categories
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
                  OutlinedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(
                      _range == null
                          ? 'Zeitraum'
                          : '${DateFormat('dd.MM.yy').format(_range!.start)} – ${DateFormat('dd.MM.yy').format(_range!.end)}',
                    ),
                  ),
                  if (_range != null)
                    IconButton(
                      onPressed: () => setState(() => _range = null),
                      tooltip: 'Zeitraum löschen',
                      icon: const Icon(Icons.close_rounded),
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
                    final entries = allEntries.where(_matches).toList();
                    if (allEntries.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'Noch keine Buchungen',
                        message:
                            'Erfasse deine erste Einnahme oder Ausgabe. Auswertungen entstehen automatisch.',
                        action: FilledButton.icon(
                          onPressed: () => showEntryEditor(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Erste Buchung'),
                        ),
                      );
                    }
                    final income = entries
                        .where((e) => e.isIncome)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    final expense = entries
                        .where((e) => !e.isIncome)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    return ListView(
                      children: [
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
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (entries.isEmpty)
                          const SizedBox(
                            height: 280,
                            child: EmptyState(
                              icon: Icons.filter_alt_off_rounded,
                              title: 'Keine Treffer',
                              message: 'Passe deine Filter an.',
                            ),
                          )
                        else
                          Card(
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

  bool _matches(LedgerEntry entry) {
    final text = '${entry.merchant} ${entry.description}'.toLowerCase();
    final category = _category == 'Alle' || entry.category == _category;
    final range =
        _range == null ||
        (!entry.bookingDate.isBefore(_range!.start) &&
            entry.bookingDate.isBefore(
              _range!.end.add(const Duration(days: 1)),
            ));
    return text.contains(_query) && category && range;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _range ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    );
    if (picked != null) setState(() => _range = picked);
  }
}

const _categories = [
  'Alle',
  'Einkaufen',
  'Wohnen',
  'Auto',
  'Motorrad',
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      onTap: () => showEntryEditor(context, ref, entry: entry),
      leading: CircleAvatar(
        backgroundColor: (positive ? Colors.green : Colors.orange).withValues(
          alpha: .15,
        ),
        child: Icon(
          positive ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: positive ? Colors.green : Colors.orange,
        ),
      ),
      title: Text(
        entry.merchant.isEmpty ? entry.description : entry.merchant,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${entry.category} · ${DateFormat('dd.MM.yyyy').format(entry.bookingDate)}${entry.paymentMethod.isEmpty ? '' : ' · ${entry.paymentMethod}'}',
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
            onSelected: (value) async {
              if (value == 'edit') {
                await showEntryEditor(context, ref, entry: entry);
              } else if (value == 'delete' &&
                  await confirmDelete(
                    context,
                    title: 'Buchung löschen?',
                    message:
                        'Diese Buchung wird aus allen Auswertungen entfernt.',
                  )) {
                final userId = ref.read(currentUserIdProvider);
                if (userId != null) {
                  await ref
                      .read(databaseProvider)
                      .deleteLedgerEntry(entry.id, userId);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
              PopupMenuItem(value: 'delete', child: Text('Löschen')),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showEntryEditor(
  BuildContext context,
  WidgetRef ref, {
  LedgerEntry? entry,
}) async {
  final result = await showDialog<LedgerEntriesCompanion>(
    context: context,
    builder: (_) => _EntryEditor(entry: entry),
  );
  if (result != null) await ref.read(databaseProvider).saveLedgerEntry(result);
}

class _EntryEditor extends StatefulWidget {
  const _EntryEditor({this.entry});
  final LedgerEntry? entry;
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
  late bool _income = widget.entry?.isIncome ?? false;
  late String _category = widget.entry?.category ?? 'Einkaufen';
  late DateTime _date = widget.entry?.bookingDate ?? DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _description.dispose();
    _payment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.entry == null ? 'Buchung erfassen' : 'Buchung bearbeiten',
    ),
    content: SizedBox(
      width: 540,
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
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: _categories
                    .skip(1)
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => _category = value ?? 'Sonstiges',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _merchant,
                decoration: const InputDecoration(
                  labelText: 'Händler / Quelle',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _payment,
                decoration: const InputDecoration(labelText: 'Zahlungsmethode'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(DateFormat('dd.MM.yyyy').format(_date)),
              ),
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

  double? _parse(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));
  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    Navigator.pop(
      context,
      LedgerEntriesCompanion.insert(
        id: widget.entry?.id ?? const Uuid().v4(),
        userId: userId,
        bookingDate: _date,
        amount: _parse(_amount.text) ?? 0,
        isIncome: Value(_income),
        category: _category,
        merchant: Value(_merchant.text.trim()),
        description: Value(_description.text.trim()),
        paymentMethod: Value(_payment.text.trim()),
        createdAt: widget.entry?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
