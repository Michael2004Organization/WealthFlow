import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String money(num value, {String currency = 'EUR'}) =>
    NumberFormat.simpleCurrency(locale: 'de_DE', name: currency).format(value);

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
      builder: (state) => LayoutBuilder(
        builder: (context, constraints) {
          final width = isExpanded && constraints.hasBoundedWidth
              ? constraints.maxWidth
              : null;
          return DropdownMenu<T>(
            enabled: enabled,
            width: width,
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
          );
        },
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

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    required this.subtitle,
    this.action,
    this.actionBelow = false,
    this.titleSingleLine = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? action;
  final bool actionBelow;
  final bool titleSingleLine;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleSingleLine)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          )
        else
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
      child: compact || actionBelow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                if (action != null) ...[const SizedBox(height: 14), action!],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: text),
                if (action != null) ...[const SizedBox(width: 12), action!],
              ],
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36),
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
    required this.color,
    this.caption,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.arrow_outward_rounded, size: 19),
                ],
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 5),
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
                const SizedBox(height: 7),
                Text(caption!, style: Theme.of(context).textTheme.bodySmall),
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
