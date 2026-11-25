import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/category_budget.dart';
import 'package:wealthflow_core/finance/free_to_spend.dart';
import 'package:wealthflow_core/finance/quick_entry.dart';

import '../../app/app_theme.dart';
import '../../app/design.dart';
import '../../core/providers.dart';
import '../../core/security/device_security.dart';
import '../../core/widgets/common_widgets.dart';
import 'quick_booking.dart';

/// Something due soon: standing order, dividend or future booking.
class CockpitDue {
  const CockpitDue({
    required this.date,
    required this.title,
    required this.amount,
    required this.income,
  });

  final DateTime date;
  final String title;
  final double amount;
  final bool income;
}

/// One month of the cashflow chart.
class CockpitMonth {
  const CockpitMonth(this.label, this.income, this.expenses);

  final String label;
  final double income;
  final double expenses;
}

/// Everything the cockpit shows, computed by the dashboard.
class CockpitData {
  const CockpitData({
    required this.free,
    required this.netWorth,
    required this.netWorthChange,
    required this.netWorthHistory,
    required this.income,
    required this.expenses,
    required this.cashflow,
    required this.due,
    required this.budgets,
    required this.recent,
    required this.review,
    required this.security,
  });

  final FreeToSpend free;
  final double netWorth;

  /// Change against the end of the previous month, if known.
  final double? netWorthChange;

  /// Net worth over the last months, oldest first, ending with today.
  final List<double> netWorthHistory;
  final double income;
  final double expenses;
  final List<CockpitMonth> cashflow;
  final List<CockpitDue> due;
  final List<BudgetProgress> budgets;
  final List<LedgerEntry> recent;

  /// Things that need a decision, e.g. "2 Dividenden bestätigen".
  final List<CockpitReview> review;
  final CockpitSecurity security;

  /// Share of income that was not spent this month; null without income.
  double? get savingsRate =>
      income <= 0 ? null : ((income - expenses) / income).clamp(-9.99, 1);
}

class CockpitReview {
  const CockpitReview(this.label, this.onOpen);

  final String label;
  final void Function(WidgetRef ref) onOpen;
}

class CockpitSecurity {
  const CockpitSecurity({
    required this.appLock,
    required this.lockAfter,
    required this.lastBackup,
    required this.backupFailed,
    required this.serverConnected,
  });

  final bool appLock;
  final Duration lockAfter;
  final DateTime? lastBackup;
  final bool backupFailed;
  final bool serverConnected;

  /// Everything fine: lock on and a backup from the last 7 days.
  bool get ok =>
      appLock &&
      !backupFailed &&
      lastBackup != null &&
      DateTime.now().difference(lastBackup!) < const Duration(days: 7);
}

/// The cockpit in the layout of the current design.
class Cockpit extends ConsumerWidget {
  const Cockpit({required this.data, super.key});

  final CockpitData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final design = DesignStyle.of(context).design;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return switch (design) {
          AppDesign.bento => _BentoCockpit(data: data, wide: wide),
          AppDesign.terminal => _TerminalCockpit(data: data, wide: wide),
          AppDesign.classic => _ClassicCockpit(data: data, wide: wide),
        };
      },
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _hidden(WidgetRef ref, String text) =>
    ref.watch(privacyModeProvider) ? '•••• €' : text;

String _percent(double ratio) =>
    '${(ratio * 100).round().toString().replaceAll('.', ',')} %';

String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.';

TextStyle _number(BuildContext context, double size, {Color? color}) {
  final style = DesignStyle.of(context);
  return TextStyle(
    fontFamily: style.numberFont,
    fontSize: style.design == AppDesign.terminal ? size * .92 : size,
    fontWeight: style.design == AppDesign.terminal
        ? FontWeight.w700
        : FontWeight.w800,
    letterSpacing: style.design == AppDesign.terminal ? -1 : -size / 40,
    height: 1.05,
    color: color,
    fontFeatures: AppTheme.tabular,
  );
}

/// Small caption above a tile's content: uppercase in Terminal.
class _Label extends StatelessWidget {
  const _Label(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = DesignStyle.of(context);
    final colors = WealthColors.of(context);
    final terminal = style.design == AppDesign.terminal;
    return Text(
      terminal ? text.toUpperCase() : text,
      style: TextStyle(
        fontFamily: terminal ? style.numberFont : null,
        fontSize: terminal ? 11 : 13,
        letterSpacing: terminal ? 1.2 : 0,
        fontWeight: FontWeight.w600,
        color: color ?? colors.muted,
      ),
    );
  }
}

/// Surface of one tile in the look of the design.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.child,
    this.onTap,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final style = DesignStyle.of(context);
    final colors = WealthColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(style.radiusCard);
    final border = style.outlinedCards && color == null
        ? Border.all(color: colors.border)
        : null;
    final background =
        color ??
        (style.design == AppDesign.terminal
            ? Colors.transparent
            : scheme.surface);
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(style.design == AppDesign.bento ? 20 : 18),
            decoration: BoxDecoration(borderRadius: radius, border: border),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Lays [children] out as a wrapping grid; each child spans `flex` of
/// [columns] columns and takes the full width below [columns] == 1.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<(int flex, Widget child)> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 14.0;
      final unit = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final (flex, child) in children)
            SizedBox(
              width: columns == 1
                  ? constraints.maxWidth
                  : unit * flex.clamp(1, columns) +
                        gap * (flex.clamp(1, columns) - 1),
              child: child,
            ),
        ],
      );
    },
  );
}

// ─── Tiles ──────────────────────────────────────────────────────────────────

/// "Frei bis Monatsende" – the number the cockpit is built around.
class _FreeTile extends ConsumerWidget {
  const _FreeTile({required this.data, this.large = true});

  final CockpitData data;
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = DesignStyle.of(context);
    final colors = WealthColors.of(context);
    final free = data.free;
    final terminal = style.design == AppDesign.terminal;
    final onHero = terminal ? colors.income : colors.onHero;
    final muted = terminal ? colors.muted : colors.onHero.withValues(alpha: .9);
    final negative = free.free < 0;
    return _Tile(
      color: terminal ? null : colors.hero,
      semanticLabel: 'Frei bis Monatsende',
      onTap: () => selectShellDestination(ref, ShellPage.household),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Label(
                  'Frei bis ${free.lastDay}. ${monthNames[free.month.month - 1]}',
                  color: muted,
                ),
              ),
              Text(
                free.daysLeft == 1
                    ? 'letzter Tag'
                    : 'noch ${free.daysLeft} Tage',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _hidden(ref, money(free.free)),
              style: _number(
                context,
                large ? 52 : 40,
                color: negative && terminal ? colors.expense : onHero,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            negative
                ? 'Mehr verplant als auf dem Konto'
                : '≈ ${_hidden(ref, money(free.perDay))} pro Tag',
            style: TextStyle(fontSize: 14, color: muted),
          ),
          const SizedBox(height: 4),
          Text(
            '${_hidden(ref, money(free.balance))} Konto − '
            '${_hidden(ref, money(free.planned))} geplant − '
            '${_hidden(ref, money(free.reserved))} Budgets',
            style: TextStyle(fontSize: 12, color: muted),
          ),
          const SizedBox(height: 14),
          _Progress(
            value: free.budgetUse ?? free.monthProgress,
            marker: free.monthProgress,
            color: terminal ? colors.income : colors.onHero,
            track: terminal
                ? colors.border
                : colors.onHero.withValues(alpha: .25),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  free.budgetUse == null
                      ? 'Keine Budgets angelegt'
                      : 'Budgets zu ${_percent(free.budgetUse!)} genutzt',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ),
              Text(
                'Monat zu ${_percent(free.monthProgress)} vorbei',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bar with an optional marker (where the month stands).
class _Progress extends StatelessWidget {
  const _Progress({
    required this.value,
    required this.color,
    required this.track,
    this.marker,
    this.height = 6,
  });

  final double value;
  final double? marker;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final terminal = DesignStyle.of(context).design == AppDesign.terminal;
    final radius = BorderRadius.circular(terminal ? 0 : height / 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: height + 4,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(color: track, borderRadius: radius),
              ),
              Container(
                height: height,
                width: width * value.clamp(0, 1),
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
              if (marker != null)
                Positioned(
                  left: (width * marker!.clamp(0, 1) - 1).clamp(0, width - 2),
                  child: Container(width: 2, height: height + 4, color: color),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NetWorthTile extends ConsumerWidget {
  const _NetWorthTile({required this.data, this.chartHeight = 120});

  final CockpitData data;
  final double chartHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final change = data.netWorthChange;
    return _Tile(
      semanticLabel: 'Nettovermögen',
      onTap: () => openFinance(ref, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Nettovermögen'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                _hidden(ref, money(data.netWorth)),
                style: _number(context, 34),
              ),
              if (change != null)
                Text(
                  '${change >= 0 ? '▲' : '▼'} '
                  '${_hidden(ref, money(change.abs()))} zum Vormonat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.amount(income: change >= 0),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: chartHeight,
            width: double.infinity,
            child: data.netWorthHistory.length < 2
                ? Center(
                    child: Text(
                      'Verlauf erscheint nach dem ersten Monat',
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                  )
                : CustomPaint(
                    painter: _LinePainter(
                      values: data.netWorthHistory,
                      color: colors.income,
                      fill:
                          DesignStyle.of(context).design != AppDesign.terminal,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color, this.fill = true});

  final List<double> values;
  final Color color;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final low = values.reduce((a, b) => a < b ? a : b);
    final high = values.reduce((a, b) => a > b ? a : b);
    final span = high - low == 0 ? 1 : high - low;
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * i / (values.length - 1),
          size.height - 4 - (values[i] - low) / span * (size.height - 8),
        ),
    ];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    if (fill) {
      final area = Path.from(line)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(area, Paint()..color = color.withValues(alpha: .14));
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = fill ? 2.5 : 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(points.last, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.color != color;
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.data});

  final CockpitData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final terminal = DesignStyle.of(context).design == AppDesign.terminal;
    final count = data.review.length;
    return _Tile(
      color: count == 0 || terminal ? null : colors.expenseSoft,
      semanticLabel: 'Zu prüfen: $count',
      onTap: count == 0 ? null : () => data.review.first.onOpen(ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Zu prüfen', color: count == 0 ? null : colors.expense),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: _number(
              context,
              36,
              color: count == 0 ? colors.muted : colors.expense,
            ),
          ),
          const SizedBox(height: 4),
          if (count == 0)
            Text('Alles erledigt', style: TextStyle(color: colors.muted))
          else
            for (final item in data.review.take(3))
              InkWell(
                onTap: () => item.onOpen(ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SavingsTile extends StatelessWidget {
  const _SavingsTile({required this.data});

  final CockpitData data;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final rate = data.savingsRate;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Sparquote'),
          const SizedBox(height: 6),
          Text(
            rate == null ? '–' : _percent(rate),
            style: _number(
              context,
              30,
              color: rate == null
                  ? colors.muted
                  : colors.amount(income: rate >= 0),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'diesen Monat',
            style: TextStyle(fontSize: 12, color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _CashflowTile extends ConsumerWidget {
  const _CashflowTile({required this.data});

  final CockpitData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final terminal = DesignStyle.of(context).design == AppDesign.terminal;
    final months = data.cashflow;
    final peak = months.fold<double>(
      1,
      (max, m) => [max, m.income, m.expenses].reduce((a, b) => a > b ? a : b),
    );
    Widget legend(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: colors.muted)),
      ],
    );
    return _Tile(
      onTap: () => selectShellDestination(ref, ShellPage.statistics),
      semanticLabel: 'Cashflow der letzten Monate',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _Label('Cashflow 6 Monate')),
              legend(colors.income, 'Ein'),
              const SizedBox(width: 10),
              legend(colors.expense, 'Aus'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ref.watch(privacyModeProvider)
                ? Center(
                    child: Text(
                      'Ausgeblendet',
                      style: TextStyle(color: colors.muted),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final month in months)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (final (value, color) in [
                                        (month.income, colors.income),
                                        (month.expenses, colors.expense),
                                      ])
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 1.5,
                                            ),
                                            child: FractionallySizedBox(
                                              heightFactor: (value / peak)
                                                  .clamp(.02, 1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        terminal ? 0 : 5,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  month.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DueTile extends ConsumerWidget {
  const _DueTile({required this.data, this.limit = 4});

  final CockpitData data;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    final items = data.due.take(limit).toList();
    return _Tile(
      onTap: () => openMore(ref, 'standingOrders'),
      semanticLabel: 'Als Nächstes fällig',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Als Nächstes'),
          const SizedBox(height: 6),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'In den nächsten 30 Tagen nichts fällig',
                style: TextStyle(color: colors.muted),
              ),
            ),
          for (final (index, item) in items.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: index == items.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      _shortDate(item.date),
                      style: TextStyle(
                        fontFamily: style.numberFont,
                        fontSize: 12,
                        color: colors.muted,
                        fontFeatures: AppTheme.tabular,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hidden(
                      ref,
                      '${item.income ? '+' : '−'} ${money(item.amount)}',
                    ),
                    style: TextStyle(
                      fontFamily: style.numberFont,
                      fontWeight: FontWeight.w700,
                      color: colors.amount(income: item.income),
                      fontFeatures: AppTheme.tabular,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetsTile extends ConsumerWidget {
  const _BudgetsTile({required this.data, this.limit = 4});

  final CockpitData data;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final budgets = [...data.budgets]
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    return _Tile(
      onTap: () => openMore(ref, 'budgets'),
      semanticLabel: 'Budgets',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Budgets'),
          const SizedBox(height: 8),
          if (budgets.isEmpty)
            Text(
              'Lege Budgets je Kategorie an, dann rechnet „Frei“ sie mit ein.',
              style: TextStyle(color: colors.muted, fontSize: 13),
            ),
          for (final progress in budgets.take(limit)) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.budget.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _hidden(
                    ref,
                    '${money(progress.spent)} / ${money(progress.available)}',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: progress.ratio > 1
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: progress.ratio > 1 ? colors.expense : colors.muted,
                    fontFeatures: AppTheme.tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _Progress(
              value: progress.ratio,
              color: progress.ratio > 1
                  ? colors.expense
                  : progress.ratio >= .8
                  ? colors.warning
                  : colors.income,
              track: colors.neutralSoft,
              height: 7,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SecurityTile extends ConsumerWidget {
  const _SecurityTile({required this.data});

  final CockpitData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final security = data.security;
    final ok = security.ok;
    final backup = security.lastBackup;
    String backupText() {
      if (security.backupFailed) return 'Letzte Sicherung fehlgeschlagen';
      if (backup == null) return 'Noch keine Sicherung';
      final local = backup.toLocal();
      final today = DateTime.now();
      final sameDay =
          local.year == today.year &&
          local.month == today.month &&
          local.day == today.day;
      final time =
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      return sameDay
          ? 'Gesichert heute $time'
          : 'Gesichert am ${_shortDate(local)}';
    }

    final lines = [
      security.appLock
          ? (security.lockAfter == Duration.zero
                ? 'Sperre sofort'
                : 'Sperre nach ${lockDelayChoices[security.lockAfter] ?? '${security.lockAfter.inSeconds} s'}')
          : 'App-Sperre aus',
      backupText(),
      security.serverConnected ? 'Server verbunden' : 'Nur auf diesem Gerät',
    ];
    return _Tile(
      onTap: () => openMore(ref, 'settings'),
      semanticLabel: ok ? 'Sicherheit: alles in Ordnung' : 'Sicherheit prüfen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _Label('Sicherheit')),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: ok ? colors.income : colors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                ok ? 'ok' : 'prüfen',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ok ? colors.income : colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(line, style: const TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _RecentTile extends ConsumerWidget {
  const _RecentTile({required this.data, this.limit = 5});

  final CockpitData data;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    final items = data.recent.take(limit).toList();
    return _Tile(
      onTap: () => selectShellDestination(ref, ShellPage.household),
      semanticLabel: 'Letzte Buchungen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('Letzte Buchungen'),
          const SizedBox(height: 6),
          if (items.isEmpty)
            Text('Noch keine Buchungen', style: TextStyle(color: colors.muted)),
          for (final entry in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      _shortDate(entry.bookingDate),
                      style: TextStyle(
                        fontFamily: style.numberFont,
                        fontSize: 12,
                        color: colors.muted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: entry.merchant.isNotEmpty
                            ? entry.merchant
                            : entry.category,
                        children: [
                          if (entry.merchant.isNotEmpty)
                            TextSpan(
                              text: ' · ${entry.category}',
                              style: TextStyle(color: colors.muted),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _hidden(
                      ref,
                      '${entry.isIncome ? '+' : '−'} ${money(entry.amount)}',
                    ),
                    style: TextStyle(
                      fontFamily: style.numberFont,
                      fontWeight: FontWeight.w700,
                      color: colors.amount(income: entry.isIncome),
                      fontFeatures: AppTheme.tabular,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One line that becomes a booking: "12,50 Bäcker bar".
class QuickEntryField extends ConsumerStatefulWidget {
  const QuickEntryField({super.key});

  @override
  ConsumerState<QuickEntryField> createState() => _QuickEntryFieldState();
}

class _QuickEntryFieldState extends ConsumerState<QuickEntryField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  QuickEntry? _parse() => parseQuickBooking(ref, _controller.text);

  Future<void> _submit() async {
    final parsed = _parse();
    final messenger = ScaffoldMessenger.of(context);
    if (parsed == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Bitte mit Betrag beginnen, z. B. „12,50 Bäcker bar“'),
        ),
      );
      return;
    }
    if (!await bookQuickEntry(ref, messenger, parsed)) return;
    _controller.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    final terminal = style.design == AppDesign.terminal;
    final preview = _controller.text.trim().isEmpty ? null : _parse();
    final radius = BorderRadius.circular(
      style.design == AppDesign.bento ? 28 : style.radiusControl,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
          style: terminal
              ? TextStyle(fontFamily: style.numberFont, fontSize: 15)
              : null,
          decoration: InputDecoration(
            hintText: 'Was ist passiert? z. B. „12,50 Bäcker bar“',
            prefixIcon: Icon(
              terminal ? Icons.chevron_right_rounded : Icons.add_rounded,
              color: colors.income,
            ),
            suffixIcon: IconButton(
              tooltip: 'Buchen',
              onPressed: _controller.text.trim().isEmpty ? null : _submit,
              icon: const Icon(Icons.keyboard_return_rounded),
            ),
            border: OutlineInputBorder(borderRadius: radius),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: terminal ? colors.income : colors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: colors.income, width: 2),
            ),
          ),
        ),
        if (preview != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Text(
              '→ ${money(preview.amount)} · ${preview.summary}'
              '${preview.categoryLearned ? ' (gelernt)' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: colors.income,
                fontFamily: terminal ? style.numberFont : null,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Layouts ────────────────────────────────────────────────────────────────

/// B2 Bento: tiles of different sizes, petrol hero.
class _BentoCockpit extends StatelessWidget {
  const _BentoCockpit({required this.data, required this.wide});

  final CockpitData data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return _Grid(
        columns: 2,
        children: [
          (2, _FreeTile(data: data, large: false)),
          (2, const QuickEntryField()),
          (1, _ReviewTile(data: data)),
          (1, _SavingsTile(data: data)),
          (2, _NetWorthTile(data: data, chartHeight: 70)),
          (2, _DueTile(data: data, limit: 3)),
          (2, _BudgetsTile(data: data, limit: 3)),
          (2, _SecurityTile(data: data)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _FreeTile(data: data)),
            const SizedBox(width: 14),
            Expanded(flex: 5, child: _NetWorthTile(data: data)),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewTile(data: data),
                  const SizedBox(height: 14),
                  _SavingsTile(data: data),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const QuickEntryField(),
        const SizedBox(height: 14),
        _Grid(
          columns: 12,
          children: [
            (5, _CashflowTile(data: data)),
            (4, _DueTile(data: data)),
            (3, _SecurityTile(data: data)),
            (6, _BudgetsTile(data: data)),
            (6, _RecentTile(data: data, limit: 4)),
          ],
        ),
      ],
    );
  }
}

/// B3 Terminal: status line, command line, figures in a row, columns.
class _TerminalCockpit extends ConsumerWidget {
  const _TerminalCockpit({required this.data, required this.wide});

  final CockpitData data;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    final security = data.security;
    final mono = TextStyle(
      fontFamily: style.numberFont,
      fontSize: 12,
      color: colors.muted,
    );
    final status = Wrap(
      spacing: 18,
      runSpacing: 4,
      children: [
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  width: 8,
                  height: 8,
                  color: security.ok ? colors.income : colors.warning,
                ),
              ),
              TextSpan(text: security.ok ? '  sicher' : '  prüfen'),
            ],
          ),
          style: mono,
        ),
        Text(
          security.appLock
              ? 'sperre ${security.lockAfter.inSeconds}s'
              : 'sperre aus',
          style: mono,
        ),
        Text(
          security.lastBackup == null
              ? 'sicherung –'
              : 'sicherung ${_shortDate(security.lastBackup!.toLocal())}',
          style: mono,
        ),
        Text(security.serverConnected ? 'server ok' : 'lokal', style: mono),
      ],
    );
    final figures = _Grid(
      columns: wide ? 12 : 2,
      children: [
        (wide ? 5 : 2, _FreeTile(data: data, large: wide)),
        (wide ? 3 : 1, _NetWorthTile(data: data, chartHeight: 46)),
        (wide ? 2 : 1, _SavingsTile(data: data)),
        (wide ? 2 : 2, _ReviewTile(data: data)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        status,
        const SizedBox(height: 12),
        const QuickEntryField(),
        const SizedBox(height: 14),
        figures,
        const SizedBox(height: 14),
        _Grid(
          columns: wide ? 3 : 1,
          children: [
            (1, _RecentTile(data: data, limit: 6)),
            (
              1,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DueTile(data: data),
                  const SizedBox(height: 14),
                  _BudgetsTile(data: data),
                ],
              ),
            ),
            (1, _CashflowTile(data: data)),
          ],
        ),
      ],
    );
  }
}

/// B4 Hell & Dunkel: the big free amount, quick entry and what needs a look.
/// The familiar overview cards follow below on the dashboard.
class _ClassicCockpit extends StatelessWidget {
  const _ClassicCockpit({required this.data, required this.wide});

  final CockpitData data;
  final bool wide;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _FreeTile(data: data)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _ReviewTile(data: data)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _SecurityTile(data: data)),
          ],
        )
      else ...[
        _FreeTile(data: data, large: false),
        const SizedBox(height: 12),
        _Grid(
          columns: 2,
          children: [
            (1, _ReviewTile(data: data)),
            (1, _SecurityTile(data: data)),
          ],
        ),
      ],
      const SizedBox(height: 14),
      const QuickEntryField(),
    ],
  );
}
