import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/account_balance_math.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/currencies.dart';
import 'package:wealthflow_core/finance/portfolio_master_data.dart';
import 'package:wealthflow_core/finance/portfolio_tax_summary.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

part 'investments/currency_dialogs.dart';
part 'investments/tax_allowance.dart';
part 'investments/physical_assets.dart';
part 'investments/positions.dart';
part 'investments/investment_editor.dart';
part 'investments/transactions.dart';

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
    ref.watch(currencyConverterProvider);
    final asyncItems = ref.watch(investmentsProvider);
    final accounts =
        ref.watch(accountsProvider).valueOrNull ?? const <Account>[];
    final entries =
        ref.watch(ledgerEntriesProvider).valueOrNull ?? const <LedgerEntry>[];
    final balanceHistories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
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
    final configuredAssetTypes =
        ref.watch(assetClassesProvider).valueOrNull ??
        const <AssetClassesData>[];
    final assetTypeNames = configuredAssetTypes.isEmpty
        ? const [
            'Aktie',
            'ETF',
            'Kryptowährung',
            'Anleihe',
            'Fonds',
            'Hebelprodukt',
          ]
        : configuredAssetTypes.map((item) => item.name).toList();
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
                title: 'Depot',
                actionInline: true,
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: selectedAccountId == null
                          ? null
                          : () => _showAddPortfolioItem(
                              context,
                              ref,
                              accountId: selectedAccountId,
                            ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Anlage'),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Weitere Aktionen',
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (value) => switch (value) {
                        'activity' => _showPortfolioActivity(
                          context,
                          ref: ref,
                          sales: sales,
                          auditLogs: auditLogs,
                        ),
                        'fee' when preference != null =>
                          _editDefaultInvestmentFee(context, ref, preference),
                        'rates' => _showExchangeRates(context, ref),
                        'converter' => _showCurrencyConverter(context, ref),
                        _ => Future<void>.value(),
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'activity',
                          child: ListTile(
                            leading: Icon(Icons.receipt_long_outlined),
                            title: Text('Verkäufe & Protokoll'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'fee',
                          child: ListTile(
                            leading: Icon(Icons.request_quote_outlined),
                            title: Text('Standardgebühr'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rates',
                          child: ListTile(
                            leading: Icon(Icons.currency_exchange_rounded),
                            title: Text('Wechselkurse'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'converter',
                          child: ListTile(
                            leading: Icon(Icons.calculate_outlined),
                            title: Text('Währungsrechner'),
                          ),
                        ),
                      ],
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
                    child: SearchableDropdownButtonFormField<String>(
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
                                '${account.label} · ${money(account.balance, currency: account.currency)} Cash',
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
                    child: SearchableDropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Anlageklasse',
                      ),
                      items:
                          <String>{'Alle', ...assetTypeNames, 'Wertgegenstände'}
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
                    child: SearchableDropdownButtonFormField<String>(
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
                  error: (error, _) => LoadErrorMessage(
                    'Portfolio konnte nicht geladen werden',
                    error: error,
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
                    final visibleAssets = accountAssets.where((asset) {
                      final matchesType =
                          _type == 'Alle' || _type == 'Wertgegenstände';
                      final text =
                          '${asset.name} ${asset.category} ${asset.metalType}'
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
                          onPressed: () => _showAddPortfolioItem(
                            context,
                            ref,
                            accountId: selectedAccountId,
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Erste Anlage'),
                        ),
                      );
                    }
                    final securitiesValue = items.fold<double>(
                      0,
                      (sum, item) => sum + _value(item),
                    );
                    final physicalValue = visibleAssets.fold<double>(
                      0,
                      (sum, item) =>
                          sum + item.weightGrams * item.currentPricePerGram,
                    );
                    final selectedAccount = accounts
                        .where((account) => account.id == selectedAccountId)
                        .firstOrNull;
                    final cash = selectedAccount == null
                        ? 0.0
                        : accountBalanceAt(
                            account: selectedAccount,
                            date: DateTime.now(),
                            histories: balanceHistories,
                            entries: entries,
                            investments: allItems,
                            purchases: purchases,
                            sales: sales,
                          );
                    final filterActive = _type != 'Alle' || _query.isNotEmpty;
                    final visibleCash = filterActive ? 0.0 : cash;
                    final portfolio =
                        securitiesValue + physicalValue + visibleCash;
                    final securitiesCost = items.fold<double>(
                      0,
                      (sum, item) => sum + _cost(item),
                    );
                    final unrealizedStockGain =
                        securitiesValue - securitiesCost;
                    final taxSummary = calculatePortfolioTaxYear(
                      year: DateTime.now().year,
                      allowance: preference?.taxAllowance ?? 1000,
                      investments: allItems,
                      schedules: schedules,
                      sales: sales,
                      purchases: purchases,
                      includePhysicalAssets:
                          preference?.includePhysicalAssetsInTaxAllowance ??
                          false,
                      through: DateTime.now(),
                    );
                    final taxEvents = calculatePortfolioTaxEvents(
                      year: DateTime.now().year,
                      allowance: preference?.taxAllowance ?? 1000,
                      investments: allItems,
                      schedules: schedules,
                      sales: sales,
                      purchases: purchases,
                      includePhysicalAssets:
                          preference?.includePhysicalAssetsInTaxAllowance ??
                          false,
                      through: DateTime.now(),
                    );
                    return ListView(
                      children: [
                        _PortfolioSummary(
                          value: portfolio,
                          securities: securitiesValue,
                          physical: physicalValue,
                          gain: unrealizedStockGain,
                          performanceBase: securitiesCost,
                          cash: visibleCash,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _TaxAllowanceTile(
                            preference: preference,
                            summary: taxSummary,
                            events: taxEvents,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SectionTitle('Positionen · ${items.length}'),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Keine Position passt zum Filter.'),
                          )
                        else
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (final (index, item) in items.indexed) ...[
                                  if (index > 0)
                                    const Divider(height: 1, indent: 68),
                                  _InvestmentTile(
                                    item: item,
                                    purchaseCount: purchases
                                        .where(
                                          (row) => row.investmentId == item.id,
                                        )
                                        .length,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Wertgegenstände',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (preference != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Steuerlich einbeziehen',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Switch.adaptive(
                                value: preference
                                    .includePhysicalAssetsInTaxAllowance,
                                onChanged: (value) => ref
                                    .read(databaseProvider)
                                    .savePreferences(
                                      preference
                                          .toCompanion(false)
                                          .copyWith(
                                            includePhysicalAssetsInTaxAllowance:
                                                Value(value),
                                            updatedAt: Value(
                                              DateTime.now().toUtc(),
                                            ),
                                          ),
                                    ),
                              ),
                            ],
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
                        if (visibleAssets.isEmpty)
                          const Text('Noch keine physischen Werte erfasst.')
                        else
                          for (final asset in visibleAssets) ...[
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

  double _value(Investment item) =>
      ref.read(currencyConverterProvider).investmentValue(item);
  double _cost(Investment item) => ref
      .read(currencyConverterProvider)
      .toBase(
        item.quantity * item.purchasePrice + item.fees,
        item.instrumentCurrency.isEmpty
            ? moneyCurrency
            : item.instrumentCurrency,
      );
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

/// Depot value and the gain since purchase on top, as on the overview.
class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.value,
    required this.securities,
    required this.physical,
    required this.gain,
    required this.performanceBase,
    required this.cash,
  });
  final double value;
  final double securities;
  final double physical;
  final double gain;
  final double performanceBase;
  final double cash;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final positive = gain >= 0;
    final percent = performanceBase == 0 ? null : gain / performanceBase * 100;
    Widget figure(String label, double amount) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.muted)),
        const SizedBox(height: 2),
        Text(
          money(amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Depotwert'),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                money(value),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                  letterSpacing: -.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Tooltip(
              message:
                  'Gewinn oder Verlust der gehaltenen Wertpapiere seit Kauf, ohne Verkäufe und Wertgegenstände.',
              child: Text(
                '${signedMoney(gain, income: positive)}'
                '${percent == null ? '' : ' (${positive ? '+' : '−'}${percent.abs().toStringAsFixed(1).replaceAll('.', ',')} %)'}'
                ' seit Kauf',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.amount(income: positive),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 14),
            Wrap(
              spacing: 32,
              runSpacing: 12,
              children: [
                figure('Wertpapiere', securities),
                if (physical > 0) figure('Wertgegenstände', physical),
                figure('Cash', cash),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
