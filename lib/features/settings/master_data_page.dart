import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/currencies.dart';
import 'package:wealthflow_core/finance/currency_conversion.dart';
import 'package:wealthflow_core/finance/exchange_rate_defaults.dart';
import 'package:wealthflow_core/finance/withholding_tax_defaults.dart';

import '../../app/app_theme.dart';
import '../../app/design.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

/// How often each master data value is used, refreshed whenever bookings,
/// standing orders, budgets, positions or the master data change.
final masterDataUsageProvider =
    FutureProvider.autoDispose<Map<String, Map<String, MasterDataUsage>>>((
      ref,
    ) async {
      ref.watch(masterDataProvider);
      ref.watch(ledgerEntriesProvider);
      ref.watch(standingOrdersProvider);
      ref.watch(categoryBudgetsProvider);
      ref.watch(investmentsProvider);
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return const {};
      return ref.watch(databaseProvider).masterDataUsage(userId);
    });

class _Kind {
  const _Kind(this.key, this.label, this.singular, this.icon, this.hint);

  final String key;
  final String label;
  final String singular;
  final IconData icon;
  final String hint;
}

const _assetClassesKey = 'assetClasses';

class MasterDataPage extends ConsumerStatefulWidget {
  const MasterDataPage({super.key});

  static const _kinds = [
    _Kind(
      'category',
      'Kategorien',
      'Kategorie',
      Icons.label_outline_rounded,
      'Für Buchungen, Daueraufträge und Budgets',
    ),
    _Kind(
      'merchant',
      'Händler & Quellen',
      'Händler',
      Icons.storefront_outlined,
      'Vorschläge beim Buchen, z. B. Rewe oder Arbeitgeber',
    ),
    _Kind(
      'paymentMethod',
      'Zahlungsarten',
      'Zahlungsart',
      Icons.credit_card_outlined,
      'z. B. Bargeld, Girokarte, Kreditkarte',
    ),
    _Kind(
      'broker',
      'Broker',
      'Broker',
      Icons.account_balance_outlined,
      'Für Depot-Positionen',
    ),
    _Kind(
      'country',
      'Länder',
      'Land',
      Icons.public_rounded,
      'Für Depot-Positionen und die Quellensteuer',
    ),
    _Kind(
      'sector',
      'Branchen',
      'Branche',
      Icons.factory_outlined,
      'Für Depot-Positionen und die Aufteilung',
    ),
    _Kind(
      _assetClassesKey,
      'Anlageklassen',
      'Anlageklasse',
      Icons.category_outlined,
      'Fest vorgegeben für alle Depots',
    ),
  ];

  @override
  ConsumerState<MasterDataPage> createState() => _MasterDataPageState();
}

enum _Sort { name, usage }

class _MasterDataPageState extends ConsumerState<MasterDataPage> {
  var _kind = MasterDataPage._kinds.first;
  var _sort = _Sort.name;
  var _query = '';
  String? _addError;
  final _addController = TextEditingController();
  final _addFocus = FocusNode();

  @override
  void dispose() {
    _addController.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final data = ref.watch(masterDataProvider);
    final usage = ref.watch(masterDataUsageProvider).valueOrNull ?? const {};
    final assetClasses =
        ref.watch(assetClassesProvider).valueOrNull ??
        const <AssetClassesData>[];
    return Padding(
      padding: EdgeInsets.all(width < 600 ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'Stammdaten'),
              Expanded(
                child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => LoadErrorMessage(
                    'Stammdaten konnten nicht geladen werden',
                    error: error,
                  ),
                  data: (items) {
                    int countOf(_Kind kind) => kind.key == _assetClassesKey
                        ? assetClasses.length
                        : items.where((i) => i.kind == kind.key).length;
                    final detail = _kind.key == _assetClassesKey
                        ? _AssetClassList(assetClasses: assetClasses)
                        : _detail(context, items, usage[_kind.key] ?? {});
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 760) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _KindChips(
                                selected: _kind,
                                countOf: countOf,
                                onSelected: _select,
                              ),
                              const SizedBox(height: 12),
                              Expanded(child: detail),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 250,
                              child: _KindList(
                                selected: _kind,
                                countOf: countOf,
                                onSelected: _select,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: detail),
                          ],
                        );
                      },
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

  void _select(_Kind kind) => setState(() {
    _kind = kind;
    _query = '';
    _addError = null;
    _addController.clear();
  });

  Widget _detail(
    BuildContext context,
    List<MasterDataData> items,
    Map<String, MasterDataUsage> usage,
  ) {
    final colors = WealthColors.of(context);
    final text = Theme.of(context).textTheme;
    final entries = items.where((item) => item.kind == _kind.key).toList();
    final known = {for (final item in entries) item.value.toLowerCase()};
    final query = _query.trim().toLowerCase();
    MasterDataUsage usageOf(String value) =>
        usage[value] ?? const MasterDataUsage();

    final visible =
        entries
            .where((item) => item.value.toLowerCase().contains(query))
            .toList()
          ..sort((a, b) {
            final byName = a.value.toLowerCase().compareTo(
              b.value.toLowerCase(),
            );
            if (_sort == _Sort.name) return byName;
            // Most used first, A–Z among equally used entries.
            final byUse = usageOf(
              b.value,
            ).total.compareTo(usageOf(a.value).total);
            return byUse != 0 ? byUse : byName;
          });
    final isCountry = _kind.key == 'country';
    final isAdmin = ref.watch(isAdminProvider);
    final rates =
        ref.watch(countryTaxRatesProvider).valueOrNull ??
        const <CountryTaxRate>[];
    CountryTaxRate? storedRate(String country) => rates
        .where((r) => normalizeCountry(r.country) == normalizeCountry(country))
        .firstOrNull;
    final suggestions = [
      for (final value in _suggestions(_kind.key))
        if (!known.contains(value.toLowerCase())) value,
    ];
    final missingDefaults = isCountry
        ? entries
              .where(
                (e) =>
                    storedRate(e.value) == null &&
                    withholdingTaxDefaultFor(e.value) != null,
              )
              .toList()
        : const <MasterDataData>[];
    final unknown =
        usage.entries
            .where(
              (e) =>
                  !known.contains(e.key.toLowerCase()) &&
                  e.key.toLowerCase().contains(query),
            )
            .toList()
          ..sort((a, b) => b.value.total.compareTo(a.value.total));
    final unused = entries.where((i) => usageOf(i.value).total == 0).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                IconTile(icon: _kind.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_kind.label, style: text.titleLarge),
                      Text(
                        '${_kind.hint} · ${entries.length} Einträge'
                        '${unused > 0 ? ', $unused unbenutzt' : ''}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    focusNode: _addFocus,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    onChanged: (_) {
                      if (_addError != null) setState(() => _addError = null);
                    },
                    decoration: InputDecoration(
                      labelText: '${_kind.singular} hinzufügen',
                      hintText: suggestions.isEmpty
                          ? null
                          : 'z. B. ${suggestions.first}',
                      prefixIcon: const Icon(Icons.add_rounded),
                      errorText: _addError,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(onPressed: _add, child: const Text('Hinzufügen')),
              ],
            ),
          ),
          if (suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 9),
                      child: Text('Vorschläge:', style: text.bodySmall),
                    ),
                    for (final value in suggestions)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.add_rounded, size: 16),
                          label: Text(value),
                          tooltip: '$value hinzufügen',
                          onPressed: () => _adopt([value]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (isCountry && isAdmin && missingDefaults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Material(
                color: colors.incomeSoft,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                  child: Row(
                    children: [
                      Icon(Icons.auto_fix_high_rounded, color: colors.income),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${missingDefaults.length} Länder ohne eigenen '
                          'Steuersatz. Standardwerte des BZSt übernehmen?',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _applyTaxDefaults(missingDefaults),
                        child: const Text('Übernehmen'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Suchen',
                      prefixIcon: Icon(Icons.search_rounded, size: 20),
                    ),
                  ),
                ),
                SegmentedButton<_Sort>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _Sort.name, label: Text('A–Z')),
                    ButtonSegment(
                      value: _Sort.usage,
                      label: Text('Meist genutzt'),
                    ),
                  ],
                  selected: {_sort},
                  onSelectionChanged: (value) =>
                      setState(() => _sort = value.first),
                ),
              ],
            ),
          ),
          Divider(color: colors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      query.isEmpty
                          ? 'Noch keine Einträge. Lege oben den ersten an.'
                          : 'Nichts gefunden für „$_query“.',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: colors.muted),
                    ),
                  ),
                for (final item in visible)
                  _EntryTile(
                    item: item,
                    usage: usageOf(item.value),
                    tax: isCountry
                        ? _CountryTax.of(
                            item.value,
                            storedRate(item.value),
                            ref.watch(currencyConverterProvider),
                          )
                        : null,
                    onEditTax: isCountry && isAdmin
                        ? () => _editTax(
                            context,
                            item.value,
                            storedRate(item.value),
                          )
                        : null,
                    onRename: () =>
                        _rename(context, item, usageOf(item.value), entries),
                    onMerge: entries.length < 2
                        ? null
                        : () => _merge(
                            context,
                            item,
                            usageOf(item.value),
                            entries,
                          ),
                    onDelete: () => _delete(context, item, usageOf(item.value)),
                  ),
                if (unknown.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In deinen Daten gefunden',
                                style: text.titleSmall,
                              ),
                              Text(
                                'Wird verwendet, fehlt aber in der Auswahl.',
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _adopt([for (final e in unknown) e.key]),
                          child: const Text('Alle übernehmen'),
                        ),
                      ],
                    ),
                  ),
                  for (final entry in unknown)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      leading: Icon(
                        Icons.help_outline_rounded,
                        color: colors.warning,
                      ),
                      title: Text(entry.key),
                      subtitle: Text(_usageText(entry.value)),
                      trailing: OutlinedButton(
                        onPressed: () => _adopt([entry.key]),
                        child: const Text('Übernehmen'),
                      ),
                    ),
                ],
                if (isCountry)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      'Quellensteuer auf Dividenden für Privatanleger mit '
                      'Wohnsitz in Deutschland. „Anrechenbar“ ist der Teil, '
                      'den deine Bank auf die Abgeltungsteuer anrechnet; den '
                      'Rest kannst du nur im Ausland zurückfordern. '
                      'Standardwerte: $withholdingTaxSource. Kurse ohne eigenen Wert: '
                      '$exchangeRateSource.'
                      '${isAdmin ? '' : ' Steuersätze ändert ein Administrator.'}',
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stores the standard rate and currency for each country in [countries].
  Future<void> _applyTaxDefaults(List<MasterDataData> countries) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final database = ref.read(databaseProvider);
    var saved = 0;
    for (final country in countries) {
      final defaults = withholdingTaxDefaultFor(country.value);
      if (defaults == null) continue;
      await database.saveCountryTaxRate(
        actorUserId: userId,
        country: country.value,
        rate: defaults.withheld,
        currency: defaults.currency,
      );
      saved++;
    }
    if (mounted) _snack('Standard-Steuersätze für $saved Länder übernommen');
  }

  Future<void> _editTax(
    BuildContext context,
    String country,
    CountryTaxRate? stored,
  ) async {
    final defaults = withholdingTaxDefaultFor(country);
    final rate = TextEditingController(
      text: _percent(withholdingTaxRateFor(country, [?stored])),
    );
    final currency = TextEditingController(
      text:
          stored?.currency.toUpperCase() ??
          defaults?.currency ??
          defaultCurrencyForCountry(country),
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<(double, String)>(
      context: context,
      builder: (context) {
        final text = Theme.of(context).textTheme;
        return AlertDialog(
          title: Text('Steuern · $country'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: rate,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quellensteuer auf Dividenden',
                      suffixText: '%',
                    ),
                    validator: (value) {
                      final parsed = _parsePercent(value);
                      return parsed == null || parsed < 0 || parsed > 100
                          ? 'Bitte 0 bis 100 eingeben.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currency,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Währung der Dividenden (ISO)',
                    ),
                    validator: (value) => isSupportedCurrency(value ?? '')
                        ? null
                        : 'Unbekannte Währung, z. B. USD',
                  ),
                  const SizedBox(height: 14),
                  if (defaults != null) ...[
                    Text(
                      'Standard: ${_percent(defaults.withheld)} % einbehalten, '
                      '${_percent(defaults.creditable)} % anrechenbar'
                      '${defaults.note.isEmpty ? '' : '. ${defaults.note}'}.',
                      style: text.bodySmall,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          rate.text = _percent(defaults.withheld);
                          currency.text = defaults.currency;
                        },
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Standardwert einsetzen'),
                      ),
                    ),
                  ] else
                    Text(
                      'Für dieses Land gibt es keinen Standardwert. '
                      'Den Satz findest du in der Liste des BZSt.',
                      style: text.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, (
                    _parsePercent(rate.text)!,
                    currency.text.trim().toUpperCase(),
                  ));
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
    disposeAfterClose(rate);
    disposeAfterClose(currency);
    final userId = ref.read(currentUserIdProvider);
    if (result == null || userId == null) return;
    await ref
        .read(databaseProvider)
        .saveCountryTaxRate(
          actorUserId: userId,
          country: country,
          rate: result.$1,
          currency: result.$2,
        );
    if (mounted) _snack('Steuersatz für $country gespeichert');
  }

  Future<void> _add() async {
    final value = _addController.text.trim();
    if (value.isEmpty) {
      setState(() => _addError = 'Bitte einen Namen eingeben.');
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final added = await ref
        .read(databaseProvider)
        .addMasterDatum(userId, _kind.key, value);
    if (!mounted) return;
    setState(() {
      _addError = added ? null : '„$value“ gibt es schon.';
      if (added) _addController.clear();
    });
    if (added) _addFocus.requestFocus();
  }

  Future<void> _adopt(List<String> values) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final database = ref.read(databaseProvider);
    for (final value in values) {
      await database.addMasterDatum(userId, _kind.key, value);
    }
    if (!mounted) return;
    _snack(
      values.length == 1
          ? '„${values.first}“ übernommen'
          : '${values.length} Einträge übernommen',
    );
  }

  Future<void> _rename(
    BuildContext context,
    MasterDataData item,
    MasterDataUsage usage,
    List<MasterDataData> entries,
  ) async {
    final controller = TextEditingController(text: item.value);
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final name = controller.text.trim();
          final twin = entries
              .where(
                (e) =>
                    e.id != item.id &&
                    e.value.toLowerCase() == name.toLowerCase(),
              )
              .firstOrNull;
          final info = twin != null
              ? 'Gibt es schon. „${item.value}“ wird mit „${twin.value}“ '
                    'zusammengeführt.'
              : usage.total > 0
              ? 'Wird auch in ${_usageText(usage)} geändert.'
              : 'Wird noch nirgends verwendet.';
          void submit() {
            if (name.isNotEmpty && name != item.value) {
              Navigator.pop(context, name);
            }
          }

          return AlertDialog(
            title: Text('${_kind.singular} umbenennen'),
            content: SizedBox(
              width: 430,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => setDialogState(() {}),
                    onSubmitted: (_) => submit(),
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  Text(info, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: name.isEmpty || name == item.value ? null : submit,
                child: Text(twin != null ? 'Zusammenführen' : 'Umbenennen'),
              ),
            ],
          );
        },
      ),
    );
    disposeAfterClose(controller);
    if (newValue == null) return;
    final changed = await ref
        .read(databaseProvider)
        .renameMasterDatum(item, newValue);
    if (!mounted) return;
    _snack(
      changed == 0
          ? '„${item.value}“ heißt jetzt „$newValue“'
          : '„${item.value}“ → „$newValue“ in $changed Einträgen geändert',
    );
  }

  Future<void> _merge(
    BuildContext context,
    MasterDataData item,
    MasterDataUsage usage,
    List<MasterDataData> entries,
  ) async {
    final others = entries.where((e) => e.id != item.id).toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    String? targetId;
    final target = await showDialog<MasterDataData>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('„${item.value}“ zusammenführen'),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchableDropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Mit'),
                  items: [
                    for (final other in others)
                      DropdownMenuItem(
                        value: other.id,
                        child: Text(other.value),
                      ),
                  ],
                  onChanged: (value) => setDialogState(() => targetId = value),
                ),
                const SizedBox(height: 12),
                Text(
                  usage.total > 0
                      ? '${_usageText(usage)} werden übernommen, danach wird '
                            '„${item.value}“ entfernt.'
                      : '„${item.value}“ wird danach entfernt.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: targetId == null
                  ? null
                  : () => Navigator.pop(
                      context,
                      others.firstWhere((o) => o.id == targetId),
                    ),
              child: const Text('Zusammenführen'),
            ),
          ],
        ),
      ),
    );
    if (target == null) return;
    final changed = await ref
        .read(databaseProvider)
        .renameMasterDatum(item, target.value);
    if (!mounted) return;
    _snack(
      '„${item.value}“ in „${target.value}“ zusammengeführt'
      '${changed > 0 ? ' ($changed Einträge)' : ''}',
    );
  }

  Future<void> _delete(
    BuildContext context,
    MasterDataData item,
    MasterDataUsage usage,
  ) async {
    if (usage.total > 0 &&
        !await confirmDelete(
          context,
          title: '„${item.value}“ entfernen?',
          message:
              'Wird in ${_usageText(usage)} verwendet. Diese behalten den '
              'Wert, er wird nur nicht mehr vorgeschlagen.',
        )) {
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final database = ref.read(databaseProvider);
    await database.deleteMasterDatum(item.id, userId);
    if (!mounted) return;
    _snack(
      '„${item.value}“ entfernt',
      undo: () => database.restoreMasterDatum(item.id, userId),
    );
  }

  void _snack(String message, {VoidCallback? undo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: undo == null
              ? null
              : SnackBarAction(label: 'Rückgängig', onPressed: undo),
        ),
      );
  }
}

/// "15", "12,8", "15,315": German decimals without trailing zeros.
String _percent(double value) {
  var text = value.toStringAsFixed(3);
  text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return text.replaceAll('.', ',');
}

double? _parsePercent(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));

/// Common values offered as one-tap chips, per kind.
List<String> _suggestions(String kind) => switch (kind) {
  'category' => const [
    'Lebensmittel',
    'Wohnen',
    'Auto',
    'Tanken',
    'Versicherungen',
    'Freizeit',
    'Restaurant',
    'Kleidung',
    'Abos',
    'Urlaub',
    'Gesundheit',
    'Geschenke',
    'Bildung',
    'Gehalt',
    'Dividende',
    'Sparen',
    'Sonstiges',
  ],
  'merchant' => const [
    'Rewe',
    'Edeka',
    'Aldi',
    'Lidl',
    'Kaufland',
    'dm',
    'Rossmann',
    'Amazon',
    'IKEA',
    'Arbeitgeber',
  ],
  'paymentMethod' => const [
    'Bar',
    'Girokarte',
    'Kreditkarte',
    'Lastschrift',
    'Überweisung',
    'PayPal',
    'Apple Pay',
    'Google Pay',
  ],
  'broker' => const [
    'Trade Republic',
    'Scalable Capital',
    'comdirect',
    'Consorsbank',
    'ING',
    'DKB',
    'flatex',
    'Interactive Brokers',
  ],
  'country' => [for (final entry in withholdingTaxDefaults) entry.country],
  'sector' => const [
    'Technologie',
    'Finanzen',
    'Gesundheit',
    'Industrie',
    'Basiskonsumgüter',
    'Nicht-Basiskonsumgüter',
    'Energie',
    'Versorger',
    'Immobilien',
    'Kommunikation',
    'Rohstoffe',
  ],
  _ => const [],
};

/// Tax facts of one country for the list: stored rule or standard value.
class _CountryTax {
  const _CountryTax({
    required this.baseCurrency,
    required this.rate,
    required this.rateIsAverage,
    required this.withheld,
    required this.creditable,
    required this.currency,
    required this.source,
  });

  factory _CountryTax.of(
    String country,
    CountryTaxRate? stored,
    CurrencyConverter converter,
  ) {
    final defaults = withholdingTaxDefaultFor(country);
    final withheld = stored?.withholdingTaxRate ?? defaults?.withheld;
    final currency =
        stored?.currency.toUpperCase() ??
        defaults?.currency ??
        defaultCurrencyForCountry(country);
    final base = converter.baseCurrency;
    final configured =
        stored != null &&
        isConfiguredRate(
          stored.exchangeRate,
          currency,
          base,
          updatedAt: stored.exchangeRateUpdatedAt,
        );
    return _CountryTax(
      baseCurrency: base,
      rate: currency == base
          ? null
          : configured
          ? stored.exchangeRate
          : defaultExchangeRate(currency, base),
      rateIsAverage: !configured,
      withheld: withheld,
      // Never more creditable than actually withheld.
      creditable: defaults == null || withheld == null
          ? null
          : (defaults.creditable < withheld ? defaults.creditable : withheld),
      currency: currency,
      source: stored == null
          ? (defaults == null ? _TaxSource.none : _TaxSource.standard)
          : (defaults != null && defaults.withheld != stored.withholdingTaxRate
                ? _TaxSource.custom
                : _TaxSource.stored),
    );
  }

  final double? withheld;
  final double? creditable;
  final String currency;
  final _TaxSource source;

  final String baseCurrency;

  /// Units of [baseCurrency] for 1 [currency]; null for the same currency
  /// or without a published rate.
  final double? rate;

  /// The ECB average, not a rate the administration set.
  final bool rateIsAverage;
}

enum _TaxSource { none, standard, stored, custom }

String _usageText(MasterDataUsage usage) {
  final parts = [
    if (usage.household > 0)
      '${usage.household} ${usage.household == 1 ? 'Eintrag' : 'Einträgen'}',
    if (usage.portfolio > 0)
      '${usage.portfolio} ${usage.portfolio == 1 ? 'Position' : 'Positionen'}',
  ];
  return parts.isEmpty ? 'nicht verwendet' : parts.join(' und ');
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.item,
    required this.usage,
    required this.onRename,
    required this.onMerge,
    required this.onDelete,
    this.tax,
    this.onEditTax,
  });

  final MasterDataData item;
  final MasterDataUsage usage;
  final VoidCallback onRename;
  final VoidCallback? onMerge;
  final VoidCallback onDelete;

  /// Withholding tax facts, for countries only.
  final _CountryTax? tax;

  /// Opens the tax rule editor (countries, administrators only).
  final VoidCallback? onEditTax;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final used = usage.total > 0;
    final usageLine = Text(
      used ? 'in ${_usageText(usage)}' : 'nicht verwendet',
      style: TextStyle(color: used ? colors.muted : colors.warning),
    );
    final tax = this.tax;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 8),
      title: Text(item.value),
      subtitle: tax == null
          ? usageLine
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                usageLine,
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Fact(
                      label: 'Quellensteuer',
                      value: tax.withheld == null
                          ? 'unbekannt'
                          : '${_percent(tax.withheld!)} %',
                      highlight: tax.source == _TaxSource.none,
                    ),
                    if (tax.creditable != null)
                      _Fact(
                        label: 'anrechenbar',
                        value: '${_percent(tax.creditable!)} %',
                      ),
                    _Fact(label: 'Währung', value: tax.currency),
                    if (tax.rate != null)
                      _Fact(
                        label: tax.rateIsAverage ? 'Ø EZB-Kurs' : 'Kurs',
                        value:
                            '1 ${tax.currency} = '
                            '${rateText(tax.rate!).replaceAll('.', ',')} ${tax.baseCurrency}',
                      ),
                    _Fact(
                      label: switch (tax.source) {
                        _TaxSource.none => 'kein Standardwert',
                        _TaxSource.standard => 'Standardwert',
                        _TaxSource.stored => 'gespeichert',
                        _TaxSource.custom => 'eigener Wert',
                      },
                    ),
                  ],
                ),
              ],
            ),
      isThreeLine: tax != null,
      onTap: onEditTax ?? onRename,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (used)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.incomeSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${usage.total}',
                style: TextStyle(
                  color: colors.income,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFeatures: AppTheme.tabular,
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Aktionen für ${item.value}',
            onSelected: (action) => switch (action) {
              'tax' => onEditTax?.call(),
              'rename' => onRename(),
              'merge' => onMerge?.call(),
              _ => onDelete(),
            },
            itemBuilder: (context) => [
              if (onEditTax != null)
                const PopupMenuItem(
                  value: 'tax',
                  child: ListTile(
                    leading: Icon(Icons.percent_rounded),
                    title: Text('Steuern bearbeiten'),
                  ),
                ),
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Umbenennen'),
                ),
              ),
              PopupMenuItem(
                value: 'merge',
                enabled: onMerge != null,
                child: const ListTile(
                  leading: Icon(Icons.merge_rounded),
                  title: Text('Zusammenführen …'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Entfernen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small labelled value, e.g. "Quellensteuer 15 %".
class _Fact extends StatelessWidget {
  const _Fact({required this.label, this.value, this.highlight = false});

  final String label;
  final String? value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight ? colors.expenseSoft : colors.neutralSoft,
        borderRadius: BorderRadius.circular(
          style.radiusControl < 8 ? style.radiusControl : 8,
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: value == null ? label : '$label ',
          style: TextStyle(fontSize: 12, color: colors.muted),
          children: [
            if (value != null)
              TextSpan(
                text: value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: highlight ? colors.expense : colors.neutral,
                  fontFeatures: AppTheme.tabular,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KindList extends StatelessWidget {
  const _KindList({
    required this.selected,
    required this.countOf,
    required this.onSelected,
  });

  final _Kind selected;
  final int Function(_Kind) countOf;
  final ValueChanged<_Kind> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final kind in MasterDataPage._kinds)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: ListTile(
                  selected: kind == selected,
                  selectedTileColor: colors.incomeSoft,
                  selectedColor: colors.income,
                  leading: Icon(kind.icon, size: 20),
                  title: Text(kind.label),
                  trailing: Text(
                    '${countOf(kind)}',
                    style: const TextStyle(fontFeatures: AppTheme.tabular),
                  ),
                  onTap: () => onSelected(kind),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KindChips extends StatelessWidget {
  const _KindChips({
    required this.selected,
    required this.countOf,
    required this.onSelected,
  });

  final _Kind selected;
  final int Function(_Kind) countOf;
  final ValueChanged<_Kind> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final kind in MasterDataPage._kinds)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(kind.icon, size: 18),
              label: Text('${kind.label} · ${countOf(kind)}'),
              selected: kind == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(kind),
            ),
          ),
      ],
    ),
  );
}

class _AssetClassList extends StatelessWidget {
  const _AssetClassList({required this.assetClasses});

  final List<AssetClassesData> assetClasses;

  @override
  Widget build(BuildContext context) {
    final sorted = [...assetClasses]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Row(
              children: [
                const IconTile(icon: Icons.category_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anlageklassen', style: text.titleLarge),
                      Text(
                        'Fest vorgegeben, damit Aufteilung und Steuer in allen '
                        'Depots gleich gerechnet werden.',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (sorted.isEmpty)
            const ListTile(title: Text('Noch keine Einträge')),
          for (final assetClass in sorted)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(assetClass.name),
              trailing: const Icon(Icons.lock_outline_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}
