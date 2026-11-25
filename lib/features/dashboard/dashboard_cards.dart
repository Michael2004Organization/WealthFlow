part of 'dashboard_page.dart';

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.income,
    required this.expenses,
    required this.planned,
    required this.onTap,
  });

  final DateTime month;
  final double income;
  final double expenses;
  final double planned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final saved = income - expenses;
    final rate = income <= 0 ? null : saved / income;
    final now = DateTime.now();
    final current = month.year == now.year && month.month == now.month;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    Widget line(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: colors.muted)),
          ),
          value,
        ],
      ),
    );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      monthNames[month.month - 1],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (current)
                    Text(
                      'Tag ${now.day} von $days',
                      style: TextStyle(fontSize: 12, color: colors.muted),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rate == null ? '–' : '${(rate * 100).toStringAsFixed(0)} %',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Sparquote',
                      style: TextStyle(color: colors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (rate ?? 0).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: colors.neutralSoft,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              line('Einnahmen', AmountText(income, income: true)),
              line('Ausgaben', AmountText(expenses, income: false)),
              if (planned > 0)
                line(
                  'Davon noch geplant',
                  Text(
                    signedMoney(planned, income: false),
                    style: TextStyle(
                      color: colors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Divider(height: 18, color: colors.border),
              line(
                'Übrig',
                AmountText(
                  saved.abs(),
                  income: saved >= 0,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.dateBadge,
  });

  final String title;
  final String subtitle;
  final Widget amount;
  final Widget icon;
  final DateTime? dateBadge;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (dateBadge != null)
            Container(
              width: 40,
              height: 44,
              decoration: BoxDecoration(
                color: colors.neutralSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shortMonthName(dateBadge!).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.muted,
                    ),
                  ),
                  Text(
                    '${dateBadge!.day}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          amount,
        ],
      ),
    );
  }
}

Widget _entryIcon(BuildContext context, LedgerEntry entry) {
  final colors = WealthColors.of(context);
  final linked = entry.sourceType == 'transfer' || entry.sourceType == 'saving';
  if (linked) {
    return IconTile(
      icon: entry.sourceType == 'saving'
          ? Icons.savings_outlined
          : Icons.swap_horiz_rounded,
      background: colors.neutralSoft,
      foreground: colors.neutral,
    );
  }
  return IconTile(
    icon: entry.sourceType == 'vehicle'
        ? Icons.directions_car_outlined
        : entry.isIncome
        ? Icons.south_west_rounded
        : Icons.north_east_rounded,
    background: entry.isIncome ? colors.incomeSoft : colors.expenseSoft,
    foreground: entry.isIncome ? colors.income : colors.expense,
  );
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries({required this.entries, required this.onShowAll});

  final List<LedgerEntry> entries;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final recent =
        entries
            .where(
              (entry) =>
                  !entry.bookingDate.isAfter(now) &&
                  // Show each transfer once, from the paying account.
                  !(entry.isIncome &&
                      (entry.sourceType == 'transfer' ||
                          entry.sourceType == 'saving')),
            )
            .toList()
          ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Letzte Buchungen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: onShowAll, child: const Text('Alle')),
              ],
            ),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Noch keine Buchungen. Tippe auf +, um die erste zu erfassen.',
                  style: TextStyle(color: WealthColors.of(context).muted),
                ),
              ),
            for (final entry in recent.take(5))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _EntryRow(
                  title: entry.sourceType == 'transfer'
                      ? 'Umbuchung'
                      : entry.merchant.isEmpty
                      ? (entry.description.isEmpty
                            ? entry.category
                            : entry.description)
                      : entry.merchant,
                  subtitle: [
                    if (entry.category.isNotEmpty) entry.category,
                    _dayLabel(entry.bookingDate),
                    if (entry.recurrenceId.isNotEmpty) 'Serie',
                  ].join(' · '),
                  icon: _entryIcon(context, entry),
                  amount: AmountText(
                    entry.amount,
                    income: entry.isIncome,
                    neutral:
                        entry.sourceType == 'transfer' ||
                        entry.sourceType == 'saving',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetsCard extends StatelessWidget {
  const _BudgetsCard({
    required this.progress,
    required this.review,
    required this.onShowAll,
  });

  final List<BudgetProgress> progress;
  final ({DateTime month, List<BudgetProgress> progress})? review;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final review = this.review;
    final over = review?.progress
        .where((item) => item.state == BudgetState.over)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Budgets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: onShowAll, child: const Text('Alle')),
              ],
            ),
            if (review != null && review.progress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 6),
                child: Text(
                  'Rückblick ${monthNames[review.month.month - 1]}: '
                  '${review.progress.length - over!.length} von '
                  '${review.progress.length} eingehalten'
                  '${over.isEmpty ? '' : ', ${over.first.budget.category} '
                            '${money(-over.first.left)} drüber'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: over.isEmpty ? colors.income : colors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            for (final item in progress.take(4))
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BudgetBar(progress: item, dense: true, onTap: onShowAll),
              ),
            if (progress.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${progress.length - 4} weitere',
                  style: TextStyle(fontSize: 12, color: colors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Upcoming extends StatelessWidget {
  const _Upcoming({
    required this.entries,
    required this.standingOrders,
    required this.dividends,
  });

  final List<LedgerEntry> entries;

  /// Bookings standing orders will create; not stored as entries yet.
  final List<({StandingOrder order, DateTime date})> standingOrders;

  /// Projected payouts with a known payment date, after taxes.
  final List<ProjectedDividend> dividends;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final until = now.add(const Duration(days: 45));
    final items =
        <({DateTime date, String title, String subtitle, Widget amount})>[
          for (final entry in entries)
            if (entry.bookingDate.isAfter(now) &&
                entry.bookingDate.isBefore(until) &&
                !(entry.isIncome &&
                    (entry.sourceType == 'transfer' ||
                        entry.sourceType == 'saving')))
              (
                date: entry.bookingDate,
                title: entry.merchant.isEmpty
                    ? (entry.description.isEmpty
                          ? entry.category
                          : entry.description)
                    : entry.merchant,
                subtitle: [
                  if (entry.category.isNotEmpty) entry.category,
                  if (entry.recurrenceId.isNotEmpty) 'Serie',
                ].join(' · '),
                amount: AmountText(
                  entry.amount,
                  income: entry.isIncome,
                  neutral:
                      entry.sourceType == 'transfer' ||
                      entry.sourceType == 'saving',
                ),
              ),
          for (final (:order, :date) in standingOrders)
            (
              date: date,
              title: order.merchant.isNotEmpty
                  ? order.merchant
                  : order.description.isNotEmpty
                  ? order.description
                  : order.category,
              subtitle: [
                if (order.category.isNotEmpty &&
                    order.kind != 'transfer' &&
                    order.kind != 'saving')
                  order.category,
                'Dauerauftrag',
              ].join(' · '),
              amount: AmountText(
                order.amount,
                income: order.kind == 'income',
                neutral: order.kind == 'transfer' || order.kind == 'saving',
              ),
            ),
          for (final payment in dividends)
            if (payment.date.isAfter(now) && payment.date.isBefore(until))
              (
                date: payment.date,
                title: 'Dividende ${payment.investment.name}',
                subtitle: 'erwartet, nach Steuern',
                amount: AmountText(payment.tax.net, income: true),
              ),
        ]..sort((a, b) => a.date.compareTo(b.date));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Demnächst',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'In den nächsten Wochen ist nichts geplant.',
                  style: TextStyle(color: WealthColors.of(context).muted),
                ),
              ),
            for (final item in items.take(4))
              _EntryRow(
                title: item.title,
                subtitle: item.subtitle.isEmpty
                    ? _dayLabel(item.date)
                    : item.subtitle,
                amount: item.amount,
                icon: const SizedBox.shrink(),
                dateBadge: item.date,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown once to users who kept the dark scheme from before the redesign.
class _LightDesignHint extends StatelessWidget {
  const _LightDesignHint({required this.onTry, required this.onDismiss});

  final VoidCallback onTry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            IconTile(
              icon: Icons.light_mode_rounded,
              foreground: colors.income,
              background: colors.incomeSoft,
            ),
            Text(
              'Neues helles Design ausprobieren?',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            FilledButton(onPressed: onTry, child: const Text('Ausprobieren')),
            TextButton(onPressed: onDismiss, child: const Text('Nein, danke')),
          ],
        ),
      ),
    );
  }
}

/// Small segmented control for chart ranges (1M · 6M · 1J · Alles).
class _RangePicker extends StatelessWidget {
  const _RangePicker({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.ground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in values)
            Semantics(
              button: true,
              selected: item == value,
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => onChanged(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item == value
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: item == value
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .06),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: item == value ? colors.income : colors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
