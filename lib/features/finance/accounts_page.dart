import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/currencies.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  String _sortMode = 'custom';

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final histories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final investments =
        ref.watch(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final sales =
        ref.watch(portfolioSalesProvider).valueOrNull ??
        const <PortfolioSale>[];
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
                subtitle: '',
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
                  error: (error, _) => LoadErrorMessage(
                    'Konten konnten nicht geladen werden',
                    error: error,
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
                    final converter = ref.watch(currencyConverterProvider);
                    final total = items.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          converter.toBase(
                            accountBalanceAt(
                              account: item,
                              date: DateTime.now(),
                              histories: histories,
                              entries: entries,
                              investments: investments,
                              purchases: purchases,
                              sales: sales,
                            ),
                            item.currency,
                          ),
                    );
                    final sorted = _sortedAccounts(items);
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 260,
                            child: SearchableDropdownButtonFormField<String>(
                              initialValue: _sortMode,
                              decoration: const InputDecoration(
                                labelText: 'Konten sortieren',
                                prefixIcon: Icon(Icons.sort_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'custom',
                                  child: Text('Eigene Reihenfolge'),
                                ),
                                DropdownMenuItem(
                                  value: 'value-desc',
                                  child: Text('Größter Wert zuerst'),
                                ),
                                DropdownMenuItem(
                                  value: 'value-asc',
                                  child: Text('Kleinster Wert zuerst'),
                                ),
                                DropdownMenuItem(
                                  value: 'name',
                                  child: Text('Name A–Z'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _sortMode = value ?? 'custom'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = constraints.maxWidth < 700
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (
                                  var index = 0;
                                  index < sorted.length;
                                  index++
                                )
                                  SizedBox(
                                    width: cardWidth,
                                    child: _AccountCard(
                                      account: sorted[index],
                                      onMoveUp: index == 0
                                          ? null
                                          : () => _moveAccount(
                                              sorted,
                                              index,
                                              index - 1,
                                            ),
                                      onMoveDown: index == sorted.length - 1
                                          ? null
                                          : () => _moveAccount(
                                              sorted,
                                              index,
                                              index + 1,
                                            ),
                                    ),
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

  List<Account> _sortedAccounts(List<Account> accounts) {
    final result = [...accounts];
    switch (_sortMode) {
      case 'value-desc':
        result.sort((a, b) => b.balance.compareTo(a.balance));
      case 'value-asc':
        result.sort((a, b) => a.balance.compareTo(b.balance));
      case 'name':
        result.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
      default:
        result.sort((a, b) {
          final order = a.displayOrder.compareTo(b.displayOrder);
          return order == 0 ? a.label.compareTo(b.label) : order;
        });
    }
    return result;
  }

  Future<void> _moveAccount(
    List<Account> visible,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = [...visible];
    final account = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, account);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    setState(() => _sortMode = 'custom');
    await ref
        .read(databaseProvider)
        .reorderAccounts(userId, reordered.map((item) => item.id).toList());
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({
    required this.account,
    required this.onMoveUp,
    required this.onMoveDown,
  });
  final Account account;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme;
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final histories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
    final investments =
        ref.watch(allInvestmentsProvider).valueOrNull ?? const <Investment>[];
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final sales =
        ref.watch(portfolioSalesProvider).valueOrNull ??
        const <PortfolioSale>[];
    final currentBalance = accountBalanceAt(
      account: account,
      date: DateTime.now(),
      histories: histories,
      entries: entries,
      investments: investments,
      purchases: purchases,
      sales: sales,
    );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: account.usageType == 'portfolio'
            ? null
            : () => _showAccountActivity(
                context,
                ref,
                account,
                entries
                    .where((entry) => entry.accountId == account.id)
                    .toList(),
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
                          '${account.bankName} · ${switch (account.usageType) {
                            'household' => 'Haushaltskonto',
                            'portfolio' => 'Portfolio-Konto',
                            _ => 'Nicht zugeordnet',
                          }}',
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
                      } else if (value == 'up') {
                        onMoveUp?.call();
                      } else if (value == 'down') {
                        onMoveDown?.call();
                      } else if (value == 'edit') {
                        await showAccountEditor(context, ref, account: account);
                      } else if (value == 'history') {
                        await _showBalanceHistory(context, ref, account);
                      } else if (value == 'delete' &&
                          await confirmDelete(
                            context,
                            title: 'Konto löschen?',
                            message: _deleteAccountMessage(
                              account,
                              ref.read(ledgerEntriesProvider).valueOrNull ??
                                  const <LedgerEntry>[],
                            ),
                          )) {
                        final userId = ref.read(currentUserIdProvider);
                        if (userId != null) {
                          await ref
                              .read(databaseProvider)
                              .deleteAccount(account.id, userId);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      if (account.usageType != 'portfolio')
                        const PopupMenuItem(
                          value: 'activity',
                          child: Text('Buchungen anzeigen'),
                        ),
                      PopupMenuItem(
                        value: 'up',
                        enabled: onMoveUp != null,
                        child: const Text('Nach oben'),
                      ),
                      PopupMenuItem(
                        value: 'down',
                        enabled: onMoveDown != null,
                        child: const Text('Nach unten'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Bearbeiten'),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: Text('Kontostand-Historie'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Löschen'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                money(currentBalance, currency: account.currency),
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
                                  '${_accountMonthNames[entry.bookingDate.month - 1]} '
                                  '${entry.bookingDate.year}',
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
                                '${DateFormat('dd.MM.yyyy').format(entry.bookingDate)} '
                                '· ${entry.category}',
                              ),
                              trailing: Text(
                                (entry.isIncome ? '+' : '−') +
                                    money(entry.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: entry.isIncome
                                      ? Colors.green
                                      : Colors.redAccent,
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

Future<void> _showBalanceHistory(
  BuildContext context,
  WidgetRef ref,
  Account account,
) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text('${account.label} · Kontostand-Historie'),
    content: SizedBox(
      width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 620),
      height: (MediaQuery.sizeOf(context).height - 240).clamp(260, 560),
      child: Consumer(
        builder: (context, dialogRef, _) {
          final histories = <AccountBalanceHistory>[
            ...?dialogRef
                .watch(accountBalanceHistoriesProvider)
                .valueOrNull
                ?.where((row) => row.accountId == account.id),
          ];
          histories.sort((a, b) => b.effectiveAt.compareTo(a.effectiveAt));
          if (histories.isEmpty) {
            return const Center(
              child: Text('Noch keine datierten Kontostände vorhanden.'),
            );
          }
          return ListView.separated(
            itemCount: histories.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = histories[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded),
                title: Text(
                  money(row.balance, currency: account.currency),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  'Gültig ab ${DateFormat('dd.MM.yyyy').format(row.effectiveAt)} · '
                  '${money(row.availableBalance, currency: account.currency)} verfügbar',
                ),
                trailing: IconButton(
                  tooltip: 'Historienwert löschen',
                  onPressed: () async {
                    final confirmed = await confirmDelete(
                      context,
                      title: 'Historienwert löschen?',
                      message:
                          'Der Kontostand vom ${DateFormat('dd.MM.yyyy').format(row.effectiveAt)} wird entfernt.',
                    );
                    if (!confirmed) return;
                    final userId = dialogRef.read(currentUserIdProvider);
                    if (userId != null) {
                      await dialogRef
                          .read(databaseProvider)
                          .deleteAccountBalanceHistory(row.id, userId);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              );
            },
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Schließen'),
      ),
      FilledButton.icon(
        onPressed: () => _addBalanceHistoryPoint(dialogContext, ref, account),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kontostand'),
      ),
    ],
  ),
);

Future<void> _addBalanceHistoryPoint(
  BuildContext context,
  WidgetRef ref,
  Account account,
) async {
  final balance = TextEditingController(
    text: account.balance.toStringAsFixed(2),
  );
  final available = TextEditingController(
    text: account.availableBalance.toStringAsFixed(2),
  );
  final key = GlobalKey<FormState>();
  var effectiveAt = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Datierten Kontostand hinzufügen'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: balance,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Kontostand'),
                validator: (value) => _parseAccountNumber(value) == null
                    ? 'Ungültige Zahl'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: available,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Verfügbar'),
                validator: (value) => _parseAccountNumber(value) == null
                    ? 'Ungültige Zahl'
                    : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: effectiveAt,
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setDialogState(() => effectiveAt = date);
                  }
                },
                icon: const Icon(Icons.event_rounded),
                label: Text(DateFormat('dd.MM.yyyy').format(effectiveAt)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .saveAccountBalanceHistory(
              userId: userId,
              accountId: account.id,
              effectiveAt: effectiveAt,
              balance: _parseAccountNumber(balance.text)!,
              availableBalance: _parseAccountNumber(available.text)!,
            );
      }
    }, source: 'Kontostand speichern');
  }
  balance.dispose();
  available.dispose();
}

double? _parseAccountNumber(String? value) => parseAmount(value);

Future<void> showAccountEditor(
  BuildContext context,
  WidgetRef ref, {
  Account? account,
}) async {
  final result =
      await showDialog<({AccountsCompanion account, DateTime effectiveAt})>(
        context: context,
        builder: (_) => _AccountEditor(account: account),
      );
  if (result != null && context.mounted) {
    await saveWithFeedback(context, () async {
      await ref
          .read(databaseProvider)
          .saveAccount(result.account, balanceEffectiveAt: result.effectiveAt);
    }, source: 'Konto speichern');
  }
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
  late String _usageType = widget.account?.usageType ?? 'unassigned';
  DateTime _validFrom = DateTime.now();

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
                SearchableDropdownButtonFormField<String>(
                  initialValue: _usageType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Verwendung'),
                  items:
                      const {
                            'unassigned': 'Nicht zugeordnet',
                            'household': 'Haushaltsbuch',
                            'portfolio': 'Portfolio',
                          }.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                  onChanged:
                      widget.account != null &&
                          widget.account!.usageType != 'unassigned'
                      ? null
                      : (value) => _usageType = value ?? 'unassigned',
                ),
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
                  SearchableDropdownButtonFormField<String>(
                    initialValue: _currency,
                    items: supportedIsoCurrencies
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickValidFrom,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(
                      'Kontostand gültig ab ${DateFormat('dd.MM.yyyy').format(_validFrom)}',
                    ),
                  ),
                ),
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

  double? _parse(String? value) => parseAmount(value);

  Future<void> _pickValidFrom() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _validFrom,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _validFrom = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final userId = container.read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(context, (
      account: AccountsCompanion.insert(
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
        usageType: Value(_usageType),
        notes: Value(_notes.text.trim()),
        createdAt: widget.account?.createdAt ?? now,
        updatedAt: now,
      ),
      effectiveAt: _validFrom,
    ));
  }
}

String _deleteAccountMessage(Account account, List<LedgerEntry> entries) {
  final count = entries.where((entry) => entry.accountId == account.id).length;
  final base = '${account.label} wird aus allen Übersichten entfernt.';
  if (count == 0) return base;
  return '$base ${count == 1 ? 'Eine Buchung bleibt' : '$count Buchungen bleiben'} '
      'im Haushaltsbuch erhalten, wird aber keinem Konto mehr zugerechnet.';
}
