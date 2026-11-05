import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';

/// Standard currency of the signed-in user, used when [money] gets none.
String moneyCurrency = 'EUR';

String money(num value, {String? currency}) => NumberFormat.simpleCurrency(
  locale: 'de_DE',
  name: currency ?? moneyCurrency,
).format(value);

/// A quantity with every decimal that matters (fractions of savings-plan
/// shares included), without trailing zeros: 0,1234 · 12 · 1.000,5.
String quantityText(num value) =>
    NumberFormat('#,##0.########', 'de_DE').format(value);

const _weekdays = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

/// The WealthFlow mark: a rising line on a petrol tile. The app icons in
/// android/, web/ and windows/ are drawn from the same points
/// (tool/generate_icons.py).
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 36, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'WealthFlow',
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(tile: scheme.primary, line: scheme.onPrimary),
      ),
    );
  }
}

/// Shared with tool/generate_icons.py; change both together.
const logoLinePoints = [
  Offset(.22, .66),
  Offset(.40, .46),
  Offset(.54, .58),
  Offset(.78, .32),
];

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.tile, required this.line});

  final Color tile;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(side * .28)),
      Paint()..color = tile,
    );
    final path = Path()
      ..moveTo(logoLinePoints.first.dx * side, logoLinePoints.first.dy * side);
    for (final point in logoLinePoints.skip(1)) {
      path.lineTo(point.dx * side, point.dy * side);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * .085
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.tile != tile || old.line != line;
}

/// German month names, independent of loaded locale data.
const monthNames = [
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
const shortMonthNames = [
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

/// "November 2026".
String monthLabel(DateTime date) =>
    '${monthNames[date.month - 1]} ${date.year}';

/// German day names without depending on loaded locale data.
String weekdayName(DateTime date) => _weekdays[date.weekday - 1];
String shortMonthName(DateTime date) => shortMonthNames[date.month - 1];

/// "5. Nov."; May has no abbreviation dot.
String shortDate(DateTime date) =>
    '${date.day}. ${shortMonthName(date)}${date.month == 5 ? '' : '.'}';

/// A form-compatible dropdown whose options are filtered while the user types.
///
/// This deliberately mirrors the small subset of [DropdownButtonFormField]
/// used throughout WealthFlow, so every selector behaves consistently with a
/// keyboard, mouse, or software keyboard.
class SearchableDropdownButtonFormField<T> extends StatelessWidget {
  const SearchableDropdownButtonFormField({
    required this.items,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.decoration = const InputDecoration(),
    this.isExpanded = false,
    this.isDense = true,
    this.menuMaxHeight,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final List<DropdownMenuItem<T>>? items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final InputDecoration decoration;
  final bool isExpanded;
  final bool isDense;
  final double? menuMaxHeight;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final options = items ?? <DropdownMenuItem<T>>[];
    final enabled = onChanged != null && options.isNotEmpty;
    return FormField<T>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      // AlertDialog measures intrinsic widths before laying out its content.
      // Let DropdownMenu handle expansion itself: a LayoutBuilder here breaks
      // that measurement and leaves the dialog without a hit-testable size.
      builder: (state) => DropdownMenu<T>(
        enabled: enabled,
        menuHeight: menuMaxHeight,
        initialSelection: state.value,
        focusNode: focusNode,
        requestFocusOnTap: true,
        enableFilter: true,
        enableSearch: true,
        expandedInsets: isExpanded ? EdgeInsets.zero : null,
        dropdownMenuEntries: [
          for (final item in options)
            DropdownMenuEntry<T>(
              value: item.value as T,
              label: _dropdownSearchLabel(item),
              labelWidget: item.child,
              enabled: item.enabled,
            ),
        ],
        filterCallback: (entries, query) {
          final normalized = query.trim().toLowerCase();
          if (normalized.isEmpty) return entries;
          final startsWith = <DropdownMenuEntry<T>>[];
          final contains = <DropdownMenuEntry<T>>[];
          for (final entry in entries) {
            final label = entry.label.toLowerCase();
            if (label.startsWith(normalized)) {
              startsWith.add(entry);
            } else if (label.contains(normalized)) {
              contains.add(entry);
            }
          }
          return [...startsWith, ...contains];
        },
        decorationBuilder: (context, menuController) => decoration.copyWith(
          isDense: isDense,
          errorText: state.errorText,
          suffixIcon: IconButton(
            tooltip: menuController.isOpen
                ? 'Auswahl schließen'
                : 'Auswahl öffnen oder Suchtext eingeben',
            onPressed: enabled
                ? () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  }
                : null,
            icon: Icon(
              menuController.isOpen
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
            ),
          ),
        ),
        onSelected: enabled
            ? (value) {
                if (value == null) return;
                state.didChange(value);
                onChanged?.call(value);
              }
            : null,
      ),
    );
  }
}

String _dropdownSearchLabel<T>(DropdownMenuItem<T> item) {
  final child = item.child;
  if (child is Text && child.data?.trim().isNotEmpty == true) {
    return child.data!.trim();
  }
  return item.value?.toString() ?? '';
}

/// User-facing message for data that failed to load. The technical [error]
/// only goes to the debug log.
class LoadErrorMessage extends StatelessWidget {
  LoadErrorMessage(this.message, {required Object error, super.key}) {
    debugPrint('$message: $error');
  }

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        '$message. Bitte die App neu starten.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// Page title with an optional action on the right (or below on phones).
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.action,
    this.actionBelow = false,
    this.actionInline = false,
    this.titleSingleLine = false,
    super.key,
  });

  final String title;
  final Widget? action;
  final bool actionBelow;

  /// Keeps [action] beside the title on phones, e.g. a row of icon buttons.
  final bool actionInline;
  final bool titleSingleLine;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: compact ? 24 : 28,
    );
    final text = titleSingleLine
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title, maxLines: 1, softWrap: false, style: style),
          )
        : Text(title, style: style);
    return Padding(
      padding: EdgeInsets.fromLTRB(4, compact ? 4 : 8, 4, compact ? 16 : 20),
      // Icon actions stay beside the title, wider ones move below on phones.
      child:
          (compact &&
                  !actionInline &&
                  action is! PopupMenuButton &&
                  action is! IconButton) ||
              actionBelow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                if (action != null) ...[const SizedBox(height: 12), action!],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: text),
                if (action != null) ...[const SizedBox(width: 12), action!],
              ],
            ),
    );
  }
}

/// Section heading inside a page, with an optional link-style action.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ?action,
      ],
    ),
  );
}

/// Small uppercase label above a key figure.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: .6,
      color: color ?? WealthColors.of(context).muted,
    ),
  );
}

/// Rounded square with an icon or a short text, used to mark list rows.
class IconTile extends StatelessWidget {
  const IconTile({
    this.icon,
    this.label,
    this.background,
    this.foreground,
    this.size = 40,
    super.key,
  });

  final IconData? icon;
  final String? label;
  final Color? background;
  final Color? foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final fg = foreground ?? colors.income;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? colors.incomeSoft,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: label != null
          ? Text(
              label!,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            )
          : Icon(icon, size: size * .5, color: fg),
    );
  }
}

/// Signed money text: income with "+", expenses with "−", transfers without a
/// sign. The sign carries the meaning, the color only supports it.
String signedMoney(
  num value, {
  required bool income,
  bool neutral = false,
  String? currency,
}) {
  final text = money(value.abs(), currency: currency);
  if (neutral) return text;
  return '${income ? '+' : '−'} $text';
}

class AmountText extends StatelessWidget {
  const AmountText(
    this.value, {
    required this.income,
    this.neutral = false,
    this.currency,
    this.style,
    super.key,
  });

  /// Expenses and gains or losses whose sign is the value's own sign.
  AmountText.change(num value, {String? currency, TextStyle? style, Key? key})
    : this(
        value.abs(),
        income: value >= 0,
        currency: currency,
        style: style,
        key: key,
      );

  final num value;
  final bool income;
  final bool neutral;
  final String? currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Text(
      signedMoney(value, income: income, neutral: neutral, currency: currency),
      maxLines: 1,
      style: (style ?? const TextStyle(fontWeight: FontWeight.w700)).copyWith(
        color: neutral
            ? Theme.of(context).colorScheme.onSurface
            : colors.amount(income: income),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: WealthColors.of(context).incomeSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icon,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(message, textAlign: TextAlign.center),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        );
        if (!constraints.hasBoundedHeight) {
          return Center(
            child: Padding(padding: const EdgeInsets.all(36), child: content),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 48).clamp(0, double.infinity),
            ),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.caption,
    this.captionColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;

  /// Accent of the icon; defaults to the theme's primary color.
  final Color? color;
  final String? caption;
  final Color? captionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Eyebrow(title)),
                  IconTile(
                    icon: icon,
                    size: 32,
                    foreground: accent,
                    background: accent.withValues(alpha: .12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: captionColor,
                    fontWeight: captionColor == null ? null : FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen'),
            ),
          ],
        ),
      ) ??
      false;
}
