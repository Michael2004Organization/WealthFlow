part of '../investments_page.dart';

class _TaxAllowanceTile extends ConsumerWidget {
  const _TaxAllowanceTile({
    required this.preference,
    required this.summary,
    required this.events,
  });

  final UserPreference? preference;
  final PortfolioTaxSummary summary;
  final List<PortfolioTaxEvent> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maximum =
        ref.watch(appConfigurationProvider).valueOrNull?.maximumTaxAllowance ??
        1000;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _showTaxAllowanceInfo(context, summary, events),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Freistellung ${money(summary.allowanceRemaining)} frei',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline_rounded, size: 16),
            if (preference != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Betrag bearbeiten',
                onPressed: () =>
                    _editTaxAllowance(context, ref, preference!, maximum),
                icon: const Icon(Icons.edit_outlined, size: 17),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showTaxAllowanceInfo(
  BuildContext context,
  PortfolioTaxSummary summary,
  List<PortfolioTaxEvent> events,
) async {
  var filter = 'Alle';
  final year = DateTime.now().year;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final visible = events.where((event) {
          if (filter == 'Ländersteuer') return event.domesticTax > 0;
          if (filter == 'Quellensteuer') return event.withholdingTax > 0;
          return true;
        }).toList();
        return AlertDialog(
          title: Text('Freistellungsauftrag $year'),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 64).clamp(300, 640),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _TaxInfoValue(
                        label: 'Verwendet',
                        value: money(summary.allowanceUsed),
                      ),
                      _TaxInfoValue(
                        label: 'Frei',
                        value: money(summary.allowanceRemaining),
                      ),
                      _TaxInfoValue(
                        label: 'Steuern',
                        value: money(summary.taxPaid),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: summary.allowance <= 0
                        ? 1
                        : (summary.allowanceUsed / summary.allowance).clamp(
                            0,
                            1,
                          ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Steuerereignisse aus Verkäufen und Dividenden',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Alle', label: Text('Alle')),
                      ButtonSegment(
                        value: 'Ländersteuer',
                        label: Text('Ländersteuer'),
                      ),
                      ButtonSegment(
                        value: 'Quellensteuer',
                        label: Text('Quellensteuer'),
                      ),
                    ],
                    selected: {filter},
                    onSelectionChanged: (value) =>
                        setDialogState(() => filter = value.first),
                  ),
                  const SizedBox(height: 8),
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Für diesen Filter sind keine Steuerereignisse vorhanden.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    for (final event in visible)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          event.kind == 'dividend'
                              ? Icons.payments_outlined
                              : Icons.sell_outlined,
                        ),
                        title: Text(
                          '${event.title} · ${event.kind == 'dividend' ? 'Dividende' : 'Verkauf'}',
                        ),
                        subtitle: Text(
                          '${DateFormat('dd.MM.yyyy').format(event.date)} · '
                          'Quellensteuer ${money(event.withholdingTax)} · '
                          'Ländersteuer ${money(event.domesticTax)} · '
                          'Freistellung ${money(event.allowanceUsed)}',
                        ),
                        trailing: Icon(
                          event.taxPaid > 0
                              ? Icons.receipt_long_outlined
                              : Icons.check_circle_outline_rounded,
                          color: event.taxPaid > 0
                              ? WealthColors.of(context).expense
                              : WealthColors.of(context).income,
                        ),
                      ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    ),
  );
}

class _TaxInfoValue extends StatelessWidget {
  const _TaxInfoValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

Future<void> _editTaxAllowance(
  BuildContext context,
  WidgetRef ref,
  UserPreference preference,
  double maximum,
) async {
  final controller = TextEditingController(
    text: preference.taxAllowance.toStringAsFixed(2),
  );
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Freistellungsauftrag'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Jährlicher Betrag',
            suffixText: '€',
            helperText: 'Administrativer Höchstbetrag: ${money(maximum)}',
          ),
          validator: (value) {
            final parsed = parseAmount(value);
            if (parsed == null || parsed < 0) return 'Ungültiger Betrag';
            if (parsed > maximum) return 'Höchstbetrag überschritten';
            return null;
          },
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
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      await ref
          .read(databaseProvider)
          .savePreferences(
            preference
                .toCompanion(false)
                .copyWith(
                  taxAllowance: Value(parseAmount(controller.text)!),
                  updatedAt: Value(DateTime.now().toUtc()),
                ),
          );
    }, source: 'Freistellungsauftrag speichern');
  }
  controller.dispose();
}

Future<void> _editDefaultInvestmentFee(
  BuildContext context,
  WidgetRef ref,
  UserPreference preference,
) async {
  final controller = TextEditingController(
    text: preference.defaultInvestmentFee.toStringAsFixed(2),
  );
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Standardgebühr'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Gebühr für neue Aktienkäufe',
            suffixText: '€',
            helperText: 'Beim einzelnen Kauf weiterhin frei änderbar.',
          ),
          validator: _positiveNumberValidator,
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
  );
  if (saved == true && context.mounted) {
    await saveWithFeedback(context, () async {
      await ref
          .read(databaseProvider)
          .savePreferences(
            preference
                .toCompanion(false)
                .copyWith(
                  defaultInvestmentFee: Value(_parseNumber(controller.text)!),
                  updatedAt: Value(DateTime.now().toUtc()),
                ),
          );
    }, source: 'Standardgebühr speichern');
  }
  controller.dispose();
}
