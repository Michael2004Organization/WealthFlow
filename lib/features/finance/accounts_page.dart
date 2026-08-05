import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Konten',
                subtitle: 'Bankkonten und verfügbare Beträge an einem Ort.',
                action: FilledButton.icon(
                  onPressed: () => showAccountEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Konto'),
                ),
              ),
              Expanded(
                child: accounts.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Konten konnten nicht geladen werden: $error'),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.account_balance_rounded,
                        title: 'Noch kein Konto',
                        message:
                            'Lege dein erstes Bankkonto an. Dein Gesamtvermögen wird danach automatisch berechnet.',
                        action: FilledButton.icon(
                          onPressed: () => showAccountEditor(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Erstes Konto anlegen'),
                        ),
                      );
                    }
                    final total = items.fold<double>(
                      0,
                      (sum, item) => sum + item.balance,
                    );
                    return ListView(
                      children: [
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 34,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Kontostand gesamt'),
                                    Text(
                                      money(total),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = constraints.maxWidth < 700
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final account in items)
                                  SizedBox(
                                    width: cardWidth,
                                    child: _AccountCard(account: account),
                                  ),
                              ],
                            );
                          },
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
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme;
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showAccountActivity(
          context,
          ref,
          account,
          entries.where((entry) => entry.accountId == account.id).toList(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.secondaryContainer,
                    child: const Icon(Icons.account_balance_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          account.bankName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'activity') {
                        await _showAccountActivity(
                          context,
                          ref,
                          account,
                          entries
                              .where((entry) => entry.accountId == account.id)
                              .toList(),
                        );
                      } else if (value == 'edit') {
                        await showAccountEditor(context, ref, account: account);
                      } else if (value == 'delete' &&
                          await confirmDelete(
                            context,
                            title: 'Konto löschen?',
                            message:
                                '${account.label} wird aus allen Übersichten entfernt.',
                          )) {
                        final userId = ref.read(currentUserIdProvider);
                        if (userId != null) {
                          await ref
                              .read(databaseProvider)
                              .deleteAccount(account.id, userId);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'activity',
                        child: Text('Buchungen anzeigen'),
                      ),
                      PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                      PopupMenuItem(value: 'delete', child: Text('Löschen')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                money(account.balance, currency: account.currency),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${money(account.availableBalance, currency: account.currency)} verfügbar',
              ),
              if (account.iban.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  _maskIban(account.iban),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _maskIban(String value) {
    final compact = value.replaceAll(' ', '');
    if (compact.length <= 8) return compact;
    return '${compact.substring(0, 4)} •••• •••• ${compact.substring(compact.length - 4)}';
  }
}

Future<void> _showAccountActivity(
  BuildContext context,
  WidgetRef ref,
  Account account,
  List<LedgerEntry> entries,
) => showDialog<void>(
  context: context,
  builder: (context) => _AccountActivityDialog(
    account: account,
    entries: entries,
    onEdit: () {
      Navigator.pop(context);
      showAccountEditor(context, ref, account: account);
    },
  ),
);

class _AccountActivityDialog extends StatefulWidget {
  const _AccountActivityDialog({
    required this.account,
    required this.entries,
    required this.onEdit,
  });

  final Account account;
  final List<LedgerEntry> entries;
  final VoidCallback onEdit;

  @override
  State<_AccountActivityDialog> createState() => _AccountActivityDialogState();
}

class _AccountActivityDialogState extends State<_AccountActivityDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.entries.where((entry) {
      final text = [
        entry.merchant,
        entry.description,
        entry.category,
        entry.paymentMethod,
      ].join(' ').toLowerCase();
      return text.contains(_query);
    }).toList()..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          const Icon(Icons.account_balance_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.account.label),
                Text(
                  money(
                    widget.account.balance,
                    currency: widget.account.currency,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Konto bearbeiten',
            onPressed: widget.onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 720),
        height: (MediaQuery.sizeOf(context).height - 220).clamp(280, 620),
        child: Column(
          children: [
            TextField(
              autofocus: false,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                labelText: 'Buchungen durchsuchen',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Keine passenden Buchungen'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final entry = items[index];
                        final previous = index == 0 ? null : items[index - 1];
                        final showMonth =
                            previous == null ||
                            previous.bookingDate.year !=
                                entry.bookingDate.year ||
                            previous.bookingDate.month !=
                                entry.bookingDate.month;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showMonth)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                                child: Text(
                                  _accountMonthNames[entry.bookingDate.month -
                                          1] +
                                      ' ' +
                                      entry.bookingDate.year.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  entry.isIncome
                                      ? Icons.south_west_rounded
                                      : Icons.north_east_rounded,
                                ),
                              ),
                              title: Text(
                                entry.merchant.isEmpty
                                    ? entry.category
                                    : entry.merchant,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(entry.bookingDate) +
                                    ' · ' +
                                    entry.category,
                              ),
                              trailing: Text(
                                (entry.isIncome ? '+' : '−') +
                                    money(entry.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: entry.isIncome ? Colors.green : null,
                                ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}

const _accountMonthNames = [
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

Future<void> showAccountEditor(
  BuildContext context,
  WidgetRef ref, {
  Account? account,
}) async {
  final result = await showDialog<AccountsCompanion>(
    context: context,
    builder: (_) => _AccountEditor(account: account),
  );
  if (result != null) await ref.read(databaseProvider).saveAccount(result);
}

class _AccountEditor extends StatefulWidget {
  const _AccountEditor({this.account});
  final Account? account;

  @override
  State<_AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<_AccountEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bank = TextEditingController(
    text: widget.account?.bankName,
  );
  late final TextEditingController _label = TextEditingController(
    text: widget.account?.label,
  );
  late final TextEditingController _holder = TextEditingController(
    text: widget.account?.holder,
  );
  late final TextEditingController _iban = TextEditingController(
    text: widget.account?.iban,
  );
  late final TextEditingController _bic = TextEditingController(
    text: widget.account?.bic,
  );
  late final TextEditingController _number = TextEditingController(
    text: widget.account?.accountNumber,
  );
  late final TextEditingController _balance = TextEditingController(
    text: widget.account?.balance.toStringAsFixed(2),
  );
  late final TextEditingController _available = TextEditingController(
    text: widget.account?.availableBalance.toStringAsFixed(2),
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.account?.notes,
  );
  late String _currency = widget.account?.currency ?? 'EUR';

  @override
  void dispose() {
    for (final controller in [
      _bank,
      _label,
      _holder,
      _iban,
      _bic,
      _number,
      _balance,
      _available,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.account == null ? 'Konto anlegen' : 'Konto bearbeiten',
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 560.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _responsiveFields([
                  _field(_bank, 'Bankname', required: true),
                  _field(_label, 'Kontobezeichnung', required: true),
                ]),
                const SizedBox(height: 12),
                _field(_holder, 'Kontoinhaber'),
                const SizedBox(height: 12),
                _field(_iban, 'IBAN'),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(_bic, 'BIC'),
                  _field(_number, 'Kontonummer'),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(_balance, 'Kontostand', number: true, required: true),
                  _field(_available, 'Verfügbar', number: true, required: true),
                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    items: const ['EUR', 'USD', 'CHF', 'GBP']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => _currency = value ?? 'EUR',
                    decoration: const InputDecoration(labelText: 'Währung'),
                  ),
                ]),
                const SizedBox(height: 12),
                _field(_notes, 'Notizen', lines: 3),
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
  }

  Widget _responsiveFields(List<Widget> fields) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    if (compact) {
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

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    int lines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (required && (value?.trim().isEmpty ?? true)) return 'Pflichtfeld';
        if (number && _parse(value) == null) return 'Ungültige Zahl';
        return null;
      },
    );
  }

  double? _parse(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final userId = container.read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(
      context,
      AccountsCompanion.insert(
        id: widget.account?.id ?? const Uuid().v4(),
        userId: userId,
        bankName: _bank.text.trim(),
        label: _label.text.trim(),
        holder: Value(_holder.text.trim()),
        iban: Value(_iban.text.trim().toUpperCase()),
        bic: Value(_bic.text.trim().toUpperCase()),
        accountNumber: Value(_number.text.trim()),
        currency: Value(_currency),
        balance: Value(_parse(_balance.text) ?? 0),
        availableBalance: Value(_parse(_available.text) ?? 0),
        notes: Value(_notes.text.trim()),
        createdAt: widget.account?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
