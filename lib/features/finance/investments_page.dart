import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/portfolio_tax_summary.dart';
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
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(investmentsProvider);
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final physicalAssets =
        ref.watch(physicalAssetsProvider).valueOrNull ??
        const <PhysicalAsset>[];
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final purchases =
        ref.watch(investmentPurchasesProvider).valueOrNull ??
        const <InvestmentPurchase>[];
    final sales =
        ref.watch(portfolioSalesProvider).valueOrNull ??
        const <PortfolioSale>[];
    final auditLogs =
        ref.watch(portfolioAuditLogsProvider).valueOrNull ??
        const <PortfolioAuditLog>[];
    final schedules =
        ref.watch(dividendSchedulesProvider).valueOrNull ??
        const <DividendSchedule>[];
    final eligibleAccounts = accounts.where((account) {
      if (account.usageType == 'portfolio') return true;
      if (account.usageType != 'unassigned') return false;
      return !entries.any((entry) => entry.accountId == account.id);
    }).toList();
    final eligibleIds = eligibleAccounts.map((account) => account.id).toSet();
    final selectedAccountId = eligibleIds.contains(_selectedAccountId)
        ? _selectedAccountId
        : eligibleIds.contains(preference?.selectedPortfolioAccountId)
        ? preference?.selectedPortfolioAccountId
        : eligibleAccounts.firstOrNull?.id;
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
                action: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: selectedAccountId == null
                          ? null
                          : () => showInvestmentEditor(
                              context,
                              ref,
                              accountId: selectedAccountId,
                            ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Position'),
                    ),
                    OutlinedButton.icon(
                      onPressed: selectedAccountId == null
                          ? null
                          : () => _showPhysicalAssetEditor(
                              context,
                              ref,
                              accountId: selectedAccountId,
                            ),
                      icon: const Icon(Icons.diamond_outlined),
                      label: const Text('Wertgegenstand'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showPortfolioActivity(
                        context,
                        sales: sales,
                        auditLogs: auditLogs,
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Verkäufe & Protokoll'),
                    ),
                    IconButton.outlined(
                      tooltip: 'Standardgebühr für neue Käufe',
                      onPressed: preference == null
                          ? null
                          : () => _editDefaultInvestmentFee(
                              context,
                              ref,
                              preference,
                            ),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(selectedAccountId),
                      initialValue: selectedAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Portfolio-Konto',
                        prefixIcon: Icon(Icons.account_balance_rounded),
                      ),
                      items: eligibleAccounts
                          .map(
                            (account) => DropdownMenuItem(
                              value: account.id,
                              child: Text(
                                '${account.label} · ${money(account.balance)} Cash',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => _selectPortfolioAccount(value),
                    ),
                  ),
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
                    final portfolioItems = allItems
                        .where((item) => item.accountId == selectedAccountId)
                        .toList();
                    final accountAssets = physicalAssets
                        .where((item) => item.accountId == selectedAccountId)
                        .toList();
                    final items = portfolioItems.where((item) {
                      final matchesType =
                          _type == 'Alle' || item.assetType == _type;
                      final text =
                          '${item.name} ${item.symbol} ${item.isin} ${item.broker}'
                              .toLowerCase();
                      return matchesType && text.contains(_query);
                    }).toList();
                    items.sort(_compare);
                    if (selectedAccountId == null) {
                      return EmptyState(
                        icon: Icons.account_balance_outlined,
                        title: 'Portfolio-Konto erforderlich',
                        message:
                            'Lege zuerst ein leeres Konto an oder wähle ein noch ungenutztes Konto als Portfolio-Konto.',
                      );
                    }
                    if (portfolioItems.isEmpty && accountAssets.isEmpty) {
                      return EmptyState(
                        icon: Icons.candlestick_chart_rounded,
                        title: 'Dein Portfolio ist noch leer',
                        message:
                            'Erfasse eine Aktie, einen ETF oder eine andere Anlage. Wert und Performance werden automatisch berechnet.',
                        action: FilledButton.icon(
                          onPressed: () => showInvestmentEditor(
                            context,
                            ref,
                            accountId: selectedAccountId,
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Erste Position'),
                        ),
                      );
                    }
                    final securitiesValue = portfolioItems.fold<double>(
                      0,
                      (sum, item) => sum + _value(item),
                    );
                    final physicalValue = accountAssets.fold<double>(
                      0,
                      (sum, item) =>
                          sum + item.weightGrams * item.currentPricePerGram,
                    );
                    final cash =
                        accounts
                            .where((account) => account.id == selectedAccountId)
                            .firstOrNull
                            ?.balance ??
                        0;
                    final portfolio = securitiesValue + physicalValue + cash;
                    final activeCost =
                        portfolioItems.fold<double>(
                          0,
                          (sum, item) => sum + _cost(item),
                        ) +
                        accountAssets.fold<double>(
                          0,
                          (sum, item) => sum + item.purchasePrice,
                        );
                    final accountSales = sales
                        .where((sale) => sale.accountId == selectedAccountId)
                        .toList();
                    final realizedGain = accountSales.fold<double>(
                      0,
                      (sum, sale) => sum + sale.realizedGain - sale.taxPaid,
                    );
                    final soldCost = accountSales.fold<double>(
                      0,
                      (sum, sale) => sum + sale.costBasis,
                    );
                    final unrealizedGain =
                        securitiesValue + physicalValue - activeCost;
                    final taxSummary = calculatePortfolioTaxYear(
                      year: DateTime.now().year,
                      allowance: preference?.taxAllowance ?? 1000,
                      investments: allItems,
                      schedules: schedules,
                      sales: sales,
                      through: DateTime.now(),
                    );
                    return ListView(
                      children: [
                        _PortfolioSummary(
                          value: portfolio,
                          investedValue: securitiesValue + physicalValue,
                          gain: unrealizedGain + realizedGain,
                          performanceBase: activeCost + soldCost,
                          positions:
                              portfolioItems.length + accountAssets.length,
                          cash: cash,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _TaxAllowanceTile(
                            preference: preference,
                            summary: taxSummary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Wertpapiere',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        for (final item in items) ...[
                          _InvestmentTile(
                            item: item,
                            purchaseCount: purchases
                                .where((row) => row.investmentId == item.id)
                                .length,
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Physische Wertgegenstände',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Wertgegenstand hinzufügen',
                              onPressed: () => _showPhysicalAssetEditor(
                                context,
                                ref,
                                accountId: selectedAccountId,
                              ),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (accountAssets.isEmpty)
                          const Text('Noch keine physischen Werte erfasst.')
                        else
                          for (final asset in accountAssets) ...[
                            _PhysicalAssetTile(asset: asset),
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

  Future<void> _selectPortfolioAccount(String? accountId) async {
    if (accountId == null) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      await ref
          .read(databaseProvider)
          .selectAccountForUsage(
            userId: userId,
            accountId: accountId,
            usageType: 'portfolio',
          );
      if (mounted) setState(() => _selectedAccountId = accountId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.value,
    required this.investedValue,
    required this.gain,
    required this.performanceBase,
    required this.positions,
    required this.cash,
  });
  final double value;
  final double investedValue;
  final double gain;
  final double performanceBase;
  final int positions;
  final double cash;

  @override
  Widget build(BuildContext context) {
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
            _SummaryValue(label: 'Portfolio gesamt', value: money(value)),
            _SummaryValue(label: 'Wertanlagen', value: money(investedValue)),
            _SummaryValue(
              label: 'Gesamtgewinn',
              value: '${positive ? '+' : ''}${money(gain)}',
              color: positive
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
            _SummaryValue(
              label: 'Performance',
              value: performanceBase == 0
                  ? '–'
                  : '${positive ? '+' : ''}${(gain / performanceBase * 100).toStringAsFixed(2)} %',
              color: positive
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
            _SummaryValue(label: 'Positionen', value: '$positions'),
            _SummaryValue(label: 'Cash', value: money(cash)),
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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

class _TaxAllowanceTile extends ConsumerWidget {
  const _TaxAllowanceTile({required this.preference, required this.summary});

  final UserPreference? preference;
  final PortfolioTaxSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maximum =
        ref.watch(appConfigurationProvider).valueOrNull?.maximumTaxAllowance ??
        1000;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Freistellungsauftrag ${DateTime.now().year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verwendet: ${money(summary.allowanceUsed)}'),
              Text('Verfügbar: ${money(summary.allowanceRemaining)}'),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: summary.allowance <= 0
                    ? 1
                    : (summary.allowanceUsed / summary.allowance).clamp(0, 1),
              ),
              if (summary.taxPaid > 0) ...[
                const SizedBox(height: 14),
                Text(
                  'Bereits gezahlte Steuern: ${money(summary.taxPaid)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        ),
      ),
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
            final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
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
  if (saved == true) {
    await ref
        .read(databaseProvider)
        .savePreferences(
          preference
              .toCompanion(false)
              .copyWith(
                taxAllowance: Value(
                  double.parse(controller.text.replaceAll(',', '.')),
                ),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
        );
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
  if (saved == true) {
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
  }
  controller.dispose();
}

class _PhysicalAssetTile extends ConsumerWidget {
  const _PhysicalAssetTile({required this.asset});

  final PhysicalAsset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentValue = asset.weightGrams * asset.currentPricePerGram;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.diamond_outlined)),
        title: Text(asset.name),
        subtitle: Text(
          [
            asset.category,
            if (asset.metalType.isNotEmpty) asset.metalType,
            '${asset.quantity.toStringAsFixed(2)} Einheiten',
            if (asset.weightGrams > 0)
              '${asset.weightGrams.toStringAsFixed(2)} g',
            '${money(asset.currentPricePerGram)}/g',
            if (asset.purchaseDate != null)
              'Kauf ${DateFormat('dd.MM.yyyy').format(asset.purchaseDate!)}',
            money(asset.purchasePrice),
          ].join(' · '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              money(currentValue),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _showPhysicalAssetEditor(
                    context,
                    ref,
                    accountId: asset.accountId,
                    asset: asset,
                  );
                } else if (value == 'sell') {
                  await _showPhysicalSaleDialog(context, ref, asset);
                } else if (value == 'delete' &&
                    await confirmDelete(
                      context,
                      title: 'Wertgegenstand löschen?',
                      message: '${asset.name} wird aus dem Portfolio entfernt.',
                    )) {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    await ref
                        .read(databaseProvider)
                        .deletePhysicalAsset(asset.id, userId);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(value: 'sell', child: Text('Verkaufen')),
                PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPhysicalAssetEditor(
  BuildContext context,
  WidgetRef ref, {
  required String accountId,
  PhysicalAsset? asset,
}) async {
  final name = TextEditingController(text: asset?.name);
  final quantity = TextEditingController(
    text: asset?.quantity.toString() ?? '1',
  );
  final weightGrams = TextEditingController(
    text: asset?.weightGrams.toString() ?? '0',
  );
  final purchasePrice = TextEditingController(
    text: asset?.purchasePrice.toString() ?? '0',
  );
  final currentPricePerGram = TextEditingController(
    text: asset?.currentPricePerGram.toString() ?? '0',
  );
  final notes = TextEditingController(text: asset?.notes);
  var category = asset?.category ?? 'Edelmetall';
  var metalType = asset?.metalType ?? 'Gold';
  DateTime? purchaseDate = asset?.purchaseDate;
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          asset == null
              ? 'Wertgegenstand hinzufügen'
              : 'Wertgegenstand bearbeiten',
        ),
        content: SizedBox(
          width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 520),
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Bezeichnung'),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                    items:
                        const [
                              'Edelmetall',
                              'Schmuck',
                              'Kunst',
                              'Sammlerstück',
                              'Sonstiges',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setDialogState(() => category = value ?? category),
                  ),
                  if (category == 'Edelmetall') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: metalType,
                      decoration: const InputDecoration(
                        labelText: 'Edelmetall',
                      ),
                      items: const ['Gold', 'Silber', 'Platin']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => metalType = value ?? metalType),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final field in [
                    (quantity, 'Menge', ''),
                    (weightGrams, 'Gewicht', 'g'),
                    (purchasePrice, 'Kaufpreis gesamt', '€'),
                    (currentPricePerGram, 'Aktueller Kurs pro Gramm', '€/g'),
                  ]) ...[
                    TextFormField(
                      controller: field.$1,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: field.$2,
                        suffixText: field.$3,
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );
                        return parsed == null || parsed < 0
                            ? 'Ungültiger Wert'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          initialDate: purchaseDate ?? DateTime.now(),
                        );
                        if (selected != null) {
                          setDialogState(() => purchaseDate = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        purchaseDate == null
                            ? 'Kaufdatum angeben'
                            : 'Kaufdatum: ${DateFormat('dd.MM.yyyy').format(purchaseDate!)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(labelText: 'Notizen'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
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
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      final now = DateTime.now().toUtc();
      double number(TextEditingController value) =>
          double.parse(value.text.replaceAll(',', '.'));
      await ref
          .read(databaseProvider)
          .savePhysicalAsset(
            PhysicalAssetsCompanion.insert(
              id: asset?.id ?? const Uuid().v4(),
              userId: userId,
              accountId: Value(accountId),
              name: name.text.trim(),
              category: Value(category),
              metalType: Value(category == 'Edelmetall' ? metalType : ''),
              quantity: Value(number(quantity)),
              weightGrams: Value(number(weightGrams)),
              purchaseDate: Value(purchaseDate),
              purchasePrice: Value(number(purchasePrice)),
              currentValue: Value(
                number(weightGrams) * number(currentPricePerGram),
              ),
              currentPricePerGram: Value(number(currentPricePerGram)),
              notes: Value(notes.text.trim()),
              createdAt: asset?.createdAt ?? now,
              updatedAt: now,
            ),
          );
    }
  }
  for (final controller in [
    name,
    quantity,
    weightGrams,
    purchasePrice,
    currentPricePerGram,
    notes,
  ]) {
    controller.dispose();
  }
}

class _InvestmentTile extends ConsumerWidget {
  const _InvestmentTile({required this.item, required this.purchaseCount});
  final Investment item;
  final int purchaseCount;

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
          '${item.assetType} · ${item.quantity.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')} Stück${item.broker.isEmpty ? '' : ' · ${item.broker}'}',
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
                } else if (value == 'sell') {
                  await _showInvestmentSaleDialog(context, ref, item);
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
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'history',
                  child: Text('Details & Kaufhistorie'),
                ),
                PopupMenuItem(
                  value: 'edit',
                  enabled: purchaseCount <= 1,
                  child: Text(
                    purchaseCount <= 1
                        ? 'Bearbeiten'
                        : 'Gesamtposition nicht bearbeitbar',
                  ),
                ),
                const PopupMenuItem(value: 'sell', child: Text('Verkaufen')),
                const PopupMenuItem(value: 'delete', child: Text('Löschen')),
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
            tooltip: sorted.length > 1
                ? 'Bei mehreren Käufen bitte einzelne Käufe bearbeiten'
                : 'Position bearbeiten',
            onPressed: sorted.length > 1
                ? null
                : () {
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
                    investment.quantity.toStringAsFixed(2) + ' Stück',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.calculate_outlined, size: 18),
                  label: Text('Ø Kaufkurs ${money(investment.purchasePrice)}'),
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
                            purchase.quantity.toStringAsFixed(2) +
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                money(
                                  purchase.quantity * purchase.purchasePrice +
                                      purchase.fees,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await _showPurchaseEditor(
                                      context,
                                      ref,
                                      purchase,
                                    );
                                  } else if (value == 'delete' &&
                                      await confirmDelete(
                                        context,
                                        title: 'Diesen Kauf löschen?',
                                        message:
                                            'Nur dieser Eintrag wird aus der Kaufhistorie entfernt.',
                                      )) {
                                    final userId = ref.read(
                                      currentUserIdProvider,
                                    );
                                    if (userId != null) {
                                      await ref
                                          .read(databaseProvider)
                                          .deleteInvestmentPurchase(
                                            purchase.id,
                                            userId,
                                          );
                                    }
                                    if (context.mounted) Navigator.pop(context);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Kauf bearbeiten'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Kauf löschen'),
                                  ),
                                ],
                              ),
                            ],
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
  String? accountId,
}) async {
  final resolvedAccountId = investment?.accountId ?? accountId ?? '';
  if (resolvedAccountId.isEmpty) return;
  final investmentPurchases =
      (ref.read(investmentPurchasesProvider).valueOrNull ??
              const <InvestmentPurchase>[])
          .where((row) => row.investmentId == investment?.id)
          .toList();
  if (investment != null && investmentPurchases.length > 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Diese Position hat mehrere Käufe. Bitte bearbeite den gewünschten Kauf in der Kaufhistorie.',
        ),
      ),
    );
    return;
  }
  final masterData =
      ref.read(masterDataProvider).valueOrNull ?? const <MasterDataData>[];
  final existingItems =
      (ref.read(investmentsProvider).valueOrNull ?? const <Investment>[])
          .where((item) => item.accountId == resolvedAccountId)
          .toList();
  final stockMasters =
      ref.read(stockMastersProvider).valueOrNull ?? const <StockMaster>[];
  final countryTaxRates =
      ref.read(countryTaxRatesProvider).valueOrNull ?? const <CountryTaxRate>[];
  final defaultFee =
      ref.read(preferencesProvider).valueOrNull?.defaultInvestmentFee ?? 0;
  final result = await showDialog<InvestmentsCompanion>(
    context: context,
    builder: (_) => _InvestmentEditor(
      investment: investment,
      masterData: masterData,
      existingItems: existingItems,
      stockMasters: stockMasters,
      countryTaxRates: countryTaxRates,
      accountId: resolvedAccountId,
      defaultFee: defaultFee,
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
        if (investment != null && investmentPurchases.length == 1) {
          await database.updateInvestmentPurchase(
            userId: userId,
            purchaseId: investmentPurchases.single.id,
            purchaseDate: result.purchaseDate.value,
            purchasePrice: result.purchasePrice.value,
            quantity: result.quantity.value,
            fees: result.fees.value,
          );
        }
      } else {
        final addedQuantity = result.quantity.value;
        final totalQuantity =
            ((duplicate.quantity + addedQuantity) * 100).round() / 100;
        final averagePrice = totalQuantity == 0
            ? 0.0
            : (duplicate.quantity * duplicate.purchasePrice +
                      addedQuantity * result.purchasePrice.value) /
                  totalQuantity;
        await database.saveInvestment(
          InvestmentsCompanion.insert(
            id: duplicate.id,
            userId: duplicate.userId,
            stockId: result.stockId,
            accountId: result.accountId,
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
            dividendCurrency: result.dividendCurrency,
            dividendExchangeRate: result.dividendExchangeRate,
            dividendWithholdingTaxRate: result.dividendWithholdingTaxRate,
            dividendFrequency: result.dividendFrequency,
            dividendStartMonth: result.dividendStartMonth,
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
    required this.stockMasters,
    required this.countryTaxRates,
    required this.accountId,
    required this.defaultFee,
    this.investment,
  });
  final Investment? investment;
  final List<MasterDataData> masterData;
  final List<Investment> existingItems;
  final List<StockMaster> stockMasters;
  final List<CountryTaxRate> countryTaxRates;
  final String accountId;
  final double defaultFee;
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
    text: widget.investment?.fees.toString() ?? widget.defaultFee.toString(),
  );
  late final _currentPrice = TextEditingController(
    text: widget.investment?.currentPrice.toString(),
  );
  late final _dividend = TextEditingController(
    text: widget.investment?.annualDividend.toString() ?? '0',
  );
  late final _dividendCurrency = TextEditingController(
    text: widget.investment?.dividendCurrency ?? 'EUR',
  );
  late final _dividendExchangeRate = TextEditingController(
    text: widget.investment?.dividendExchangeRate.toString() ?? '1',
  );
  late final _dividendWithholdingTax = TextEditingController(
    text: widget.investment?.dividendWithholdingTaxRate.toString() ?? '0',
  );
  late final _notes = TextEditingController(text: widget.investment?.notes);
  late String _type = widget.investment?.assetType ?? 'Aktie';
  late String _frequency = widget.investment?.dividendFrequency ?? 'jährlich';
  late int _startMonth = widget.investment?.dividendStartMonth ?? 1;
  late DateTime _date = widget.investment?.purchaseDate ?? DateTime.now();
  String? _selectedExistingId;
  late String? _selectedStockId = widget.investment?.stockId;

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
      _dividendCurrency,
      _dividendExchangeRate,
      _dividendWithholdingTax,
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
                if (widget.investment == null) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStockId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Aktie aus Stammdaten',
                      prefixIcon: Icon(Icons.search_rounded),
                      helperText:
                          'Suche über den Namen – keine Ticker-Eingabe nötig.',
                    ),
                    items: widget.stockMasters
                        .map(
                          (stock) => DropdownMenuItem(
                            value: stock.id,
                            child: Text(
                              '${stock.name} · ${stock.symbol}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null
                        ? 'Bitte eine Aktie aus den Stammdaten wählen.'
                        : null,
                    onChanged: _selectStock,
                  ),
                  if (widget.stockMasters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Ein Administrator muss zuerst eine Aktie im zentralen Katalog anlegen.',
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
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
                  _field(_name, 'Name', required: true, readOnly: true),
                  _field(_symbol, 'Symbol', readOnly: true),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(_isin, 'ISIN', readOnly: true),
                  _field(_wkn, 'WKN', readOnly: true),
                ]),
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
                              'Hebelprodukt',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => _type = v ?? 'Aktie',
                  ),
                  _field(_broker, 'Broker', readOnly: true),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _masterField(
                    _country,
                    'Land',
                    'country',
                    onSelected: _countryChanged,
                  ),
                  _field(_sector, 'Branche', readOnly: true),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
                  _field(
                    _purchasePrice,
                    'Kaufkurs',
                    number: true,
                    required: true,
                  ),
                  _field(
                    _quantity,
                    'Stückzahl',
                    number: true,
                    required: true,
                    decimalPlaces: 2,
                  ),
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
                  _field(
                    _dividendCurrency,
                    'Dividendenwährung',
                    required: true,
                    readOnly: true,
                  ),
                  _field(
                    _dividendExchangeRate,
                    'Kurs zur Standardwährung',
                    number: true,
                    required: true,
                    minimum: 0.000001,
                  ),
                  _field(
                    _dividendWithholdingTax,
                    'Quellensteuer',
                    number: true,
                    required: true,
                    readOnly: true,
                    suffixText: '%',
                    maximum: 100,
                  ),
                ]),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Beispiel: 1 USD × 0,92 Kurs × 85 % nach 15 % Quellensteuer.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFields([
                  _readOnlyValue('Auszahlungsrhythmus', _frequency),
                  _readOnlyValue(
                    'Startmonat des Rhythmus',
                    _investmentMonthNames[_startMonth - 1],
                  ),
                ]),
                const SizedBox(height: 12),
                _responsiveFields([
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
    bool readOnly = false,
    String? suffixText,
    double? minimum,
    double? maximum,
    int? decimalPlaces,
  }) => TextFormField(
    controller: controller,
    readOnly: readOnly,
    maxLines: lines,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : null,
    inputFormatters: decimalPlaces == null
        ? null
        : [
            FilteringTextInputFormatter.allow(
              RegExp('^\\d*([,.]\\d{0,$decimalPlaces})?'),
            ),
          ],
    mouseCursor: readOnly ? SystemMouseCursors.basic : null,
    enableInteractiveSelection: !readOnly,
    style: readOnly
        ? TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          )
        : null,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffixText,
      prefixIcon: Icon(
        readOnly ? Icons.lock_outline_rounded : Icons.edit_outlined,
        size: 18,
      ),
      filled: true,
      fillColor: readOnly
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: readOnly
              ? Theme.of(context).dividerColor.withValues(alpha: .35)
              : Theme.of(context).colorScheme.primary.withValues(alpha: .55),
          width: readOnly ? 1 : 1.4,
        ),
      ),
    ),
    validator: (value) {
      if (required && (value?.trim().isEmpty ?? true)) return 'Pflichtfeld';
      if (number && _number(value) == null) return 'Ungültige Zahl';
      if (number && (_number(value) ?? -1) < 0) return 'Muss positiv sein';
      if (minimum != null &&
          (_number(value) ?? double.negativeInfinity) < minimum) {
        return 'Muss mindestens $minimum sein';
      }
      if (maximum != null && (_number(value) ?? double.infinity) > maximum) {
        return 'Darf höchstens $maximum sein';
      }
      return null;
    },
  );

  Widget _readOnlyValue(String label, String value) => TextFormField(
    key: ValueKey('$label:$value'),
    initialValue: value,
    readOnly: true,
    enableInteractiveSelection: false,
    mouseCursor: SystemMouseCursors.basic,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    ),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
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
    String kind, {
    ValueChanged<String>? onSelected,
  }) => TextFormField(
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
          onSelected?.call(value);
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
      _dividendCurrency.text = item.dividendCurrency;
      _dividendExchangeRate.text = item.dividendExchangeRate.toString();
      _dividendWithholdingTax.text = item.dividendWithholdingTaxRate.toString();
      _notes.text = item.notes;
      _type = item.assetType;
      _frequency = item.dividendFrequency;
      _startMonth = item.dividendStartMonth;
      _purchasePrice.clear();
      _quantity.clear();
      _fees.text = '0';
    });
  }

  void _selectStock(String? id) {
    if (id == null) return;
    final stock = widget.stockMasters.firstWhere((item) => item.id == id);
    setState(() {
      _selectedStockId = id;
      _name.text = stock.name;
      _symbol.text = stock.symbol;
      _isin.text = stock.isin;
      _country.text = stock.country;
      _sector.text = stock.sector;
      _wkn.text = stock.wkn;
      _broker.text = stock.broker;
      _dividendCurrency.text = stock.dividendCurrency.toUpperCase();
      _frequency = stock.dividendFrequency;
      _startMonth = stock.dividendStartMonth;
      _dividendExchangeRate.text = stock.dividendCurrency.toUpperCase() == 'EUR'
          ? '1'
          : _dividendExchangeRate.text;
      _dividendWithholdingTax.text = _isUnitedStates(stock.country)
          ? _taxRateForCountry(stock.country, fallback: 15).toString()
          : _taxRateForCountry(stock.country, fallback: 0).toString();
    });
  }

  double? _number(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.'));

  void _countryChanged(String value) {
    setState(() {
      _dividendWithholdingTax.text = _taxRateForCountry(
        value,
        fallback: _isUnitedStates(value) ? 15 : 0,
      ).toStringAsFixed(2);
    });
  }

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
        stockId: Value(_selectedStockId),
        accountId: Value(widget.accountId),
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
        quantity: ((_number(_quantity.text) ?? 0) * 100).round() / 100,
        fees: Value(_number(_fees.text) ?? 0),
        currentPrice: _number(_currentPrice.text) ?? 0,
        annualDividend: Value(_number(_dividend.text) ?? 0),
        dividendCurrency: Value(_dividendCurrency.text.trim().toUpperCase()),
        dividendExchangeRate: Value(_number(_dividendExchangeRate.text) ?? 1),
        dividendWithholdingTaxRate: Value(
          (_number(_dividendWithholdingTax.text) ?? 0).clamp(0, 100),
        ),
        dividendFrequency: Value(_frequency),
        dividendStartMonth: Value(_startMonth),
        notes: Value(_notes.text.trim()),
        createdAt: widget.investment?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  bool _isUnitedStates(String country) {
    final normalized = country.trim().toLowerCase();
    return normalized == 'usa' ||
        normalized == 'us' ||
        normalized.contains('vereinigte staat') ||
        normalized.contains('united states');
  }

  double _taxRateForCountry(String country, {required double fallback}) {
    final normalized = country.trim().toLowerCase();
    return widget.countryTaxRates
            .where((item) => item.country.trim().toLowerCase() == normalized)
            .firstOrNull
            ?.withholdingTaxRate ??
        fallback;
  }
}

Future<void> _showInvestmentSaleDialog(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) async {
  final quantity = TextEditingController(text: investment.quantity.toString());
  final price = TextEditingController(text: investment.currentPrice.toString());
  final fee = TextEditingController(
    text: (ref.read(preferencesProvider).valueOrNull?.defaultInvestmentFee ?? 0)
        .toString(),
  );
  final key = GlobalKey<FormState>();
  var date = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${investment.name} verkaufen'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantity,
                  decoration: InputDecoration(
                    labelText: 'Stückzahl',
                    helperText:
                        'Verfügbar: ${investment.quantity.toStringAsFixed(4)} Stück',
                    suffixIcon: TextButton(
                      onPressed: () =>
                          quantity.text = investment.quantity.toString(),
                      child: const Text('Alles'),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = _parseNumber(value);
                    if (parsed == null || parsed <= 0) return 'Ungültige Menge';
                    if (parsed > investment.quantity)
                      return 'Mehr als verfügbar';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufskurs je Stück',
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fee,
                  decoration: const InputDecoration(
                    labelText: 'Gebühren',
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      firstDate: investment.purchaseDate,
                      lastDate: DateTime.now(),
                      initialDate: date,
                    );
                    if (selected != null) setState(() => date = selected);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(DateFormat('dd.MM.yyyy').format(date)),
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
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Verkauf buchen'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref
          .read(databaseProvider)
          .sellInvestment(
            userId: userId,
            investmentId: investment.id,
            quantity: _parseNumber(quantity.text)!,
            pricePerUnit: _parseNumber(price.text)!,
            fees: _parseNumber(fee.text)!,
            soldAt: date,
          );
    }
  }
  quantity.dispose();
  price.dispose();
  fee.dispose();
}

Future<void> _showPhysicalSaleDialog(
  BuildContext context,
  WidgetRef ref,
  PhysicalAsset asset,
) async {
  final grams = TextEditingController(text: asset.weightGrams.toString());
  final price = TextEditingController(
    text: asset.currentPricePerGram.toString(),
  );
  final fee = TextEditingController(text: '0');
  final key = GlobalKey<FormState>();
  var date = DateTime.now();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${asset.name} verkaufen'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: grams,
                  decoration: InputDecoration(
                    labelText: 'Gewicht',
                    suffixText: 'g',
                    helperText:
                        'Verfügbar: ${asset.weightGrams.toStringAsFixed(2)} g',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = _parseNumber(value);
                    if (parsed == null || parsed <= 0)
                      return 'Ungültiges Gewicht';
                    if (parsed > asset.weightGrams) return 'Mehr als verfügbar';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufskurs pro Gramm',
                    suffixText: '€/g',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fee,
                  decoration: const InputDecoration(
                    labelText: 'Gebühren',
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      firstDate: asset.purchaseDate ?? DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDate: date,
                    );
                    if (selected != null) setState(() => date = selected);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(DateFormat('dd.MM.yyyy').format(date)),
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
            onPressed: () {
              if (key.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Verkauf buchen'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref
          .read(databaseProvider)
          .sellPhysicalAsset(
            userId: userId,
            assetId: asset.id,
            grams: _parseNumber(grams.text)!,
            pricePerGram: _parseNumber(price.text)!,
            fees: _parseNumber(fee.text)!,
            soldAt: date,
          );
    }
  }
  grams.dispose();
  price.dispose();
  fee.dispose();
}

Future<void> _showPurchaseEditor(
  BuildContext context,
  WidgetRef ref,
  InvestmentPurchase purchase,
) async {
  final quantity = TextEditingController(text: purchase.quantity.toString());
  final price = TextEditingController(text: purchase.purchasePrice.toString());
  final fee = TextEditingController(text: purchase.fees.toString());
  final key = GlobalKey<FormState>();
  var date = purchase.purchaseDate;
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Kauf bearbeiten'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantity,
                decoration: const InputDecoration(labelText: 'Stückzahl'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => (_parseNumber(value) ?? 0) <= 0
                    ? 'Muss größer als 0 sein'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: price,
                decoration: const InputDecoration(
                  labelText: 'Kaufkurs',
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveNumberValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fee,
                decoration: const InputDecoration(
                  labelText: 'Gebühren',
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveNumberValidator,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    initialDate: date,
                  );
                  if (selected != null) setState(() => date = selected);
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(DateFormat('dd.MM.yyyy').format(date)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState?.validate() ?? false)
                Navigator.pop(dialogContext, true);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref
          .read(databaseProvider)
          .updateInvestmentPurchase(
            userId: userId,
            purchaseId: purchase.id,
            purchaseDate: date,
            purchasePrice: _parseNumber(price.text)!,
            quantity: _parseNumber(quantity.text)!,
            fees: _parseNumber(fee.text)!,
          );
    }
    if (context.mounted) Navigator.pop(context);
  }
  quantity.dispose();
  price.dispose();
  fee.dispose();
}

Future<void> _showPortfolioActivity(
  BuildContext context, {
  required List<PortfolioSale> sales,
  required List<PortfolioAuditLog> auditLogs,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => DefaultTabController(
    length: 2,
    child: AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      title: const Text('Portfolio-Aktivitäten'),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(300, 760),
        height: (MediaQuery.sizeOf(context).height - 220).clamp(320, 620),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Verkäufe'),
                Tab(text: 'Gelöscht'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  sales.isEmpty
                      ? const Center(child: Text('Noch keine Verkäufe.'))
                      : ListView.separated(
                          itemCount: sales.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final sale = sales[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  sale.assetKind == 'physical'
                                      ? Icons.diamond_outlined
                                      : Icons.trending_down_rounded,
                                ),
                              ),
                              title: Text(sale.assetName),
                              subtitle: Text(
                                '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                                '${sale.quantity.toStringAsFixed(2)} ${sale.unit} · '
                                'Gewinn ${money(sale.realizedGain)}'
                                '${sale.taxPaid > 0 ? ' · Steuer ${money(sale.taxPaid)}' : ''}',
                              ),
                              trailing: Text(
                                money(sale.proceeds),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          },
                        ),
                  auditLogs.isEmpty
                      ? const Center(child: Text('Noch keine Löschvorgänge.'))
                      : ListView.separated(
                          itemCount: auditLogs.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final log = auditLogs[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.delete_outline_rounded),
                              ),
                              title: Text(log.displayName),
                              subtitle: Text(
                                '${DateFormat('dd.MM.yyyy · HH:mm').format(log.occurredAt.toLocal())}'
                                '${log.details.isEmpty ? '' : ' · ${log.details}'}',
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Schließen'),
        ),
      ],
    ),
  ),
);

double? _parseNumber(String? value) =>
    double.tryParse((value ?? '').replaceAll(',', '.'));

String? _positiveNumberValidator(String? value) {
  final parsed = _parseNumber(value);
  return parsed == null || parsed < 0 ? 'Ungültiger Wert' : null;
}

const _investmentMonthNames = [
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
