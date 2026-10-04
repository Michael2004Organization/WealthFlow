import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/account_balance_math.dart';
import '../../core/finance/currencies.dart';
import '../../core/finance/portfolio_master_data.dart';
import '../../core/finance/portfolio_tax_summary.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/finance/amount_input.dart';

final _portfolioActionButtonStyle = FilledButton.styleFrom(
  backgroundColor: const Color(0xFFADB6F7),
  foregroundColor: const Color(0xFF171927),
);

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
    final balanceHistories =
        ref.watch(accountBalanceHistoriesProvider).valueOrNull ??
        const <AccountBalanceHistory>[];
    final physicalAssets =
        ref.watch(physicalAssetsProvider).valueOrNull ??
        const <PhysicalAsset>[];
    final preference = ref.watch(preferencesProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider);
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
                title: 'Portfolio',
                subtitle: 'Positionen, Performance und Erträge im Blick.',
                action: _PortfolioHeaderActions(
                  children: [
                    FilledButton.tonalIcon(
                      style: _portfolioActionButtonStyle,
                      onPressed: selectedAccountId == null
                          ? null
                          : () => _showAddPortfolioItem(
                              context,
                              ref,
                              accountId: selectedAccountId,
                            ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Anlage hinzufügen'),
                    ),
                    FilledButton.tonalIcon(
                      style: _portfolioActionButtonStyle,
                      onPressed: () => _showPortfolioActivity(
                        context,
                        ref: ref,
                        sales: sales,
                        auditLogs: auditLogs,
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Verkäufe & Protokoll'),
                    ),
                    Tooltip(
                      message: 'Standardgebühr für neue Käufe',
                      child: FilledButton.tonalIcon(
                        style: _portfolioActionButtonStyle,
                        onPressed: preference == null
                            ? null
                            : () => _editDefaultInvestmentFee(
                                context,
                                ref,
                                preference,
                              ),
                        icon: const Icon(Icons.request_quote_outlined),
                        label: const Text('Gebühr'),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      style: _portfolioActionButtonStyle,
                      onPressed: () =>
                          _showExchangeRates(context, ref, isAdmin: isAdmin),
                      icon: const Icon(Icons.currency_exchange_rounded),
                      label: const Text('Wechselkurse'),
                    ),
                    FilledButton.tonalIcon(
                      style: _portfolioActionButtonStyle,
                      onPressed: () => _showCurrencyConverter(context, ref),
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Währungsrechner'),
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
                          investedValue: securitiesValue + physicalValue,
                          gain: unrealizedStockGain,
                          performanceBase: securitiesCost,
                          positions: items.length + visibleAssets.length,
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

class _PortfolioHeaderActions extends StatelessWidget {
  const _PortfolioHeaderActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 520) {
      return SizedBox(
        width: MediaQuery.sizeOf(context).width - 56,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      );
    }
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

Future<void> _showExchangeRates(
  BuildContext context,
  WidgetRef ref, {
  required bool isAdmin,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final database = ref.read(databaseProvider);
  final countries = await database.availableCountries();
  final rates =
      ref.read(countryTaxRatesProvider).valueOrNull ?? const <CountryTaxRate>[];
  final apiKey = await ref
      .read(secureSessionStoreProvider)
      .readExchangeApiKey(userId);
  final hasApiKey = apiKey?.trim().isNotEmpty ?? false;
  final baseCurrency =
      ref.read(preferencesProvider).valueOrNull?.currency ?? 'EUR';
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      title: const Text('Wechselkurse nach Steuerland'),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 64).clamp(300, 780),
        height: (MediaQuery.sizeOf(context).height - 240).clamp(300, 620),
        child: countries.isEmpty
            ? const Center(
                child: Text('Noch keine Steuerländer in Stammdaten vorhanden.'),
              )
            : ListView.separated(
                itemCount: countries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final stored = rates
                      .where(
                        (item) =>
                            item.country.trim().toLowerCase() ==
                            country.trim().toLowerCase(),
                      )
                      .firstOrNull;
                  return _ExchangeRateEditorRow(
                    country: country,
                    baseCurrency: baseCurrency,
                    initialCurrency: stored?.currency ?? baseCurrency,
                    initialRate: stored?.exchangeRate ?? 1,
                    allowManual: stored?.allowManualExchangeRate ?? true,
                    hasApiKey: hasApiKey,
                    isAdmin: isAdmin,
                    onSave:
                        ({
                          required currency,
                          required exchangeRate,
                          required allowManual,
                        }) => database.saveCountryExchangeRate(
                          actorUserId: userId,
                          country: country,
                          currency: currency,
                          exchangeRate: exchangeRate,
                          allowManualExchangeRate: isAdmin ? allowManual : null,
                          apiKeyConfigured: hasApiKey,
                        ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Schließen'),
        ),
      ],
    ),
  );
}

Future<void> _showCurrencyConverter(BuildContext context, WidgetRef ref) async {
  final baseCurrency =
      ref.read(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
      'EUR';
  final configuredRates =
      ref.read(countryTaxRatesProvider).valueOrNull ?? const <CountryTaxRate>[];
  final rates = <String, double>{baseCurrency: 1};
  for (final row in configuredRates) {
    if (row.exchangeRate > 0) {
      rates[row.currency.toUpperCase()] = row.exchangeRate;
    }
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) =>
        _CurrencyConverterDialog(baseCurrency: baseCurrency, rates: rates),
  );
}

class _CurrencyConverterDialog extends StatefulWidget {
  const _CurrencyConverterDialog({
    required this.baseCurrency,
    required this.rates,
  });

  final String baseCurrency;
  final Map<String, double> rates;

  @override
  State<_CurrencyConverterDialog> createState() =>
      _CurrencyConverterDialogState();
}

class _CurrencyConverterDialogState extends State<_CurrencyConverterDialog> {
  final _left = TextEditingController(text: '1');
  final _right = TextEditingController();
  late final List<String> _currencies = widget.rates.keys.toList()..sort();
  late String _leftCurrency = widget.baseCurrency;
  late String _rightCurrency = _currencies.firstWhere(
    (value) => value != widget.baseCurrency,
    orElse: () => widget.baseCurrency,
  );
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _convert(fromLeft: true);
  }

  @override
  void dispose() {
    _left.dispose();
    _right.dispose();
    super.dispose();
  }

  void _convert({required bool fromLeft}) {
    if (_updating) return;
    _updating = true;
    final source = fromLeft ? _left : _right;
    final target = fromLeft ? _right : _left;
    final sourceCurrency = fromLeft ? _leftCurrency : _rightCurrency;
    final targetCurrency = fromLeft ? _rightCurrency : _leftCurrency;
    final amount = _parseNumber(source.text);
    final sourceRate = widget.rates[sourceCurrency] ?? 1;
    final targetRate = widget.rates[targetCurrency] ?? 1;
    target.text = amount == null
        ? ''
        : (amount * sourceRate / targetRate).toStringAsFixed(2);
    _updating = false;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Währungsrechner'),
    content: SizedBox(
      width: (MediaQuery.sizeOf(context).width - 64).clamp(280, 620),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _converterRow(
            controller: _left,
            currency: _leftCurrency,
            onAmountChanged: (_) => _convert(fromLeft: true),
            onCurrencyChanged: (value) {
              if (value == null) return;
              setState(() => _leftCurrency = value);
              _convert(fromLeft: true);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(Icons.swap_vert_rounded),
          ),
          _converterRow(
            controller: _right,
            currency: _rightCurrency,
            onAmountChanged: (_) => _convert(fromLeft: false),
            onCurrencyChanged: (value) {
              if (value == null) return;
              setState(() => _rightCurrency = value);
              _convert(fromLeft: true);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Umrechnung über ${widget.baseCurrency}; verwendet werden die hinterlegten Wechselkurse.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fertig'),
      ),
    ],
  );

  Widget _converterRow({
    required TextEditingController controller,
    required String currency,
    required ValueChanged<String> onAmountChanged,
    required ValueChanged<String?> onCurrencyChanged,
  }) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onAmountChanged,
          decoration: const InputDecoration(labelText: 'Betrag'),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 130,
        child: SearchableDropdownButtonFormField<String>(
          initialValue: currency,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Währung'),
          items: _currencies
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: onCurrencyChanged,
        ),
      ),
    ],
  );
}

class _ExchangeRateEditorRow extends StatefulWidget {
  const _ExchangeRateEditorRow({
    required this.country,
    required this.baseCurrency,
    required this.initialCurrency,
    required this.initialRate,
    required this.allowManual,
    required this.hasApiKey,
    required this.isAdmin,
    required this.onSave,
  });

  final String country;
  final String baseCurrency;
  final String initialCurrency;
  final double initialRate;
  final bool allowManual;
  final bool hasApiKey;
  final bool isAdmin;
  final Future<void> Function({
    required String currency,
    required double exchangeRate,
    required bool allowManual,
  })
  onSave;

  @override
  State<_ExchangeRateEditorRow> createState() => _ExchangeRateEditorRowState();
}

class _ExchangeRateEditorRowState extends State<_ExchangeRateEditorRow> {
  late final TextEditingController _currency = TextEditingController(
    text: widget.initialCurrency,
  );
  late final TextEditingController _rate = TextEditingController(
    text: widget.initialRate.toStringAsFixed(6),
  );
  late bool _allowManual = widget.allowManual;
  bool _saving = false;

  bool get _readOnly => widget.hasApiKey && !_allowManual;

  @override
  void dispose() {
    _currency.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(widget.country)),
        SizedBox(
          width: 82,
          child: TextField(
            controller: _currency,
            readOnly: _readOnly,
            maxLength: 3,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Währung',
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _rate,
            readOnly: _readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Kurs zu ${widget.baseCurrency}',
            ),
          ),
        ),
        if (widget.isAdmin)
          Tooltip(
            message: 'Manuelle Eingabe trotz API erlauben',
            child: Switch.adaptive(
              value: _allowManual,
              onChanged: (value) => setState(() => _allowManual = value),
            ),
          ),
        IconButton(
          tooltip: 'Wechselkurs speichern',
          onPressed: _saving || _readOnly
              ? null
              : () async {
                  final parsed = _parseNumber(_rate.text);
                  if (parsed == null ||
                      parsed <= 0 ||
                      _currency.text.length != 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ungültiger Wechselkurs.')),
                    );
                    return;
                  }
                  setState(() => _saving = true);
                  await widget.onSave(
                    currency: _currency.text.toUpperCase(),
                    exchangeRate: parsed,
                    allowManual: _allowManual,
                  );
                  if (mounted) setState(() => _saving = false);
                },
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
        ),
      ],
    ),
  );
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
              tooltip:
                  'Aktueller theoretischer Gewinn oder Verlust der gehaltenen Aktien. Verkäufe und physische Werte sind nicht enthalten.',
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
  const _SummaryValue({
    required this.label,
    required this.value,
    this.color,
    this.tooltip,
  });
  final String label;
  final String value;
  final Color? color;
  final String? tooltip;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          if (tooltip != null) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: tooltip!,
              child: const Icon(Icons.info_outline_rounded, size: 16),
            ),
          ],
        ],
      ),
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
                              ? Colors.orange
                              : Colors.green,
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
  if (saved == true) {
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
    final gain = currentValue - asset.purchasePrice;
    final positive = gain >= 0;
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(currentValue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${positive ? '+' : ''}${money(gain)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: positive
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
  DateTime? purchaseDate = asset?.purchaseDate ?? DateTime.now();
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
                  SearchableDropdownButtonFormField<String>(
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
                    SearchableDropdownButtonFormField<String>(
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth < 460
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final field in [
                            (quantity, 'Menge', ''),
                            (weightGrams, 'Gewicht', 'g'),
                            (purchasePrice, 'Kaufpreis gesamt', '€'),
                            (
                              currentPricePerGram,
                              'Aktueller Kurs pro Gramm',
                              '€/g',
                            ),
                          ])
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: field.$1,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: field.$2,
                                  suffixText: field.$3,
                                ),
                                validator: (value) {
                                  final parsed = parseAmount(value);
                                  return parsed == null || parsed < 0
                                      ? 'Ungültiger Wert'
                                      : null;
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
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
      double number(TextEditingController value) => parseAmount(value.text)!;
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${positive ? '+' : ''}${money(gain)}',
                  style: TextStyle(
                    color: positive
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
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
) async {
  final userId = ref.read(currentUserIdProvider);
  final apiKey = userId == null
      ? null
      : await ref.read(secureSessionStoreProvider).readMarketApiKey(userId);
  final hasApiKey = apiKey?.trim().isNotEmpty ?? false;
  if (!context.mounted) return;
  await showDialog<void>(
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
                      showInvestmentEditor(
                        context,
                        ref,
                        investment: investment,
                      );
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
                      '${investment.quantity.toStringAsFixed(2)} Stück',
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calculate_outlined, size: 18),
                    label: Text(
                      'Ø Kaufkurs ${money(investment.purchasePrice)}',
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.show_chart_rounded, size: 18),
                    label: Text('Kurs ${money(investment.currentPrice)}'),
                  ),
                  if (!hasApiKey)
                    ActionChip(
                      avatar: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Aktuellen Kurs bearbeiten'),
                      onPressed: () async {
                        await _editCurrentPrice(context, ref, investment);
                        if (context.mounted) Navigator.pop(context);
                      },
                    )
                  else
                    const Chip(
                      avatar: Icon(Icons.cloud_done_outlined, size: 18),
                      label: Text('Kurs automatisch verwaltet'),
                    ),
                  if (investment.isin.isNotEmpty)
                    Chip(label: Text('ISIN ${investment.isin}')),
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
                              '${purchase.quantity.toStringAsFixed(2)} Stück · ${money(purchase.purchasePrice)}',
                            ),
                            subtitle: Text(
                              DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(purchase.purchaseDate) +
                                  (purchase.fees == 0
                                      ? ''
                                      : ' · Gebühren ${money(purchase.fees)}'),
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
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
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
}

Future<void> _editCurrentPrice(
  BuildContext context,
  WidgetRef ref,
  Investment investment,
) async {
  final controller = TextEditingController(
    text: investment.currentPrice.toStringAsFixed(2),
  );
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Aktueller Kurs · ${investment.name}'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Kurs für die gesamte Position',
            suffixText: '€',
            helperText: 'Gilt einmalig für alle Käufe dieser Position.',
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
          child: const Text('Kurs speichern'),
        ),
      ],
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref
          .read(databaseProvider)
          .updateInvestmentCurrentPrice(
            id: investment.id,
            userId: userId,
            currentPrice: _parseNumber(controller.text)!,
          );
    }
  }
  controller.dispose();
}

Future<void> _showAddPortfolioItem(
  BuildContext context,
  WidgetRef ref, {
  required String accountId,
}) async {
  var kind = 'position';
  final selected = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Anlage hinzufügen'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'position',
                    icon: Icon(Icons.candlestick_chart_rounded),
                    label: Text('Position'),
                  ),
                  ButtonSegment(
                    value: 'physical',
                    icon: Icon(Icons.diamond_outlined),
                    label: Text('Wertgegenstand'),
                  ),
                ],
                selected: {kind},
                onSelectionChanged: (value) =>
                    setDialogState(() => kind = value.single),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: ListTile(
                  key: ValueKey(kind),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    kind == 'position'
                        ? Icons.account_balance_wallet_outlined
                        : Icons.inventory_2_outlined,
                  ),
                  title: Text(
                    kind == 'position'
                        ? 'Wertpapier oder Derivat'
                        : 'Physischer Wertgegenstand',
                  ),
                  subtitle: Text(
                    kind == 'position'
                        ? 'Aktien, Anleihen sowie Knock-Outs, Optionsscheine und Faktorprodukte.'
                        : 'Zum Beispiel Edelmetalle, Sammlerstücke oder andere Sachwerte.',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, kind),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Weiter'),
          ),
        ],
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  if (selected == 'physical') {
    await _showPhysicalAssetEditor(context, ref, accountId: accountId);
  } else {
    await showInvestmentEditor(context, ref, accountId: accountId);
  }
}

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
  final existingItems =
      (ref.read(investmentsProvider).valueOrNull ?? const <Investment>[])
          .where((item) => item.accountId == resolvedAccountId)
          .toList();
  final stockMasters =
      ref.read(stockMastersProvider).valueOrNull ?? const <StockMaster>[];
  final countryTaxRates =
      ref.read(countryTaxRatesProvider).valueOrNull ?? const <CountryTaxRate>[];
  final countries = await ref.read(databaseProvider).availableCountries();
  final accountCurrency =
      (ref.read(accountsProvider).valueOrNull ?? const <Account>[])
          .where((item) => item.id == resolvedAccountId)
          .firstOrNull
          ?.currency
          .toUpperCase() ??
      ref.read(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
      'EUR';
  final defaultFee =
      ref.read(preferencesProvider).valueOrNull?.defaultInvestmentFee ?? 0;
  final currencies = <String>{
    ...supportedIsoCurrencies,
    ...countryTaxRates.map((item) => item.currency.toUpperCase()),
    accountCurrency,
    if (investment != null) investment.dividendCurrency.toUpperCase(),
  }.where((value) => value.trim().isNotEmpty).toList()..sort();
  final userIdForApi = ref.read(currentUserIdProvider);
  final marketApiKey = investment == null || userIdForApi == null
      ? null
      : await ref
            .read(secureSessionStoreProvider)
            .readMarketApiKey(userIdForApi);
  final exchangeApiKey = investment == null || userIdForApi == null
      ? null
      : await ref
            .read(secureSessionStoreProvider)
            .readExchangeApiKey(userIdForApi);
  if (!context.mounted) return;
  final saved = await showDialog<({InvestmentsCompanion investment, bool buy})>(
    context: context,
    builder: (_) => _InvestmentEditor(
      investment: investment,
      stockMasters: stockMasters,
      countryTaxRates: countryTaxRates,
      countries: countries,
      currencies: currencies,
      assetTypes: supportedPortfolioAssetClasses,
      accountId: resolvedAccountId,
      accountCurrency: accountCurrency,
      defaultFee: defaultFee,
      hasMarketApiKey: marketApiKey?.trim().isNotEmpty ?? false,
      hasExchangeApiKey: exchangeApiKey?.trim().isNotEmpty ?? false,
    ),
  );
  if (saved != null) {
    var result = saved.investment;
    final database = ref.read(databaseProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      if (!result.stockId.present || result.stockId.value == null) {
        final now = DateTime.now().toUtc();
        final master = await database.ensurePortfolioMaster(
          userId,
          StockMastersCompanion.insert(
            id: const Uuid().v4(),
            name: result.name.value,
            assetType: Value(result.assetType.value),
            symbol: result.symbol.value,
            isin: Value(result.isin.value),
            wkn: Value(result.wkn.value),
            instrumentSubtype: Value(result.instrumentSubtype.value),
            positionDirection: Value(result.positionDirection.value),
            issuer: Value(result.issuer.value),
            underlying: Value(result.underlying.value),
            instrumentCurrency: Value(result.instrumentCurrency.value),
            nominalValue: Value(result.nominalValue.value),
            couponRate: Value(result.couponRate.value),
            maturityDate: Value(result.maturityDate.value),
            strikePrice: Value(result.strikePrice.value),
            knockOutBarrier: Value(result.knockOutBarrier.value),
            leverage: Value(result.leverage.value),
            subscriptionRatio: Value(result.subscriptionRatio.value),
            currency: Value(result.instrumentCurrency.value),
            dividendCurrency: Value(result.dividendCurrency.value),
            country: Value(result.country.value),
            broker: Value(result.broker.value),
            sector: Value(result.sector.value),
            dividendFrequency: Value(result.dividendFrequency.value),
            dividendStartMonth: Value(result.dividendStartMonth.value),
            dividendPerShare: Value(result.annualDividend.value),
            createdAt: now,
            updatedAt: now,
          ),
        );
        result = result.copyWith(stockId: Value(master.id));
      }
      Investment? duplicate;
      if (investment == null) {
        final newIdentity = portfolioMasterIdentity(
          assetType: result.assetType.value,
          name: result.name.value,
          symbol: result.symbol.value,
          isin: result.isin.value,
          wkn: result.wkn.value,
          instrumentSubtype: result.instrumentSubtype.value,
          issuer: result.issuer.value,
          underlying: result.underlying.value,
          maturityDate: result.maturityDate.value,
        );
        duplicate = existingItems
            .where(
              (item) =>
                  portfolioMasterIdentity(
                    assetType: item.assetType,
                    name: item.name,
                    symbol: item.symbol,
                    isin: item.isin,
                    wkn: item.wkn,
                    instrumentSubtype: item.instrumentSubtype,
                    issuer: item.issuer,
                    underlying: item.underlying,
                    maturityDate: item.maturityDate,
                  ) ==
                  newIdentity,
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
            instrumentSubtype: result.instrumentSubtype,
            positionDirection: result.positionDirection,
            issuer: result.issuer,
            underlying: result.underlying,
            instrumentCurrency: result.instrumentCurrency,
            nominalValue: result.nominalValue,
            couponRate: result.couponRate,
            maturityDate: result.maturityDate,
            strikePrice: result.strikePrice,
            knockOutBarrier: result.knockOutBarrier,
            leverage: result.leverage,
            subscriptionRatio: result.subscriptionRatio,
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
            cashApplied: Value(saved.buy),
            createdAt: DateTime.now().toUtc(),
          ),
        );
        await _importCachedDividendHistory(
          database: database,
          userId: userId,
          investmentId: targetId,
          stockId: result.stockId.value,
          purchaseDate: result.purchaseDate.value,
          exchangeRate: result.dividendExchangeRate.value,
          withholdingTaxRate: result.dividendWithholdingTaxRate.value,
        );
        if (saved.buy) {
          await database.applyPortfolioPurchaseToCash(
            userId: userId,
            accountId: result.accountId.value,
            amount:
                result.purchasePrice.value * result.quantity.value +
                result.fees.value,
            purchasedAt: result.purchaseDate.value,
          );
        }
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

Future<void> _importCachedDividendHistory({
  required AppDatabase database,
  required String userId,
  required String investmentId,
  required String? stockId,
  required DateTime purchaseDate,
  required double exchangeRate,
  required double withholdingTaxRate,
}) async {
  if (stockId == null) return;
  final now = DateTime.now();
  final createdAt = now.toUtc();
  for (var year = purchaseDate.year; year <= now.year; year++) {
    final dividends = await database.stockDividendsForYear(stockId, year);
    for (final dividend in dividends) {
      final paymentDate = dividend.paymentDate ?? dividend.exDate;
      if (paymentDate.isBefore(purchaseDate) || paymentDate.isAfter(now)) {
        continue;
      }
      await database.saveDividendSchedule(
        DividendSchedulesCompanion.insert(
          id: '$investmentId-api-${dividend.id}',
          userId: userId,
          investmentId: investmentId,
          paymentMonth: paymentDate.month,
          amountPerShare: dividend.amount,
          exDate: Value(dividend.exDate),
          paymentDate: Value(dividend.paymentDate),
          paymentYear: Value(year),
          currency: Value(dividend.currency),
          exchangeRate: Value(exchangeRate),
          withholdingTaxRate: Value(withholdingTaxRate),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
    }
  }
}

class _InvestmentEditor extends StatefulWidget {
  const _InvestmentEditor({
    required this.stockMasters,
    required this.countryTaxRates,
    required this.countries,
    required this.currencies,
    required this.assetTypes,
    required this.accountId,
    required this.accountCurrency,
    required this.defaultFee,
    required this.hasMarketApiKey,
    required this.hasExchangeApiKey,
    this.investment,
  });
  final Investment? investment;
  final List<StockMaster> stockMasters;
  final List<CountryTaxRate> countryTaxRates;
  final List<String> countries;
  final List<String> currencies;
  final List<String> assetTypes;
  final String accountId;
  final String accountCurrency;
  final double defaultFee;
  final bool hasMarketApiKey;
  final bool hasExchangeApiKey;
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
    text:
        widget.investment?.dividendCurrency ??
        widget.countryTaxRates
            .where(
              (item) =>
                  normalizeCountry(item.country) ==
                  normalizeCountry(widget.investment?.country ?? ''),
            )
            .firstOrNull
            ?.currency
            .toUpperCase() ??
        widget.accountCurrency,
  );
  late final _dividendExchangeRate = TextEditingController(
    text: widget.investment?.dividendExchangeRate.toString() ?? '1',
  );
  late final _dividendWithholdingTax = TextEditingController(
    text: widget.investment?.dividendWithholdingTaxRate.toString() ?? '0',
  );
  late final _notes = TextEditingController(text: widget.investment?.notes);
  late final _issuer = TextEditingController(text: widget.investment?.issuer);
  late final _underlying = TextEditingController(
    text: widget.investment?.underlying,
  );
  late final _instrumentCurrency = TextEditingController(
    text: widget.investment?.instrumentCurrency ?? widget.accountCurrency,
  );
  late final _nominalValue = TextEditingController(
    text: widget.investment?.nominalValue.toString() ?? '0',
  );
  late final _couponRate = TextEditingController(
    text: widget.investment?.couponRate.toString() ?? '0',
  );
  late final _strikePrice = TextEditingController(
    text: widget.investment?.strikePrice.toString() ?? '0',
  );
  late final _knockOutBarrier = TextEditingController(
    text: widget.investment?.knockOutBarrier.toString() ?? '0',
  );
  late final _leverage = TextEditingController(
    text: widget.investment?.leverage.toString() ?? '0',
  );
  late final _subscriptionRatio = TextEditingController(
    text: widget.investment?.subscriptionRatio.toString() ?? '0',
  );
  late String _type = widget.investment?.assetType ?? 'Aktie';
  late String _instrumentSubtype =
      widget.investment?.instrumentSubtype.isNotEmpty == true
      ? widget.investment!.instrumentSubtype
      : 'Knock-Out';
  late String _positionDirection =
      widget.investment?.positionDirection.isNotEmpty == true
      ? widget.investment!.positionDirection
      : 'Long';
  late DateTime? _maturityDate = widget.investment?.maturityDate;
  late String _frequency = widget.investment?.dividendFrequency ?? 'jährlich';
  late int _startMonth = widget.investment?.dividendStartMonth ?? 1;
  late DateTime _date = widget.investment?.purchaseDate ?? DateTime.now();
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
      _issuer,
      _underlying,
      _instrumentCurrency,
      _nominalValue,
      _couponRate,
      _strikePrice,
      _knockOutBarrier,
      _leverage,
      _subscriptionRatio,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
      title: Text(
        widget.investment == null ? 'Position anlegen' : 'Position bearbeiten',
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80).clamp(280.0, 650.0),
        height: (MediaQuery.sizeOf(context).height - 320).clamp(240.0, 680.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Tooltip(
                  message: 'Anlageklasse auswählen',
                  child: SearchableDropdownButtonFormField<String>(
                    initialValue: _normalizedType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: widget.investment == null
                          ? 'Anlageklasse *'
                          : 'Anlageklasse',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: widget.assetTypes
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: widget.investment != null
                        ? null
                        : (value) => setState(() {
                            _type = value ?? 'Aktie';
                            _selectedStockId = null;
                            _clearMasterFields();
                          }),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.investment == null && _offersMasterSelection) ...[
                  SearchableDropdownButtonFormField<String>(
                    key: ValueKey('master-$_normalizedType-$_selectedStockId'),
                    initialValue: _selectedStockId ?? _newMasterValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Stammdaten *',
                      prefixIcon: Icon(Icons.search_rounded),
                      helperText:
                          'Vorhandenes Instrument wählen oder neu erfassen.',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: _newMasterValue,
                        child: Text('Neues Instrument erfassen'),
                      ),
                      ..._matchingStockMasters.map(
                        (stock) => DropdownMenuItem(
                          value: stock.id,
                          child: Text(
                            [
                              stock.name,
                              stock.symbol,
                            ].where((value) => value.isNotEmpty).join(' · '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == _newMasterValue) {
                        setState(() {
                          _selectedStockId = null;
                          _clearMasterFields();
                        });
                      } else {
                        _selectStock(value);
                      }
                    },
                  ),
                  if (_matchingStockMasters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Für diese Anlageklasse gibt es noch keine passenden Stammdaten. Beim Speichern wird ein neuer Datensatz angelegt.',
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                Card(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    key: ValueKey(
                      'master-details-$_normalizedType-$_selectedStockId',
                    ),
                    initiallyExpanded: !_usesSelectedMaster,
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Stammdaten'),
                    subtitle: Text(
                      _usesSelectedMaster
                          ? 'Aus dem Portfolio-Katalog übernommen'
                          : 'Werden beim Speichern dedupliziert angelegt',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    children: [
                      _responsiveFields([
                        _field(
                          _name,
                          'Name',
                          required: true,
                          readOnly: _usesSelectedMaster,
                        ),
                        _field(
                          _symbol,
                          'Symbol',
                          required: true,
                          readOnly: _usesSelectedMaster,
                        ),
                      ]),
                      if (!_isCrypto) ...[
                        const SizedBox(height: 12),
                        _responsiveFields([
                          _field(
                            _isin,
                            'ISIN',
                            required: true,
                            readOnly: _usesSelectedMaster,
                          ),
                          _field(_wkn, 'WKN', readOnly: _usesSelectedMaster),
                        ]),
                      ],
                      const SizedBox(height: 12),
                      _responsiveFields([
                        _readOnlyValue('Anlageklasse', _normalizedType),
                        _field(
                          _broker,
                          'Broker',
                          readOnly: _usesSelectedMaster,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _responsiveFields([
                        _countryDropdown(),
                        if (!_isCrypto)
                          _field(
                            _sector,
                            'Branche',
                            readOnly: _usesSelectedMaster,
                          ),
                      ]),
                      if (_isCrypto) ...[
                        const SizedBox(height: 12),
                        _currencyDropdown(
                          controller: _instrumentCurrency,
                          label: 'Handelswährung',
                        ),
                      ],
                      if (_isBond) ...[
                        const SizedBox(height: 12),
                        _responsiveFields([
                          _field(
                            _issuer,
                            'Emittent',
                            readOnly: _usesSelectedMaster,
                          ),
                          _currencyDropdown(
                            controller: _instrumentCurrency,
                            label: 'Anleihewährung',
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _responsiveFields([
                          _field(_nominalValue, 'Nennwert', number: true),
                          _field(
                            _couponRate,
                            'Kupon',
                            number: true,
                            suffixText: '%',
                            maximum: 100,
                          ),
                          OutlinedButton.icon(
                            onPressed: _usesSelectedMaster
                                ? null
                                : _pickMaturityDate,
                            icon: const Icon(Icons.event_rounded),
                            label: Text(
                              _maturityDate == null
                                  ? 'Fälligkeit wählen'
                                  : 'Fällig: ${DateFormat('dd.MM.yyyy').format(_maturityDate!)}',
                            ),
                          ),
                        ]),
                      ],
                      if (_isDerivative) ...[
                        const SizedBox(height: 12),
                        _responsiveFields([
                          SearchableDropdownButtonFormField<String>(
                            initialValue: _instrumentSubtype,
                            decoration: const InputDecoration(
                              labelText: 'Derivat',
                            ),
                            items:
                                const ['Knock-Out', 'Optionsschein', 'Faktor']
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: _usesSelectedMaster
                                ? null
                                : (value) => setState(() {
                                    _instrumentSubtype = value ?? 'Knock-Out';
                                    _positionDirection =
                                        _instrumentSubtype == 'Optionsschein'
                                        ? 'Call'
                                        : 'Long';
                                  }),
                          ),
                          SearchableDropdownButtonFormField<String>(
                            key: ValueKey(_instrumentSubtype),
                            initialValue: _positionDirection,
                            decoration: InputDecoration(
                              labelText: _instrumentSubtype == 'Optionsschein'
                                  ? 'Optionsart'
                                  : 'Richtung',
                            ),
                            items:
                                (_instrumentSubtype == 'Optionsschein'
                                        ? const ['Call', 'Put']
                                        : const ['Long', 'Short'])
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: _usesSelectedMaster
                                ? null
                                : (value) => _positionDirection =
                                      value ?? _positionDirection,
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _responsiveFields([
                          _field(
                            _issuer,
                            'Emittent',
                            readOnly: _usesSelectedMaster,
                          ),
                          _field(
                            _underlying,
                            'Basiswert',
                            required: true,
                            readOnly: _usesSelectedMaster,
                          ),
                          _currencyDropdown(
                            controller: _instrumentCurrency,
                            label: 'Produktwährung',
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _responsiveFields([
                          if (_instrumentSubtype == 'Optionsschein')
                            _field(
                              _strikePrice,
                              'Basispreis',
                              number: true,
                              readOnly: _usesSelectedMaster,
                            ),
                          if (_instrumentSubtype == 'Knock-Out')
                            _field(
                              _knockOutBarrier,
                              'Knock-Out-Schwelle',
                              number: true,
                              readOnly: _usesSelectedMaster,
                            ),
                          _field(
                            _leverage,
                            _instrumentSubtype == 'Faktor' ? 'Faktor' : 'Hebel',
                            number: true,
                            readOnly: _usesSelectedMaster,
                          ),
                          if (_instrumentSubtype != 'Faktor')
                            _field(
                              _subscriptionRatio,
                              'Bezugsverhältnis',
                              number: true,
                              readOnly: _usesSelectedMaster,
                            ),
                          if (_instrumentSubtype == 'Optionsschein')
                            OutlinedButton.icon(
                              onPressed: _usesSelectedMaster
                                  ? null
                                  : _pickMaturityDate,
                              icon: const Icon(Icons.event_rounded),
                              label: Text(
                                _maturityDate == null
                                    ? 'Laufzeitende wählen'
                                    : 'Bis ${DateFormat('dd.MM.yyyy').format(_maturityDate!)}',
                              ),
                            ),
                        ]),
                      ],
                      if (_supportsDividends) ...[
                        const SizedBox(height: 12),
                        _responsiveFields([
                          _field(
                            _dividend,
                            'Dividende je Stück / Ausschüttung',
                            number: true,
                            required: true,
                            suffixText: _dividendCurrency.text.toUpperCase(),
                          ),
                          SearchableDropdownButtonFormField<String>(
                            initialValue: _frequency,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: _usesSelectedMaster
                                  ? 'Auszahlungsrhythmus'
                                  : 'Auszahlungsrhythmus *',
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
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: _usesSelectedMaster
                                ? null
                                : (value) => setState(
                                    () => _frequency = value ?? _frequency,
                                  ),
                          ),
                          SearchableDropdownButtonFormField<int>(
                            initialValue: _startMonth,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: _usesSelectedMaster
                                  ? 'Startmonat'
                                  : 'Startmonat *',
                            ),
                            items: List.generate(
                              12,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(_investmentMonthNames[index]),
                              ),
                            ),
                            onChanged: _usesSelectedMaster
                                ? null
                                : (value) => setState(
                                    () => _startMonth = value ?? _startMonth,
                                  ),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
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
                    readOnly: widget.hasMarketApiKey && _usesSelectedMaster,
                  ),
                ]),
                if (_supportsDividends) ...[
                  const SizedBox(height: 12),
                  _responsiveFields([
                    _field(
                      _dividendExchangeRate,
                      'Kurs zur Standardwährung',
                      number: true,
                      required: true,
                      minimum: 0.000001,
                      readOnly: _exchangeLocked,
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
                ],
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
                if (widget.investment == null) ...[
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const ListTile(
                      dense: true,
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('Speichern oder Kaufen?'),
                      subtitle: Text(
                        'Speichern fügt die Position nur hinzu. Kaufen zieht Kaufwert und Gebühren vom verfügbaren Geld des Portfolio-Kontos ab.',
                      ),
                    ),
                  ),
                ],
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
        if (widget.investment == null) ...[
          OutlinedButton(
            onPressed: () => _save(buy: false),
            child: const Text('Speichern'),
          ),
          FilledButton(
            onPressed: () => _save(buy: true),
            child: const Text('Kaufen'),
          ),
        ] else
          FilledButton(
            onPressed: () => _save(buy: false),
            child: const Text('Speichern'),
          ),
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
      labelText: required && !readOnly ? '$label *' : label,
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
      if (required && !readOnly && (value?.trim().isEmpty ?? true)) {
        return 'Pflichtfeld';
      }
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

  void _selectStock(String? id) {
    if (id == null) return;
    final stock = widget.stockMasters.firstWhere((item) => item.id == id);
    final countryRate = widget.countryTaxRates
        .where(
          (item) =>
              item.country.trim().toLowerCase() ==
              stock.country.trim().toLowerCase(),
        )
        .firstOrNull;
    setState(() {
      _selectedStockId = id;
      _name.text = stock.name;
      _symbol.text = stock.symbol;
      _isin.text = stock.isin;
      _country.text = stock.country;
      _sector.text = stock.sector;
      _wkn.text = stock.wkn;
      _broker.text = stock.broker;
      _issuer.text = stock.issuer;
      _underlying.text = stock.underlying;
      _instrumentCurrency.text = stock.instrumentCurrency;
      _nominalValue.text = stock.nominalValue.toString();
      _couponRate.text = stock.couponRate.toString();
      _maturityDate = stock.maturityDate;
      _strikePrice.text = stock.strikePrice.toString();
      _knockOutBarrier.text = stock.knockOutBarrier.toString();
      _leverage.text = stock.leverage.toString();
      _subscriptionRatio.text = stock.subscriptionRatio.toString();
      _dividend.text = stock.dividendPerShare.toString();
      if (stock.instrumentSubtype.isNotEmpty) {
        _instrumentSubtype = stock.instrumentSubtype;
      }
      if (stock.positionDirection.isNotEmpty) {
        _positionDirection = stock.positionDirection;
      }
      _dividendCurrency.text =
          countryRate?.currency.toUpperCase() ??
          defaultCurrencyForCountry(
            stock.country,
            fallback: stock.dividendCurrency,
          );
      _frequency = stock.dividendFrequency;
      _startMonth = stock.dividendStartMonth;
      _dividendExchangeRate.text =
          (countryRate?.exchangeRate ??
                  (stock.dividendCurrency.toUpperCase() == 'EUR' ? 1 : 1))
              .toString();
      _dividendWithholdingTax.text = _isUnitedStates(stock.country)
          ? _taxRateForCountry(stock.country, fallback: 15).toString()
          : _taxRateForCountry(stock.country, fallback: 0).toString();
    });
  }

  double? _number(String? value) => parseAmount(value);

  static const _newMasterValue = '__new_portfolio_master__';

  String get _normalizedType => _type;

  bool get _isBond => _normalizedType == 'Anleihe';

  bool get _isDerivative =>
      const {'Derivate', 'Hebelprodukt'}.contains(_normalizedType);

  bool get _isCrypto => _normalizedType == 'Kryptowährung';

  bool get _offersMasterSelection => true;

  bool get _usesSelectedMaster => _selectedStockId != null;

  List<StockMaster> get _matchingStockMasters => widget.stockMasters
      .where((item) => item.assetType == _normalizedType)
      .toList();

  bool get _supportsDividends =>
      const {'Aktie', 'ETF', 'Fonds'}.contains(_normalizedType);

  void _clearMasterFields() {
    for (final controller in [
      _name,
      _symbol,
      _isin,
      _wkn,
      _broker,
      _country,
      _sector,
      _issuer,
      _underlying,
    ]) {
      controller.clear();
    }
    _instrumentCurrency.text = widget.accountCurrency;
    _dividendCurrency.text = widget.accountCurrency;
    _dividendExchangeRate.text = '1';
    _dividendWithholdingTax.text = '0';
    _dividend.text = '0';
    _frequency = 'jährlich';
    _startMonth = 1;
    for (final controller in [
      _nominalValue,
      _couponRate,
      _strikePrice,
      _knockOutBarrier,
      _leverage,
      _subscriptionRatio,
    ]) {
      controller.text = '0';
    }
    _maturityDate = null;
  }

  Widget _countryDropdown() {
    final values = <String>{
      ...widget.countries,
      _country.text.trim(),
    }.where((value) => value.isNotEmpty).toList()..sort();
    final selected = values.contains(_country.text.trim())
        ? _country.text.trim()
        : null;
    return SearchableDropdownButtonFormField<String>(
      key: ValueKey('country-$selected-$_selectedStockId'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: _usesSelectedMaster ? 'Land' : 'Land *',
        prefixIcon: const Icon(Icons.public_rounded),
      ),
      items: values
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: _usesSelectedMaster ? null : _applyCountry,
      validator: (value) =>
          value?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
    );
  }

  void _applyCountry(String? value) {
    final selected = value?.trim() ?? '';
    final configuration = widget.countryTaxRates
        .where(
          (item) =>
              normalizeCountry(item.country) == normalizeCountry(selected),
        )
        .firstOrNull;
    setState(() {
      _country.text = selected;
      _dividendCurrency.text =
          configuration?.currency.toUpperCase() ??
          defaultCurrencyForCountry(selected, fallback: widget.accountCurrency);
      _dividendExchangeRate.text = (configuration?.exchangeRate ?? 1)
          .toString();
      _dividendWithholdingTax.text = (configuration?.withholdingTaxRate ?? 0)
          .toString();
    });
  }

  Widget _currencyDropdown({
    required TextEditingController controller,
    required String label,
  }) {
    final values = <String>{
      ...widget.currencies,
      controller.text.trim().toUpperCase(),
      widget.accountCurrency,
    }.where((value) => value.isNotEmpty).toList()..sort();
    return SearchableDropdownButtonFormField<String>(
      initialValue: values.contains(controller.text.trim().toUpperCase())
          ? controller.text.trim().toUpperCase()
          : values.first,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: _usesSelectedMaster && controller == _instrumentCurrency
          ? null
          : (value) => controller.text = value ?? widget.accountCurrency,
    );
  }

  bool get _exchangeLocked => widget.hasExchangeApiKey;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickMaturityDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 100),
      initialDate: _maturityDate?.isAfter(now) == true
          ? _maturityDate!
          : DateTime(now.year + 1, now.month, now.day),
    );
    if (selected != null) setState(() => _maturityDate = selected);
  }

  void _save({required bool buy}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final masterError = portfolioMasterValidationError(
      assetType: _normalizedType,
      name: _name.text,
      country: _country.text,
      symbol: _symbol.text,
      isin: _isin.text,
      wkn: _wkn.text,
      instrumentSubtype: _instrumentSubtype,
      issuer: _issuer.text,
      underlying: _underlying.text,
    );
    if (masterError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(masterError)));
      return;
    }
    final userId = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    Navigator.pop(context, (
      investment: InvestmentsCompanion.insert(
        id: widget.investment?.id ?? const Uuid().v4(),
        userId: userId,
        stockId: Value(_selectedStockId),
        accountId: Value(widget.accountId),
        name: _name.text.trim(),
        symbol: Value(_symbol.text.trim().toUpperCase()),
        isin: Value(_isin.text.trim().toUpperCase()),
        wkn: Value(_wkn.text.trim().toUpperCase()),
        assetType: _normalizedType,
        instrumentSubtype: Value(_isDerivative ? _instrumentSubtype : ''),
        positionDirection: Value(_isDerivative ? _positionDirection : ''),
        issuer: Value((_isBond || _isDerivative) ? _issuer.text.trim() : ''),
        underlying: Value(_isDerivative ? _underlying.text.trim() : ''),
        instrumentCurrency: Value(
          (_isBond || _isDerivative || _isCrypto)
              ? _instrumentCurrency.text.trim().toUpperCase()
              : _dividendCurrency.text.trim().toUpperCase(),
        ),
        nominalValue: Value(_isBond ? (_number(_nominalValue.text) ?? 0) : 0),
        couponRate: Value(_isBond ? (_number(_couponRate.text) ?? 0) : 0),
        maturityDate: Value(
          (_isBond || (_isDerivative && _instrumentSubtype == 'Optionsschein'))
              ? _maturityDate
              : null,
        ),
        strikePrice: Value(
          _isDerivative && _instrumentSubtype == 'Optionsschein'
              ? (_number(_strikePrice.text) ?? 0)
              : 0,
        ),
        knockOutBarrier: Value(
          _isDerivative && _instrumentSubtype == 'Knock-Out'
              ? (_number(_knockOutBarrier.text) ?? 0)
              : 0,
        ),
        leverage: Value(_isDerivative ? (_number(_leverage.text) ?? 0) : 0),
        subscriptionRatio: Value(
          _isDerivative && _instrumentSubtype != 'Faktor'
              ? (_number(_subscriptionRatio.text) ?? 0)
              : 0,
        ),
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
      buy: buy,
    ));
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
                    if (parsed > investment.quantity) {
                      return 'Mehr als verfügbar';
                    }
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
  final accounts = ref.read(accountsProvider).valueOrNull ?? const <Account>[];
  const historyOnly = '__history_only__';
  var destinationAccountId = accounts.any((item) => item.id == asset.accountId)
      ? asset.accountId
      : historyOnly;
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
                    if (parsed == null || parsed <= 0) {
                      return 'Ungültiges Gewicht';
                    }
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
                SearchableDropdownButtonFormField<String>(
                  initialValue: destinationAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Verkaufserlös',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: historyOnly,
                      child: Text('Nicht buchen – nur Historie'),
                    ),
                    ...accounts.map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          '${account.label} · ${account.bankName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      destinationAccountId = value ?? historyOnly,
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
            destinationAccountId: destinationAccountId == historyOnly
                ? null
                : destinationAccountId,
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
  final investment =
      (ref.read(allInvestmentsProvider).valueOrNull ?? const <Investment>[])
          .where((item) => item.id == purchase.investmentId)
          .firstOrNull;
  final quantity = TextEditingController(text: purchase.quantity.toString());
  final price = TextEditingController(text: purchase.purchasePrice.toString());
  final fee = TextEditingController(text: purchase.fees.toString());
  final dividend = TextEditingController(
    text: investment?.annualDividend.toString() ?? '0',
  );
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
              TextFormField(
                controller: dividend,
                decoration: InputDecoration(
                  labelText: 'Dividende je Stück/Ausschüttung',
                  suffixText: investment?.dividendCurrency ?? 'EUR',
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
      if (investment != null) {
        await ref
            .read(databaseProvider)
            .updateInvestmentDividend(
              id: investment.id,
              userId: userId,
              dividendPerShare: _parseNumber(dividend.text)!,
            );
      }
    }
    if (context.mounted) Navigator.pop(context);
  }
  quantity.dispose();
  price.dispose();
  fee.dispose();
  dividend.dispose();
}

Future<void> _showPortfolioActivity(
  BuildContext context, {
  required WidgetRef ref,
  required List<PortfolioSale> sales,
  required List<PortfolioAuditLog> auditLogs,
}) async {
  final userId = ref.read(currentUserIdProvider);
  final database = ref.read(databaseProvider);
  final deletedInvestments = userId == null
      ? const <Investment>[]
      : await database.deletedInvestmentsFor(userId);
  final deletedPhysicalAssets = userId == null
      ? const <PhysicalAsset>[]
      : await database.deletedPhysicalAssetsFor(userId);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => DefaultTabController(
      length: 3,
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
                  Tab(text: 'Papierkorb'),
                  Tab(text: 'Protokoll'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    sales.isEmpty
                        ? const Center(child: Text('Noch keine Verkäufe.'))
                        : ListView.separated(
                            itemCount: sales.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final sale = sales[index];
                              final positive = sale.realizedGain >= 0;
                              return ListTile(
                                onTap: () => _showSaleDetail(
                                  context,
                                  sale: sale,
                                  baseCurrency:
                                      ref
                                          .read(preferencesProvider)
                                          .valueOrNull
                                          ?.currency ??
                                      'EUR',
                                ),
                                leading: CircleAvatar(
                                  child: Icon(
                                    sale.assetKind == 'physical'
                                        ? Icons.diamond_outlined
                                        : Icons.trending_down_rounded,
                                  ),
                                ),
                                title: Text(sale.assetName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                                      '${sale.quantity.toStringAsFixed(2)} ${sale.unit}',
                                    ),
                                    Text(
                                      '${positive ? 'Gewinn' : 'Verlust'} '
                                      '${positive ? '+' : ''}${money(sale.realizedGain)}'
                                      '${sale.taxPaid > 0 ? ' · Steuer ${money(sale.taxPaid)}' : ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: positive
                                                ? Colors.green
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
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
                    deletedInvestments.isEmpty && deletedPhysicalAssets.isEmpty
                        ? const Center(child: Text('Der Papierkorb ist leer.'))
                        : ListView(
                            children: [
                              for (final item in deletedInvestments)
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.show_chart_rounded),
                                  ),
                                  title: Text(item.name),
                                  subtitle: const Text('Gelöschtes Wertpapier'),
                                  trailing: FilledButton.tonalIcon(
                                    onPressed: () async {
                                      final userId = ref.read(
                                        currentUserIdProvider,
                                      );
                                      if (userId != null) {
                                        await ref
                                            .read(databaseProvider)
                                            .restoreInvestment(item.id, userId);
                                      }
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.restore_rounded),
                                    label: const Text('Wiederherstellen'),
                                  ),
                                ),
                              for (final asset in deletedPhysicalAssets)
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.diamond_outlined),
                                  ),
                                  title: Text(asset.name),
                                  subtitle: const Text(
                                    'Gelöschter Wertgegenstand',
                                  ),
                                  trailing: FilledButton.tonalIcon(
                                    onPressed: () async {
                                      final userId = ref.read(
                                        currentUserIdProvider,
                                      );
                                      if (userId != null) {
                                        await ref
                                            .read(databaseProvider)
                                            .restorePhysicalAsset(
                                              asset.id,
                                              userId,
                                            );
                                      }
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.restore_rounded),
                                    label: const Text('Wiederherstellen'),
                                  ),
                                ),
                            ],
                          ),
                    auditLogs.isEmpty
                        ? const Center(child: Text('Noch keine Löschvorgänge.'))
                        : ListView.separated(
                            itemCount: auditLogs.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
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
}

Future<void> _showSaleDetail(
  BuildContext context, {
  required PortfolioSale sale,
  required String baseCurrency,
}) {
  final gross = sale.quantity * sale.pricePerUnit;
  final capitalTax = sale.taxPaid / 1.055;
  final solidarity = sale.taxPaid - capitalTax;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Verkaufsdetails'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Icon(
                      sale.assetKind == 'physical'
                          ? Icons.diamond_outlined
                          : Icons.show_chart_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.assetName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${DateFormat('dd.MM.yyyy').format(sale.soldAt)} · '
                          '${sale.quantity.toStringAsFixed(2)} ${sale.unit} zu '
                          '${money(sale.pricePerUnit, currency: sale.sourceCurrency)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SaleHighlight(
                        label: 'Netto-Auszahlung',
                        value: money(sale.proceeds, currency: baseCurrency),
                      ),
                    ),
                    const SizedBox(
                      height: 44,
                      child: VerticalDivider(width: 24),
                    ),
                    Expanded(
                      child: _SaleHighlight(
                        label: sale.realizedGain >= 0 ? 'Gewinn' : 'Verlust',
                        value:
                            '${sale.realizedGain >= 0 ? '+' : ''}${money(sale.realizedGain, currency: baseCurrency)}',
                        color: sale.realizedGain >= 0
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Brutto bis Netto',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              _SaleTaxRow(
                label: 'Brutto-Verkaufserlös',
                value: gross,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              _SaleTaxRow(
                label: 'Gebühren',
                value: -sale.fees,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Anschaffungskosten',
                value: -sale.costBasis,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Realisierter Gewinn/Verlust',
                value: sale.realizedGain,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              const Divider(height: 18),
              _SaleTaxRow(
                label: 'Genutzter Freistellungsauftrag',
                value: sale.allowanceUsed,
                sale: sale,
                baseCurrency: baseCurrency,
                informational: true,
              ),
              _SaleTaxRow(
                label: 'Kapitalertragsteuer',
                value: -capitalTax,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              _SaleTaxRow(
                label: 'Solidaritätszuschlag',
                value: -solidarity,
                sale: sale,
                baseCurrency: baseCurrency,
              ),
              const Divider(height: 18),
              _SaleTaxRow(
                label: 'Netto-Auszahlung',
                value: sale.proceeds,
                sale: sale,
                baseCurrency: baseCurrency,
                emphasized: true,
              ),
              const SizedBox(height: 12),
              if (sale.sourceCurrency != baseCurrency || sale.exchangeRate != 1)
                Text(
                  '${sale.sourceCurrency} → $baseCurrency · Kurs ${sale.exchangeRate.toStringAsFixed(6)}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  sale.accountCredited
                      ? Icons.account_balance_rounded
                      : Icons.receipt_long_outlined,
                ),
                title: Text(
                  sale.accountCredited
                      ? 'Auszahlung auf Konto gebucht'
                      : 'Nur im Verkaufsprotokoll erfasst',
                ),
                subtitle: sale.destinationAccountId == null
                    ? null
                    : Text('Zielkonto: ${sale.destinationAccountId}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fertig'),
        ),
      ],
    ),
  );
}

class _SaleHighlight extends StatelessWidget {
  const _SaleHighlight({required this.label, required this.value, this.color});

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

class _SaleTaxRow extends StatelessWidget {
  const _SaleTaxRow({
    required this.label,
    required this.value,
    required this.sale,
    required this.baseCurrency,
    this.emphasized = false,
    this.informational = false,
  });

  final String label;
  final double value;
  final PortfolioSale sale;
  final String baseCurrency;
  final bool emphasized;
  final bool informational;

  @override
  Widget build(BuildContext context) {
    final rate = sale.exchangeRate <= 0 ? 1.0 : sale.exchangeRate;
    final showSource = sale.sourceCurrency != baseCurrency || rate != 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (showSource)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                money(value / rate, currency: sale.sourceCurrency),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Text(
            money(value, currency: baseCurrency),
            style: TextStyle(
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              color: informational
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

double? _parseNumber(String? value) => parseAmount(value);

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
