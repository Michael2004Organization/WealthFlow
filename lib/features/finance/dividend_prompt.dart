import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/dividend_projection.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

String _autoBookKey(String userId) => 'dividends.autoBook.$userId';

/// Whether dividends with a known payment date are booked without asking.
/// Kept per device, like the dashboard layout.
final dividendAutoBookProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return false;
  final preferences = await SharedPreferences.getInstance();
  return preferences.getBool(_autoBookKey(userId)) ?? false;
});

Future<void> setDividendAutoBook(WidgetRef ref, bool value) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setBool(_autoBookKey(userId), value);
  ref.invalidate(dividendAutoBookProvider);
}

/// The account a payout goes to unless the user picks another one: the
/// position's own account, otherwise the chosen household account.
String? _defaultAccount(WidgetRef ref, Investment investment) {
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  bool exists(String id) =>
      id.isNotEmpty && accounts.any((account) => account.id == id);
  if (exists(investment.accountId)) return investment.accountId;
  final household = ref
      .read(preferencesProvider)
      .valueOrNull
      ?.selectedHouseholdAccountId;
  if (household != null && exists(household)) return household;
  return accounts.firstOrNull?.id;
}

/// "Dividende Apple 42,10 € (nach Steuern) eingegangen?" on the dashboard.
class DividendPromptCard extends ConsumerStatefulWidget {
  const DividendPromptCard({required this.pending, super.key});

  final List<ProjectedDividend> pending;

  @override
  ConsumerState<DividendPromptCard> createState() => _DividendPromptState();
}

class _DividendPromptState extends ConsumerState<DividendPromptCard> {
  final _autoBooked = <String>{};

  @override
  Widget build(BuildContext context) {
    final auto = ref.watch(dividendAutoBookProvider).valueOrNull ?? false;
    if (auto) _bookAutomatically();
    final colors = WealthColors.of(context);
    final pending = widget.pending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconTile(
                  icon: Icons.payments_outlined,
                  background: colors.incomeSoft,
                  foreground: colors.income,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pending.length == 1
                        ? 'Dividende eingegangen?'
                        : '${pending.length} Dividenden eingegangen?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final payment in pending.take(3)) _row(payment),
            if (pending.length > 3)
              Text(
                '+ ${pending.length - 3} weitere',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
            const SizedBox(height: 4),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: auto,
              onChanged: (value) => setDividendAutoBook(ref, value),
              title: const Text('Mit bekanntem Zahltag automatisch buchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ProjectedDividend payment) {
    final colors = WealthColors.of(context);
    final when = payment.paymentDateKnown
        ? shortDate(payment.date)
        : 'erwartet im ${monthNames[payment.date.month - 1]}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.investment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${money(payment.tax.net, currency: payment.accountCurrency)}'
                  ' nach Steuern · $when',
                  style: TextStyle(fontSize: 12, color: colors.muted),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: () => _skip(payment),
                child: const Text('Nicht erhalten'),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    showDividendReceiptDialog(context, ref, payment),
                child: const Text('Übernehmen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _skip(ProjectedDividend payment) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await saveWithFeedback(
      context,
      () => ref
          .read(databaseProvider)
          .skipDividend(
            userId: userId,
            investmentId: payment.investment.id,
            paymentDate: payment.date,
          ),
      source: 'Dividende',
    );
  }

  /// Books payouts whose date is known on the position's own account.
  void _bookAutomatically() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final due = [
      for (final payment in widget.pending)
        if (payment.paymentDateKnown &&
            _autoBooked.add(
              dividendReceiptId(payment.investment.id, payment.date),
            ))
          payment,
    ];
    if (due.isEmpty) return;
    final database = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    Future<void>.microtask(() async {
      var booked = 0;
      for (final payment in due) {
        final accountId = _defaultAccount(ref, payment.investment);
        if (accountId == null) continue;
        try {
          await database.receiveDividend(
            userId: userId,
            investment: payment.investment,
            accountId: accountId,
            dueDate: payment.date,
            amount: payment.tax.net,
          );
          booked++;
        } catch (error) {
          debugPrint('Dividende nicht automatisch gebucht: $error');
        }
      }
      if (booked > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              booked == 1
                  ? '1 Dividende automatisch gebucht'
                  : '$booked Dividenden automatisch gebucht',
            ),
          ),
        );
      }
    });
  }
}

/// Confirms one payout with an editable amount, date and account.
Future<void> showDividendReceiptDialog(
  BuildContext context,
  WidgetRef ref,
  ProjectedDividend payment,
) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final accounts = (ref.read(accountsProvider).valueOrNull ?? const <Account>[])
      .where(
        (account) =>
            account.id == payment.investment.accountId ||
            account.usageType != 'portfolio',
      )
      .toList();
  final amount = TextEditingController(
    text: formatAmountInput(double.parse(payment.tax.net.toStringAsFixed(2))),
  );
  var accountId = _defaultAccount(ref, payment.investment);
  if (!accounts.any((account) => account.id == accountId)) {
    accountId = accounts.firstOrNull?.id;
  }
  var date = DateUtils.dateOnly(
    payment.date.isAfter(DateTime.now()) ? DateTime.now() : payment.date,
  );
  final formKey = GlobalKey<FormState>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Dividende ${payment.investment.name}'),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 440),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('dividend-amount'),
                  controller: amount,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Eingegangen (nach Steuern)',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixText: payment.accountCurrency,
                    helperText:
                        'Erwartet: ${money(payment.tax.net, currency: payment.accountCurrency)}',
                  ),
                  validator: (value) => (parseAmount(value) ?? 0) <= 0
                      ? 'Bitte einen positiven Betrag eingeben.'
                      : null,
                ),
                const SizedBox(height: 12),
                SearchableDropdownButtonFormField<String>(
                  initialValue: accountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Auf Konto',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  items: [
                    for (final account in accounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          account.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  validator: (value) =>
                      value == null ? 'Bitte ein Konto wählen.' : null,
                  onChanged: (value) => accountId = value,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: date,
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(DateFormat('dd.MM.yyyy').format(date)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    ),
  );
  final value = parseAmount(amount.text) ?? 0;
  amount.dispose();
  if (confirmed != true || accountId == null || !context.mounted) return;
  final database = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  final done = await saveWithFeedback(
    context,
    () => database.receiveDividend(
      userId: userId,
      investment: payment.investment,
      accountId: accountId!,
      dueDate: payment.date,
      paymentDate: date,
      amount: value,
    ),
    failure: 'Dividende nicht gebucht',
    source: 'Dividende',
  );
  if (!done) return;
  messenger.showSnackBar(
    SnackBar(
      content: const Text('Dividende gebucht'),
      action: SnackBarAction(
        label: 'Rückgängig',
        onPressed: () => database.undoDividendReceipt(
          dividendReceiptId(payment.investment.id, payment.date),
          userId,
        ),
      ),
    ),
  );
}
