import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/bank_csv.dart';
import 'package:wealthflow_core/finance/bank_import.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/storage/data_export.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

/// Picks a bank's CSV export and shows every row before anything is saved.
Future<void> startBankImport(
  BuildContext context,
  WidgetRef ref, {
  String? accountId,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final accounts = householdAccounts(
    await ref.read(accountsProvider.future),
    investments: await ref.read(allInvestmentsProvider.future),
    physicalAssets: await ref.read(physicalAssetsProvider.future),
  );
  if (accounts.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Lege zuerst ein Haushaltskonto unter Vermögen an.'),
      ),
    );
    return;
  }
  final bytes = await chooseCsvFile();
  if (bytes == null || !context.mounted) return;
  final BankCsvTable table;
  try {
    table = parseBankCsv(bytes);
  } on FormatException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message)));
    return;
  }
  final entries = await ref.read(ledgerEntriesProvider.future);
  if (!context.mounted) return;
  final phone = MediaQuery.sizeOf(context).width < 600;
  final dialog = BankImportDialog(
    userId: userId,
    table: table,
    accounts: accounts,
    initialAccountId: accounts.any((account) => account.id == accountId)
        ? accountId!
        : accounts.first.id,
    existing: entries,
  );
  final result = await showDialog<List<LedgerEntriesCompanion>>(
    context: context,
    builder: (_) => phone
        ? Dialog.fullscreen(child: dialog)
        : Dialog(
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
              child: dialog,
            ),
          ),
  );
  if (result == null || result.isEmpty || !context.mounted) return;
  final saved = await saveWithFeedback(
    context,
    () => ref.read(databaseProvider).saveLedgerEntries(result),
    failure: 'Import fehlgeschlagen',
    source: 'CSV-Import',
  );
  if (saved) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.length == 1
              ? '1 Buchung übernommen'
              : '${result.length} Buchungen übernommen',
        ),
      ),
    );
  }
}

class BankImportDialog extends StatefulWidget {
  const BankImportDialog({
    required this.userId,
    required this.table,
    required this.accounts,
    required this.initialAccountId,
    required this.existing,
    super.key,
  });

  final String userId;
  final BankCsvTable table;
  final List<Account> accounts;
  final String initialAccountId;
  final List<LedgerEntry> existing;

  @override
  State<BankImportDialog> createState() => _BankImportDialogState();
}

class _BankImportDialogState extends State<BankImportDialog> {
  late String _accountId = widget.initialAccountId;
  late int? _date = widget.table.mapping?.date;
  late int? _amount = widget.table.mapping?.amount;
  late int? _counterparty = widget.table.mapping?.counterparty;
  late int? _purpose = widget.table.mapping?.purpose;
  bool _alreadyInBalance = true;
  List<BankImportCandidate> _candidates = const [];
  final _selected = <String>{};
  final _categories = <String, String>{};

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final date = _date;
    final amount = _amount;
    final detected = widget.table.mapping;
    final rows = date == null || amount == null
        ? const <BankCsvRow>[]
        : widget.table.read(
            BankCsvMapping(
              date: date,
              amount: amount,
              counterparty: _counterparty,
              counterpartyIncoming: detected?.counterpartyIncoming,
              purpose: _purpose,
              status: detected?.status,
            ),
          );
    _candidates = prepareBankImport(
      rows: rows,
      accountId: _accountId,
      existing: widget.existing,
    );
    _selected
      ..clear()
      ..addAll(
        _candidates.where((item) => !item.duplicate).map((item) => item.id),
      );
  }

  List<LedgerEntriesCompanion> _entries() {
    final now = DateTime.now().toUtc();
    return [
      for (final item in _candidates)
        if (_selected.contains(item.id))
          LedgerEntriesCompanion.insert(
            id: item.id,
            userId: widget.userId,
            bookingDate: item.row.date,
            amount: item.row.amount.abs(),
            isIncome: Value(item.isIncome),
            category: _categories[item.id] ?? item.category,
            merchant: Value(item.row.counterparty),
            description: Value(item.row.purpose),
            accountId: Value(_accountId),
            // Already in the entered balance: do not count it again.
            accountApplied: Value(_alreadyInBalance),
            createdAt: now,
            updatedAt: now,
          ),
    ];
  }

  Future<void> _changeCategory(BankImportCandidate item) async {
    final known = {
      for (final entry in widget.existing)
        if (entry.isIncome == item.isIncome && entry.category.isNotEmpty)
          entry.category,
    }.toList()..sort();
    final controller = TextEditingController(
      text: _categories[item.id] ?? item.category,
    );
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kategorie'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                onSubmitted: (value) => Navigator.pop(dialogContext, value),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final category in known.take(12))
                    ActionChip(
                      label: Text(category),
                      onPressed: () => Navigator.pop(dialogContext, category),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) return;
    setState(() {
      // The same merchant usually belongs to the same category.
      for (final other in _candidates) {
        if (other.row.counterparty == item.row.counterparty &&
            other.isIncome == item.isIncome) {
          _categories[other.id] = value.trim();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final duplicates = _candidates.where((item) => item.duplicate).length;
    final bank = widget.table.bank;
    final needsMapping = widget.table.mapping == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Abbrechen',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Kontoauszug importieren',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Text(
                bank != null
                    ? 'Erkannt: $bank'
                    : needsMapping
                    ? 'Unbekanntes Format: bitte die Spalten zuordnen.'
                    : 'Spalten erkannt',
                style: TextStyle(color: colors.muted),
              ),
              if (needsMapping) ...[const SizedBox(height: 12), _mapping()],
              const SizedBox(height: 12),
              SearchableDropdownButtonFormField<String>(
                initialValue: _accountId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'In Konto',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                items: [
                  for (final account in widget.accounts)
                    DropdownMenuItem(
                      value: account.id,
                      child: Text(
                        account.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _accountId = value ?? _accountId;
                  _prepare();
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _alreadyInBalance,
                onChanged: (value) => setState(() => _alreadyInBalance = value),
                title: const Text('Schon im Kontostand enthalten'),
                subtitle: Text(
                  _alreadyInBalance
                      ? 'Der Kontostand in WealthFlow bleibt, wie er ist.'
                      : 'Jede Buchung ändert den Kontostand.',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Eyebrow(
                      '${_candidates.length} Zeilen'
                      '${duplicates == 0 ? '' : ' · $duplicates schon vorhanden'}',
                    ),
                  ),
                  TextButton(
                    onPressed: _candidates.isEmpty
                        ? null
                        : () => setState(() {
                            if (_selected.length == _candidates.length) {
                              _selected.clear();
                            } else {
                              _selected.addAll(
                                _candidates.map((item) => item.id),
                              );
                            }
                          }),
                    child: Text(
                      _selected.length == _candidates.length ? 'Keine' : 'Alle',
                    ),
                  ),
                ],
              ),
              if (_candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Keine Buchungen gefunden.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.muted),
                  ),
                ),
              for (final item in _candidates) _row(item),
            ],
          ),
        ),
        Divider(height: 1, color: colors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.pop(context, _entries()),
            icon: const Icon(Icons.download_done_rounded),
            label: Text(
              _selected.length == 1
                  ? '1 Buchung übernehmen'
                  : '${_selected.length} Buchungen übernehmen',
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BankImportCandidate item) {
    final colors = WealthColors.of(context);
    final selected = _selected.contains(item.id);
    final category = _categories[item.id] ?? item.category;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(
        () => selected ? _selected.remove(item.id) : _selected.add(item.id),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) => setState(
                () => value == true
                    ? _selected.add(item.id)
                    : _selected.remove(item.id),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.row.counterparty.isNotEmpty
                        ? item.row.counterparty
                        : item.row.purpose,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? null : colors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${shortDate(item.row.date)} ${item.row.date.year}',
                        style: TextStyle(fontSize: 12, color: colors.muted),
                      ),
                      InkWell(
                        onTap: () => _changeCategory(item),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                        ),
                      ),
                      if (item.duplicate)
                        Text(
                          'schon vorhanden',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AmountText(item.row.amount.abs(), income: item.isIncome),
          ],
        ),
      ),
    );
  }

  Widget _mapping() {
    final header = widget.table.header;
    Widget column(
      String label,
      int? value,
      ValueChanged<int?> onChanged, {
      bool optional = false,
    }) => DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        if (optional)
          const DropdownMenuItem<int?>(value: null, child: Text('–')),
        for (final (index, name) in header.indexed)
          DropdownMenuItem<int?>(
            value: index,
            child: Text(
              name.trim().isEmpty ? 'Spalte ${index + 1}' : name.trim(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) => setState(() {
        onChanged(value);
        _prepare();
      }),
    );
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: column('Datum *', _date, (v) => _date = v)),
            const SizedBox(width: 12),
            Expanded(child: column('Betrag *', _amount, (v) => _amount = v)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: column(
                'Empfänger',
                _counterparty,
                (v) => _counterparty = v,
                optional: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: column(
                'Verwendungszweck',
                _purpose,
                (v) => _purpose = v,
                optional: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
