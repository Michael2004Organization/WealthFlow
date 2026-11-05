import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/standing_order_schedule.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

const _kinds = {
  'expense': 'Ausgabe',
  'income': 'Einnahme',
  'transfer': 'Umbuchung',
  'saving': 'Sparen',
};

const _intervals = {
  'monthly': 'Monatlich',
  'quarterly': 'Vierteljährlich',
  'yearly': 'Jährlich',
};

/// The next booking of [order] after today, or null once it has ended.
DateTime? nextStandingOrderBooking(StandingOrder order, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final last = order.lastDueDate;
  return nextStandingOrderDueDate(
    interval: order.interval,
    dayOfMonth: order.dayOfMonth,
    start: order.startDate,
    end: order.endDate,
    after: last != null && last.isAfter(day) ? last : day,
  );
}

/// Bookings the [orders] will create after [after] (exclusive) up to
/// [through], sorted by date. They do not exist as entries yet.
List<({StandingOrder order, DateTime date})> plannedStandingOrderBookings(
  List<StandingOrder> orders, {
  required DateTime after,
  required DateTime through,
}) {
  final day = DateTime(after.year, after.month, after.day);
  return [
    for (final order in orders)
      for (final date in standingOrderDueDates(
        interval: order.interval,
        dayOfMonth: order.dayOfMonth,
        start: order.startDate,
        end: order.endDate,
        after: order.lastDueDate != null && order.lastDueDate!.isAfter(day)
            ? order.lastDueDate
            : day,
        through: through,
      ))
        (order: order, date: date),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

class StandingOrdersPage extends ConsumerWidget {
  const StandingOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(standingOrdersProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Daueraufträge',
                action: FilledButton.icon(
                  onPressed: () => showStandingOrderEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Dauerauftrag'),
                ),
              ),
              Expanded(
                child: orders.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => LoadErrorMessage(
                    'Daueraufträge konnten nicht geladen werden',
                    error: error,
                  ),
                  data: (items) => items.isEmpty
                      ? EmptyState(
                          icon: Icons.event_repeat_rounded,
                          title: 'Noch keine Daueraufträge',
                          message:
                              'Miete, Gehalt oder Sparplan einmal anlegen: '
                              'die Buchung entsteht jeden Monat am '
                              'Fälligkeitstag, ohne festes Ende.',
                          action: FilledButton.icon(
                            onPressed: () =>
                                showStandingOrderEditor(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Dauerauftrag anlegen'),
                          ),
                        )
                      : _StandingOrderList(orders: items),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingOrderList extends StatelessWidget {
  const _StandingOrderList({required this.orders});

  final List<StandingOrder> orders;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final active = orders
        .where((order) => nextStandingOrderBooking(order, today: today) != null)
        .toList();
    final ended = orders.where((order) => !active.contains(order)).toList();
    double monthly(String kind) => active
        .where((order) => order.kind == kind)
        .fold(
          0.0,
          (sum, order) =>
              sum + order.amount / standingOrderStep(order.interval),
        );
    final colors = WealthColors.of(context);
    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Total('Ausgaben pro Monat', monthly('expense'), colors.expense),
            _Total('Einnahmen pro Monat', monthly('income'), colors.income),
            _Total('Sparen pro Monat', monthly('saving'), colors.neutral),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              for (final (index, order) in active.indexed) ...[
                if (index > 0) Divider(height: 1, color: colors.border),
                _StandingOrderTile(order: order),
              ],
            ],
          ),
        ),
        if (ended.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Eyebrow('Beendet'),
          ),
          Card(
            child: Column(
              children: [
                for (final (index, order) in ended.indexed) ...[
                  if (index > 0) Divider(height: 1, color: colors.border),
                  _StandingOrderTile(order: order),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 180),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label),
            const SizedBox(height: 4),
            Text(
              money(value),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: value == 0 ? null : color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StandingOrderTile extends ConsumerWidget {
  const _StandingOrderTile({required this.order});

  final StandingOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    String accountLabel(String id) =>
        accounts.where((account) => account.id == id).firstOrNull?.label ?? '';
    final next = nextStandingOrderBooking(order);
    final linked = order.kind == 'transfer' || order.kind == 'saving';
    final income = order.kind == 'income';
    final route = [
      accountLabel(order.accountId),
      if (linked) accountLabel(order.targetAccountId),
    ].where((label) => label.isNotEmpty).join(' → ');
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      onTap: () => showStandingOrderEditor(context, ref, order: order),
      leading: IconTile(
        icon: switch (order.kind) {
          'income' => Icons.south_west_rounded,
          'transfer' => Icons.swap_horiz_rounded,
          'saving' => Icons.savings_outlined,
          _ => Icons.north_east_rounded,
        },
        background: linked
            ? colors.neutralSoft
            : income
            ? colors.incomeSoft
            : colors.expenseSoft,
        foreground: linked
            ? colors.neutral
            : income
            ? colors.income
            : colors.expense,
      ),
      title: Text(
        order.merchant.isNotEmpty
            ? order.merchant
            : order.description.isNotEmpty
            ? order.description
            : order.category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          '${_intervals[order.interval]} am ${order.dayOfMonth}.',
          if (next != null) 'nächste ${shortDate(next)}' else 'beendet',
          if (route.isNotEmpty) route,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: colors.muted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(
            order.amount,
            income: income,
            neutral: linked,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handle(context, ref, value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
              if (next != null)
                const PopupMenuItem(value: 'end', child: Text('Beenden')),
              const PopupMenuItem(value: 'delete', child: Text('Löschen')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    if (value == 'edit') {
      await showStandingOrderEditor(context, ref, order: order);
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final end = value == 'end';
    final confirmed = await confirmDelete(
      context,
      title: end ? 'Dauerauftrag beenden?' : 'Dauerauftrag löschen?',
      message: end
          ? 'Ab morgen entstehen keine neuen Buchungen mehr. Bereits '
                'gebuchte bleiben erhalten.'
          : 'Der Dauerauftrag verschwindet. Bereits gebuchte Zahlungen '
                'bleiben im Haushaltsbuch.',
    );
    if (!confirmed || !context.mounted) return;
    final database = ref.read(databaseProvider);
    await saveWithFeedback(
      context,
      () => end
          ? database.endStandingOrder(order.id, userId)
          : database.deleteStandingOrder(order.id, userId),
      failure: end ? 'Beenden fehlgeschlagen' : 'Löschen fehlgeschlagen',
      source: 'Dauerauftrag',
    );
  }
}

/// Creates or edits a standing order. A change applies from the next due
/// date on; bookings already made stay as they are.
Future<void> showStandingOrderEditor(
  BuildContext context,
  WidgetRef ref, {
  StandingOrder? order,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  // Read as futures: the page may be the first to need them.
  final allAccounts = await ref.read(accountsProvider.future);
  final accounts = householdAccounts(
    allAccounts,
    investments: await ref.read(allInvestmentsProvider.future),
    physicalAssets: await ref.read(physicalAssetsProvider.future),
  );
  if (!context.mounted) return;
  if (accounts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lege zuerst ein Haushaltskonto unter Vermögen an.'),
      ),
    );
    return;
  }
  final preferred = ref
      .read(preferencesProvider)
      .valueOrNull
      ?.selectedHouseholdAccountId;
  final value = await showDialog<StandingOrdersCompanion>(
    context: context,
    builder: (_) => _StandingOrderEditor(
      userId: userId,
      order: order,
      accounts: accounts,
      targetAccounts: allAccounts,
      defaultAccountId:
          accounts.where((item) => item.id == preferred).firstOrNull?.id ??
          accounts.first.id,
    ),
  );
  if (value == null || !context.mounted) return;
  await saveWithFeedback(
    context,
    () => ref.read(databaseProvider).saveStandingOrder(value),
    failure: 'Dauerauftrag nicht gespeichert',
    source: 'Dauerauftrag speichern',
  );
}

class _StandingOrderEditor extends StatefulWidget {
  const _StandingOrderEditor({
    required this.userId,
    required this.order,
    required this.accounts,
    required this.targetAccounts,
    required this.defaultAccountId,
  });

  final String userId;
  final StandingOrder? order;
  final List<Account> accounts;
  final List<Account> targetAccounts;
  final String defaultAccountId;

  @override
  State<_StandingOrderEditor> createState() => _StandingOrderEditorState();
}

class _StandingOrderEditorState extends State<_StandingOrderEditor> {
  final _formKey = GlobalKey<FormState>();
  late final StandingOrder? _order = widget.order;
  late String _kind = _order?.kind ?? 'expense';
  late String _interval = _order?.interval ?? 'monthly';
  late String _accountId = _order?.accountId ?? widget.defaultAccountId;
  late String _targetAccountId = _order?.targetAccountId ?? '';
  late int _day = _order?.dayOfMonth ?? DateTime.now().day;
  late DateTime _start = _order?.startDate ?? DateTime.now();
  late DateTime? _end = _order?.endDate;
  late final _amount = TextEditingController(
    text: _order == null ? '' : formatAmountInput(_order.amount),
  );
  late final _merchant = TextEditingController(text: _order?.merchant ?? '');
  late final _category = TextEditingController(text: _order?.category ?? '');
  late final _description = TextEditingController(
    text: _order?.description ?? '',
  );

  bool get _linked => _kind == 'transfer' || _kind == 'saving';

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool end}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650 * 3)),
      initialDate: end ? (_end ?? DateTime.now()) : _start,
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _end = picked;
      } else {
        _start = picked;
        if (_order == null) _day = picked.day;
      }
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now().toUtc();
    final start = DateTime(_start.year, _start.month, _start.day);
    final order = _order;
    Navigator.pop(
      context,
      StandingOrdersCompanion.insert(
        id: order?.id ?? const Uuid().v4(),
        userId: widget.userId,
        accountId: _accountId,
        targetAccountId: Value(_linked ? _targetAccountId : ''),
        kind: Value(_kind),
        amount: parseAmount(_amount.text) ?? 0,
        category: Value(
          _category.text.trim().isEmpty
              ? (_kind == 'income' ? 'Gehalt' : 'Sonstiges')
              : _category.text.trim(),
        ),
        merchant: Value(_merchant.text.trim()),
        description: Value(_description.text.trim()),
        interval: Value(_interval),
        dayOfMonth: _day,
        startDate: start,
        endDate: Value(_end == null ? null : DateUtils.dateOnly(_end!)),
        // Kept, so a changed rhythm never books a past date again.
        lastDueDate: Value(order?.lastDueDate),
        createdAt: order?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    return AlertDialog(
      title: Text(
        _order == null ? 'Dauerauftrag anlegen' : 'Dauerauftrag bearbeiten',
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 560),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: [
                    for (final MapEntry(:key, :value) in _kinds.entries)
                      ButtonSegment(value: key, label: _FitLabel(value)),
                  ],
                  selected: {_kind},
                  showSelectedIcon: false,
                  onSelectionChanged: _order == null
                      ? (value) => setState(() => _kind = value.first)
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('standing-order-amount'),
                  controller: _amount,
                  autofocus: _order == null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Betrag *',
                    prefixIcon: Icon(Icons.euro_rounded),
                  ),
                  validator: (value) => (parseAmount(value) ?? 0) <= 0
                      ? 'Bitte einen positiven Betrag eingeben.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _merchant,
                  decoration: InputDecoration(
                    labelText: _kind == 'income'
                        ? 'Von (z. B. Arbeitgeber)'
                        : 'Empfänger / Name *',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                  ),
                  validator: (value) =>
                      _kind != 'income' && (value?.trim().isEmpty ?? true)
                      ? 'Bitte einen Namen eingeben.'
                      : null,
                ),
                if (!_linked) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategorie',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SearchableDropdownButtonFormField<String>(
                  initialValue: _accountId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _linked ? 'Von Konto *' : 'Konto *',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
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
                  onChanged: (value) =>
                      setState(() => _accountId = value ?? _accountId),
                ),
                if (_linked) ...[
                  const SizedBox(height: 12),
                  SearchableDropdownButtonFormField<String>(
                    initialValue: _targetAccountId.isEmpty
                        ? null
                        : _targetAccountId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: _kind == 'saving'
                          ? 'Zielkonto / Investkonto *'
                          : 'Zielkonto *',
                      prefixIcon: const Icon(Icons.redo_rounded),
                    ),
                    items: [
                      for (final account in widget.targetAccounts)
                        if (account.id != _accountId)
                          DropdownMenuItem(
                            value: account.id,
                            child: Text(
                              account.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Bitte ein Zielkonto auswählen.'
                        : null,
                    onChanged: (value) => _targetAccountId = value ?? '',
                  ),
                ],
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: [
                    for (final MapEntry(:key, :value) in _intervals.entries)
                      ButtonSegment(value: key, label: _FitLabel(value)),
                  ],
                  selected: {_interval},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) =>
                      setState(() => _interval = value.first),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _day,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Am Tag'),
                        items: [
                          for (var day = 1; day <= 31; day++)
                            DropdownMenuItem(value: day, child: Text('$day.')),
                        ],
                        onChanged: (value) =>
                            setState(() => _day = value ?? _day),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(end: false),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: _FitLabel('ab ${dateFormat.format(_start)}'),
                      ),
                    ),
                  ],
                ),
                if (_day > 28)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'In kürzeren Monaten wird am letzten Tag gebucht.',
                      style: TextStyle(
                        fontSize: 12,
                        color: WealthColors.of(context).muted,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(end: true),
                        icon: const Icon(Icons.stop_rounded),
                        label: Text(
                          _end == null
                              ? 'Ohne Ende'
                              : 'bis ${dateFormat.format(_end!)}',
                        ),
                      ),
                    ),
                    if (_end != null)
                      IconButton(
                        tooltip: 'Ende entfernen',
                        onPressed: () => setState(() => _end = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(
                    labelText: 'Notiz',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
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
  }
}

/// Shrinks a segment label instead of overflowing on narrow phones.
class _FitLabel extends StatelessWidget {
  const _FitLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
}
