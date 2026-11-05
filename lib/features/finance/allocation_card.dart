import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/allocation.dart';
import 'package:wealthflow_core/finance/amount_input.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

enum _Split { classes, countries, currencies }

/// Wealth split by asset class, country or currency as one bar, with
/// targets and how much to buy to reach them.
class AllocationCard extends ConsumerStatefulWidget {
  const AllocationCard({this.includeAccounts = true, super.key});

  /// The depot page leaves household accounts out.
  final bool includeAccounts;

  @override
  ConsumerState<AllocationCard> createState() => _AllocationCardState();
}

class _AllocationCardState extends ConsumerState<AllocationCard> {
  _Split _split = _Split.classes;

  Map<String, double> _values() {
    final converter = ref.watch(currencyConverterProvider);
    final base = ref.watch(preferencesProvider).valueOrNull?.currency ?? 'EUR';
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final investments =
        ref.watch(investmentsProvider).valueOrNull ?? const <Investment>[];
    final physical =
        ref.watch(physicalAssetsProvider).valueOrNull ??
        const <PhysicalAsset>[];
    final values = <String, double>{};
    void add(String label, double value) =>
        values.update(label, (sum) => sum + value, ifAbsent: () => value);
    for (final account in accounts) {
      if (!widget.includeAccounts && account.usageType != 'portfolio') {
        continue;
      }
      final value = converter.toBase(account.balance, account.currency);
      add(switch (_split) {
        _Split.classes => 'Konten',
        _Split.countries => 'Konten',
        _Split.currencies => account.currency.toUpperCase(),
      }, value);
    }
    for (final item in investments) {
      add(switch (_split) {
        _Split.classes => item.assetType.isEmpty ? 'Sonstiges' : item.assetType,
        _Split.countries => item.country.isEmpty ? 'Ohne Land' : item.country,
        _Split.currencies => item.instrumentCurrency.toUpperCase(),
      }, converter.investmentValue(item));
    }
    for (final item in physical) {
      add(switch (_split) {
        _Split.classes => item.category.isEmpty ? 'Sachwerte' : item.category,
        _Split.countries => 'Sachwerte',
        _Split.currencies => base.toUpperCase(),
      }, item.currentValue);
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final targetRows =
        (ref.watch(masterDataProvider).valueOrNull ?? const <MasterDataData>[])
            .where((row) => row.kind == allocationTargetKind)
            .toList();
    final targets = _split == _Split.classes
        ? parseAllocationTargets(targetRows.map((row) => row.value))
        : const <String, double>{};
    final slices = buildAllocation(_values(), targets: targets);
    if (slices.every((slice) => slice.value <= 0)) {
      return const SizedBox.shrink();
    }
    final palette = [
      Theme.of(context).colorScheme.primary,
      colors.income,
      colors.warning,
      colors.neutral,
      colors.expense,
      Theme.of(context).colorScheme.tertiary,
      colors.muted,
    ];
    Color colorOf(int index) => palette[index % palette.length];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  'Vermögensaufteilung',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SegmentedButton<_Split>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: _Split.classes,
                      label: Text('Klassen'),
                    ),
                    ButtonSegment(
                      value: _Split.countries,
                      label: Text('Länder'),
                    ),
                    ButtonSegment(
                      value: _Split.currencies,
                      label: Text('Währungen'),
                    ),
                  ],
                  selected: {_split},
                  onSelectionChanged: (value) =>
                      setState(() => _split = value.first),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (final (index, slice) in slices.indexed)
                      if (slice.share > 0)
                        Expanded(
                          flex: (slice.share * 1000).round().clamp(1, 1000),
                          child: Container(color: colorOf(index)),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (final (index, slice) in slices.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorOf(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slice.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (slice.target != null)
                            Text(
                              'Ziel ${_percent(slice.target!)}'
                              '${slice.toBuy > 0 ? ' · ${money(slice.toBuy)} nachkaufen' : ' · erreicht'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: slice.toBuy > 0
                                    ? colors.warning
                                    : colors.income,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      _percent(slice.share),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      width: 104,
                      child: Text(
                        money(slice.value),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, color: colors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            if (_split == _Split.classes)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _editTargets(slices),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(
                    targets.isEmpty ? 'Ziele festlegen' : 'Ziele ändern',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTargets(List<AllocationSlice> slices) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final controllers = {
      for (final slice in slices)
        slice.label: TextEditingController(
          text: slice.target == null
              ? ''
              : formatAmountInput(slice.target! * 100).replaceAll(',00', ''),
        ),
    };
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final sum = controllers.values.fold<double>(
            0,
            (total, controller) => total + (parseAmount(controller.text) ?? 0),
          );
          return AlertDialog(
            title: const Text('Ziele der Aufteilung'),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final MapEntry(key: label, value: controller)
                        in controllers.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: label,
                            suffixText: '%',
                          ),
                        ),
                      ),
                    Text(
                      'Summe ${formatAmountInput(sum).replaceAll(',00', '')} %'
                      '${(sum - 100).abs() < .01 || sum == 0 ? '' : ' (sollte 100 % sein)'}',
                      style: TextStyle(
                        color: (sum - 100).abs() < .01 || sum == 0
                            ? WealthColors.of(context).muted
                            : WealthColors.of(context).warning,
                      ),
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
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
    final values = {
      for (final MapEntry(key: label, value: controller) in controllers.entries)
        if ((parseAmount(controller.text) ?? 0) > 0)
          label: parseAmount(controller.text)!,
    };
    for (final controller in controllers.values) {
      controller.dispose();
    }
    if (saved != true || !mounted) return;
    await saveWithFeedback(
      context,
      () => ref
          .read(databaseProvider)
          .replaceMasterData(userId, allocationTargetKind, {
            for (final MapEntry(key: label, value: percent) in values.entries)
              '$label=$percent',
          }),
      source: 'Ziele der Aufteilung',
    );
  }
}

String _percent(double share) =>
    '${(share * 100).toStringAsFixed(share < .1 ? 1 : 0).replaceAll('.', ',')} %';
