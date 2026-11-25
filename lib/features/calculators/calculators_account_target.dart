part of 'calculators_page.dart';

class _AccountTargetCalculator extends ConsumerStatefulWidget {
  const _AccountTargetCalculator();

  @override
  ConsumerState<_AccountTargetCalculator> createState() =>
      _AccountTargetCalculatorState();
}

class _AccountTargetCalculatorState
    extends ConsumerState<_AccountTargetCalculator> {
  final _target = TextEditingController(text: '10000');
  String? _accountId;
  DateTime _endMonth = DateTime(DateTime.now().year, DateTime.now().month + 12);

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final validIds = accounts.map((item) => item.id).toSet();
    final selectedId = validIds.contains(_accountId)
        ? _accountId
        : accounts.firstOrNull?.id;
    final account = accounts.where((item) => item.id == selectedId).firstOrNull;
    final target = _value(_target.text);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final plannedAll =
        entries.where((entry) {
          final effective = ledgerEffectiveDate(
            entry.bookingDate,
            entry.budgetMonth,
          );
          return entry.accountId == selectedId && effective.isAfter(todayOnly);
        }).toList()..sort(
          (a, b) => ledgerEffectiveDate(
            a.bookingDate,
            a.budgetMonth,
          ).compareTo(ledgerEffectiveDate(b.bookingDate, b.budgetMonth)),
        );
    var scanBalance = account?.balance ?? 0;
    DateTime? reachedAt = account != null && account.balance >= target
        ? todayOnly
        : null;
    for (final entry in plannedAll) {
      scanBalance += entry.isIncome ? entry.amount : -entry.amount;
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      if (reachedAt == null && scanBalance >= target) reachedAt = effective;
    }
    final startMonth = DateTime(today.year, today.month);
    final minimumEndMonth = reachedAt == null
        ? startMonth
        : DateTime(reachedAt.year, reachedAt.month);
    final configuredEnd = DateTime(_endMonth.year, _endMonth.month);
    final effectiveEnd = configuredEnd.isBefore(minimumEndMonth)
        ? minimumEndMonth
        : configuredEnd;
    final endExclusive = DateTime(effectiveEnd.year, effectiveEnd.month + 1);
    final planned = plannedAll.where((entry) {
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      return effective.isBefore(endExclusive);
    }).toList();
    var projected = account?.balance ?? 0;
    final development = <(DateTime, double, LedgerEntry)>[];
    for (final entry in planned) {
      projected += entry.isIncome ? entry.amount : -entry.amount;
      final effective = ledgerEffectiveDate(
        entry.bookingDate,
        entry.budgetMonth,
      );
      development.add((effective, projected, entry));
    }
    return _CalculatorScaffold(
      title: 'Kontoziel-Rechner',
      resultHeight: 500,
      verticalResultHeight: 600,
      input: Column(
        children: [
          SearchableDropdownButtonFormField<String>(
            key: ValueKey(selectedId),
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Konto',
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
            items: accounts
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      '${item.label} · ${money(item.balance, currency: item.currency)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: 14),
          _NumberField(
            controller: _target,
            label: 'Gewünschter Kontostand',
            suffix: '€',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Start'),
                  child: Text(DateFormat('MM.yyyy').format(startMonth)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickEndMonth(minimumEndMonth, effectiveEnd),
                  icon: const Icon(Icons.event_rounded),
                  label: Text(
                    'Ende ${DateFormat('MM.yyyy').format(effectiveEnd)}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            planned.isEmpty
                ? 'Für dieses Konto liegen keine zukünftigen Buchungen vor.'
                : '${planned.length} zukünftige Buchungen werden wirtschaftlich eingeordnet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      result: account == null
          ? const Center(child: Text('Bitte zuerst ein Konto anlegen.'))
          : ListView(
              children: [
                Icon(
                  reachedAt == null
                      ? Icons.hourglass_empty_rounded
                      : Icons.flag_circle_rounded,
                  size: 54,
                  color: reachedAt == null
                      ? WealthColors.of(context).expense
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  reachedAt == null
                      ? 'Ziel mit vorhandener Planung nicht erreicht'
                      : reachedAt == todayOnly
                      ? 'Ziel bereits erreicht'
                      : 'Ziel am ${DateFormat('dd.MM.yyyy').format(reachedAt)} erreicht',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    _Result(
                      label: 'Heute',
                      value: money(account.balance, currency: account.currency),
                    ),
                    _Result(label: 'Ziel', value: money(target)),
                    _Result(
                      label:
                          'Ende ${DateFormat('MM.yyyy').format(effectiveEnd)}',
                      value: money(projected),
                      color: projected >= target
                          ? WealthColors.of(context).income
                          : WealthColors.of(context).expense,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (development.isNotEmpty) ...[
                  Text(
                    'Geplante Entwicklung',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final item in development)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item.$3.isIncome
                            ? Icons.add_circle_outline_rounded
                            : Icons.remove_circle_outline_rounded,
                        color: item.$3.isIncome
                            ? WealthColors.of(context).income
                            : WealthColors.of(context).expense,
                      ),
                      title: Text(
                        item.$3.merchant.isEmpty
                            ? item.$3.description
                            : item.$3.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${DateFormat('dd.MM.yyyy').format(item.$1)}'
                        ' · wirtschaftlicher Termin',
                      ),
                      trailing: Text(
                        money(item.$2),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  Future<void> _pickEndMonth(DateTime minimum, DateTime initial) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: minimum,
      lastDate: DateTime(2100, 12, 31),
      initialDate: initial.isBefore(minimum) ? minimum : initial,
      helpText: 'Endmonat der Planung wählen',
    );
    if (selected != null) {
      setState(() => _endMonth = DateTime(selected.year, selected.month));
    }
  }
}
