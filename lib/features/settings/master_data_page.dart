import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';

import '../../app/app_theme.dart';
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
          ..sort(
            (a, b) => _sort == _Sort.usage
                ? usageOf(b.value).total.compareTo(usageOf(a.value).total)
                : a.value.toLowerCase().compareTo(b.value.toLowerCase()),
          );
    if (_sort == _Sort.usage) {
      // Stable A–Z order among equally used entries.
      visible.sort((a, b) {
        final byUse = usageOf(b.value).total.compareTo(usageOf(a.value).total);
        return byUse != 0
            ? byUse
            : a.value.toLowerCase().compareTo(b.value.toLowerCase());
      });
    }
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
                      labelText: 'Neue ${_kind.singular}',
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
              ],
            ),
          ),
        ],
      ),
    );
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
    controller.dispose();
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
  });

  final MasterDataData item;
  final MasterDataUsage usage;
  final VoidCallback onRename;
  final VoidCallback? onMerge;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final used = usage.total > 0;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 8),
      title: Text(item.value),
      subtitle: Text(
        used ? 'in ${_usageText(usage)}' : 'nicht verwendet',
        style: TextStyle(color: used ? colors.muted : colors.warning),
      ),
      onTap: onRename,
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
              'rename' => onRename(),
              'merge' => onMerge?.call(),
              _ => onDelete(),
            },
            itemBuilder: (context) => [
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
