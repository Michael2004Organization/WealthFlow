import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class InvestmentsPage extends ConsumerStatefulWidget {
  const InvestmentsPage({super.key});

  @override
  ConsumerState<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends ConsumerState<InvestmentsPage> {
  String _query = '';
  String _type = 'Alle';
  String _sort = 'Wert';

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(investmentsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Portfolio',
                subtitle: 'Positionen, Performance und Erträge im Blick.',
                action: FilledButton.icon(
                  onPressed: () => showInvestmentEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Position'),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        labelText: 'Portfolio durchsuchen',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Anlageklasse',
                      ),
                      items:
                          const [
                                'Alle',
                                'Aktie',
                                'ETF',
                                'Kryptowährung',
                                'Anleihe',
                                'Fonds',
                                'Edelmetall',
                                'Hebelprodukt',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => _type = value ?? 'Alle'),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _sort,
                      decoration: const InputDecoration(
                        labelText: 'Sortierung',
                      ),
                      items:
                          const [
                                'Wert',
                                'Performance',
                                'Gewinn',
                                'Alphabetisch',
                                'Kaufdatum',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setState(() => _sort = value ?? 'Wert'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: asyncItems.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Portfolio konnte nicht geladen werden: $error',
                    ),
                  ),
                  data: (allItems) {
                    final items = allItems.where((item) {
                      final matchesType =
                          _type == 'Alle' || item.assetType == _type;
                      final text =
                          '${item.name} ${item.symbol} ${item.isin} ${item.broker}'
                              .toLowerCase();
                      return matchesType && text.contains(_query);
                    }).toList();
                    items.sort(_compare);
                    if (allItems.isEmpty) {
                      return EmptyState(
                        icon: Icons.candlestick_chart_rounded,
                        title: 'Dein Portfolio ist noch leer',
                        message:
                            'Erfasse eine Aktie, einen ETF oder eine andere Anlage. Wert und Performance werden automatisch berechnet.',
                        action: FilledButton.icon(
                          onPressed: () => showInvestmentEditor(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Erste Position'),
                        ),
                      );
                    }
                    if (items.isEmpty) {
                      return const EmptyState(
                        icon: Icons.filter_alt_off_rounded,
                        title: 'Keine Treffer',
                        message: 'Passe Suche oder Anlageklasse an.',
                      );
                    }
                    final portfolio = allItems.fold<double>(
                      0,
                      (sum, item) => sum + _value(item),
                    );
                    final cost = allItems.fold<double>(
                      0,
                      (sum, item) => sum + _cost(item),
                    );
                    return ListView(
                      children: [
                        _PortfolioSummary(
                          value: portfolio,
                          cost: cost,
                          positions: allItems.length,
                        ),
                        const SizedBox(height: 16),
                        for (final item in items) ...[
                          _InvestmentTile(item: item),
                          const SizedBox(height: 10),
                        ],
                      ],
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

  int _compare(Investment a, Investment b) => switch (_sort) {
    'Performance' => _performance(b).compareTo(_performance(a)),
    'Gewinn' => (_value(b) - _cost(b)).compareTo(_value(a) - _cost(a)),
    'Alphabetisch' => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    'Kaufdatum' => b.purchaseDate.compareTo(a.purchaseDate),
    _ => _value(b).compareTo(_value(a)),
  };

  double _value(Investment item) => item.quantity * item.currentPrice;
  double _cost(Investment item) =>
      item.quantity * item.purchasePrice + item.fees;
  double _performance(Investment item) =>
      _cost(item) == 0 ? 0 : (_value(item) - _cost(item)) / _cost(item);
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.value,
    required this.cost,
    required this.positions,
  });
  final double value;
  final double cost;
  final int positions;

  @override
  Widget build(BuildContext context) {
    final gain = value - cost;
    final positive = gain >= 0;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Wrap(
          spacing: 36,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _SummaryValue(label: 'Depotwert', value: money(value)),
            _SummaryValue(label: 'Investiert', value: money(cost)),
            _SummaryValue(
              label: 'Gesamtgewinn',
              value: '${positive ? '+' : ''}${money(gain)}',
              color: positive
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
            _SummaryValue(
              label: 'Performance',
              value: cost == 0
                  ? '–'
                  : '${positive ? '+' : ''}${(gain / cost * 100).toStringAsFixed(2)} %',
              color: positive
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
            _SummaryValue(label: 'Positionen', value: '$positions'),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

class _InvestmentTile extends ConsumerWidget {
  const _InvestmentTile({required this.item});
  final Investment item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = item.quantity * item.currentPrice;
    final cost = item.quantity * item.purchasePrice + item.fees;
    final gain = value - cost;
    final positive = gain >= 0;
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        onTap: () => _showInvestmentDetails(
          context,
          ref,
          item,
          purchases
              .where((purchase) => purchase.investmentId == item.id)
              .toList(),
        ),
        leading: CircleAvatar(
          child: Text(
            item.symbol.isEmpty
                ? item.name[0].toUpperCase()
                : item.symbol
                      .substring(
                        0,
                        item.symbol.length > 3 ? 3 : item.symbol.length,
                      )
                      .toUpperCase(),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${item.assetType} · ${item.quantity.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '')} Stück${item.broker.isEmpty ? '' : ' · ${item.broker}'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(value),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${positive ? '+' : ''}${money(gain)}',
                  style: TextStyle(
                    color: positive
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'history') {
                  await _showInvestmentDetails(
                    context,
                    ref,
                    item,
                    purchases
                        .where((purchase) => purchase.investmentId == item.id)
                        .toList(),
                  );
                } else if (value == 'edit') {
                  await showInvestmentEditor(context, ref, investment: item);
                } else if (value == 'delete' &&
                    await confirmDelete(
                      context,
                      title: 'Position löschen?',
                      message:
                          '${item.name} wird aus deinem Portfolio entfernt.',
                    )) {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    await ref
                        .read(databaseProvider)
                        .deleteInvestment(item.id, userId);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'history',
                  child: Text('Details & Kaufhistorie'),
                ),
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showInvestmentDetails(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
  List<InvestmentPurchase> purchases,
) => showDialog<void>(
  context: context,
  builder: (context) {
    final sorted = [...purchases]
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Expanded(child: Text(investment.name)),
          IconButton(
            tooltip: 'Position bearbeiten',
            onPressed: () {
              Navigator.pop(context);
              showInvestmentEditor(context, ref, investment: investment);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 680),
        height: (MediaQuery.sizeOf(context).height - 240).clamp(280, 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(
                  avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text(
                    investment.quantity.toStringAsFixed(4) + ' Stück',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.show_chart_rounded, size: 18),
                  label: Text('Kurs ' + money(investment.currentPrice)),
                ),
                if (investment.isin.isNotEmpty)
                  Chip(label: Text('ISIN ' + investment.isin)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Kaufhistorie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sorted.isEmpty
                  ? const Center(
                      child: Text(
                        'Für diese ältere Position ist noch kein Kauf hinterlegt.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: sorted.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final purchase = sorted[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.add_chart_rounded),
                          ),
                          title: Text(
                            purchase.quantity.toStringAsFixed(4) +
                                ' Stück · ' +
                                money(purchase.purchasePrice),
                          ),
                          subtitle: Text(
                            DateFormat(
                                  'dd.MM.yyyy',
                                ).format(purchase.purchaseDate) +
                                (purchase.fees == 0
                                    ? ''
                                    : ' · Gebühren ' + money(purchase.fees)),
                          ),
                          trailing: Text(
                            money(
                              purchase.quantity * purchase.purchasePrice +
                                  purchase.fees,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  },
);

Future<void> showInvestmentEditor(
  BuildContext context,
  WidgetRef ref, {
  Investment? investment,
}) async {
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final existingItems =
      ref.read(investmentsProvider).valueOrNull ?? const <Investment>[];
  final result = await showDialog<InvestmentsCompanion>(
    context: context,
    builder: (_) => _InvestmentEditor(
      investment: investment,
      masterData: masterData,
      existingItems: existingItems,
    ),
  );
  if (result != null) {
    final database = ref.read(databaseProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      Investment? duplicate;
      if (investment == null) {
        final newName = result.name.value.trim().toLowerCase();
        final newIsin = result.isin.value.trim().toUpperCase();
        duplicate = existingItems
            .where(
              (item) =>
                  (newIsin.isNotEmpty && item.isin.toUpperCase() == newIsin) ||
                  item.name.trim().toLowerCase() == newName,
            )
            .firstOrNull;
      }
      final targetId = duplicate?.id ?? result.id.value;
      if (duplicate == null) {
        await database.saveInvestment(result);
      } else {
        final addedQuantity = result.quantity.value;
        final totalQuantity = duplicate.quantity + addedQuantity;
        final averagePrice = totalQuantity == 0
            ? 0.0
            : (duplicate.quantity * duplicate.purchasePrice +
                      addedQuantity * result.purchasePrice.value) /
                  totalQuantity;
        await database.saveInvestment(
          InvestmentsCompanion.insert(
            id: duplicate.id,
            userId: duplicate.userId,
            name: result.name.value,
            symbol: result.symbol,
            isin: result.isin,
            wkn: result.wkn,
            assetType: result.assetType.value,
            broker: result.broker,
            country: result.country,
            sector: result.sector,
            purchaseDate:
                duplicate.purchaseDate.isBefore(result.purchaseDate.value)
                ? duplicate.purchaseDate
                : result.purchaseDate.value,
            purchasePrice: averagePrice,
            quantity: totalQuantity,
            fees: Value(duplicate.fees + result.fees.value),
            currentPrice: result.currentPrice.value,
            annualDividend: result.annualDividend,
            dividendFrequency: result.dividendFrequency,
            notes: result.notes,
            createdAt: duplicate.createdAt,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
      if (investment == null) {
        await database.saveInvestmentPurchase(
          InvestmentPurchasesCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            investmentId: targetId,
            purchaseDate: result.purchaseDate.value,
            purchasePrice: result.purchasePrice.value,
            quantity: result.quantity.value,
            fees: result.fees,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
      for (final item in {
        'broker': result.broker.value,
        'country': result.country.value,
        'sector': result.sector.value,
      }.entries.where((item) => item.value.trim().isNotEmpty)) {
        await database.saveMasterDatum(
          MasterDataCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            kind: item.key,
            value: item.value.trim(),
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }
}

class _InvestmentEditor extends StatefulWidget {
  const _InvestmentEditor({
    required this.masterData,
    required this.existingItems,
    this.investment,
  });
  final Investment? investment;
  final List<MasterDataData> masterData;
  final List<Investment> existingItems;
  @override
  State<_InvestmentEditor> createState() => _InvestmentEditorState();
}

class _InvestmentEditorState extends State<_InvestmentEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.investment?.name);
  late final _symbol = TextEditingController(text: widget.investment?.symbol);
  late final _isin = TextEditingController(text: widget.investment?.isin);
  late final _wkn = TextEditingController(text: widget.investment?.wkn);
  late final _broker = TextEditingController(text: widget.investment?.broker);
  late final _country = TextEditingController(text: widget.investment?.country);
  late final _sector = TextEditingController(text: widget.investment?.sector);
  late final _purchasePrice = TextEditingController(
    text: widget.investment?.purchasePrice.toString(),
  );
  late final _quantity = TextEditingController(
    text: widget.investment?.quantity.toString(),
  );
  late final _fees = TextEditingController(
    text: widget.investment?.fees.toString() ?? '0',
  );
  late final _currentPrice = TextEditingController(
    text: widget.investment?.currentPrice.toString(),
  );
  late final _dividend = TextEditingController(
    text: widget.investment?.annualDividend.toString() ?? '0',
  );
  late final _notes = TextEditingController(text: widget.investment?.notes);
  late String _type = widget.investment?.assetType ?? 'Aktie';
  late String _frequency = widget.investment?.dividendFrequency ?? 'jährlich';
  late DateTime _date = widget.investment?.purchaseDate ?? DateTime.now();
  String? _selectedExistingId;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _symbol,
      _isin,
      _wkn,
      _broker,
      _country,
      _sector,
      _purchasePrice,
      _quantity,
      _fees,
      _currentPrice,
      _dividend,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.investment == null ? 'Position anlegen' : 'Position bearbeiten',
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 650.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (widget.investment == null &&
                    widget.existingItems.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedExistingId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText:
                          'Zu bestehender Position hinzufügen (optional)',
                      prefixIcon: Icon(Icons.playlist_add_rounded),
                    ),
                    items: widget.existingItems
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              item.name +
                                  (item.isin.isEmpty ? '' : ' · ' + item.isin),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _selectExisting,
                  ),
                  const SizedBox(height: 12),
                ],
                _responsiveFields([
                  _field(_name, 'Name', required: true),
                  _field(_symbol, 'Symbol'),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([_field(_isin, 'ISIN'), _field(_wkn, 'WKN')]),
                const SizedBox(height: 12),
                _responsiveFields([
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Anlageklasse',
                    ),
                    items:
                        const [
                              'Aktie',
                              'ETF',
                              'Kryptowährung',
                              'Anleihe',
                              'Fonds',
                              'Edelmetall',
                              'Hebelprodukt',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => _type = v ?? 'Aktie',
                  ),
                  _masterField(_broker, 'Broker', 'broker'),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _masterField(_country, 'Land', 'country'),
                  _masterField(_sector, 'Branche', 'sector'),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    _purchasePrice,
                    'Kaufkurs',
                    number: true,
                    required: true,
                  ),
                  _field(_quantity, 'Stückzahl', number: true, required: true),
                  _field(_fees, 'Gebühren', number: true, required: true),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    _currentPrice,
                    'Aktueller Kurs',
                    number: true,
                    required: true,
                  ),
                  _field(
                    _dividend,
                    'Dividende je Stück/Ausschüttung',
                    number: true,
                    required: true,
                  ),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  DropdownButtonFormField<String>(
                    initialValue: _frequency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Auszahlungsrhythmus',
                    ),
                    items:
                        const [
                              'monatlich',
                              'vierteljährlich',
                              'halbjährlich',
                              'jährlich',
                              'Sonderdividende',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => _frequency = v ?? 'jährlich',
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      'Kauf: ${DateFormat('dd.MM.yyyy').format(_date)}',
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _field(_notes, 'Notizen', lines: 3),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    int lines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: lines,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : null,
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      if (required && (value?.trim().isEmpty ?? true)) return 'Pflichtfeld';
      if (number && _number(value) == null) return 'Ungültige Zahl';
      if (number && (_number(value) ?? -1) < 0) return 'Muss positiv sein';
      return null;
    },
  );

  Widget _responsiveFields(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return Column(
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              fields[index],
              if (index < fields.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return Row(
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            Expanded(child: fields[index]),
            if (index < fields.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    },
  );

  Widget _masterField(
    TextEditingController controller,
    String label,
    String kind,
  ) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: PopupMenuButton<String>(
        tooltip: 'Vorhandene Werte anzeigen',
        icon: const Icon(Icons.arrow_drop_down_rounded),
        onSelected: (value) {
          controller
            ..text = value
            ..selection = TextSelection.collapsed(offset: value.length);
        },
        itemBuilder: (context) => widget.masterData
            .where((item) => item.kind == kind)
            .map(
              (item) => PopupMenuItem<String>(
                value: item.value,
                child: Text(item.value),
              ),
            )
            .toList(),
      ),
    ),
  );

  void _selectExisting(String? id) {
    if (id == null) return;
    final item = widget.existingItems.firstWhere((item) => item.id == id);
    setState(() {
      _selectedExistingId = id;
      _name.text = item.name;
      _symbol.text = item.symbol;
      _isin.text = item.isin;
      _wkn.text = item.wkn;
      _broker.text = item.broker;
      _country.text = item.country;
      _sector.text = item.sector;
      _currentPrice.text = item.currentPrice.toString();
      _dividend.text = item.annualDividend.toString();
      _notes.text = item.notes;
      _type = item.assetType;
      _frequency = item.dividendFrequency;
      _purchasePrice.clear();
      _quantity.clear();
      _fees.text = '0';
    });
  }

  double? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(
      context,
      InvestmentsCompanion.insert(
        id: widget.investment?.id ?? const Uuid().v4(),
        userId: userId,
        name: _name.text.trim(),
        symbol: Value(_symbol.text.trim().toUpperCase()),
        isin: Value(_isin.text.trim().toUpperCase()),
        wkn: Value(_wkn.text.trim().toUpperCase()),
        assetType: _type,
        broker: Value(_broker.text.trim()),
        country: Value(_country.text.trim()),
        sector: Value(_sector.text.trim()),
        purchaseDate: _date,
        purchasePrice: _number(_purchasePrice.text) ?? 0,
        quantity: _number(_quantity.text) ?? 0,
        fees: Value(_number(_fees.text) ?? 0),
        currentPrice: _number(_currentPrice.text) ?? 0,
        annualDividend: Value(_number(_dividend.text) ?? 0),
        dividendFrequency: Value(_frequency),
        notes: Value(_notes.text.trim()),
        createdAt: widget.investment?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
