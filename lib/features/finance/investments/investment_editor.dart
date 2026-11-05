part of '../investments_page.dart';

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
    ),
  );
  if (saved != null && context.mounted) {
    await saveWithFeedback(context, () async {
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
          await database.recordInvestmentPurchase(
            userId: userId,
            investmentId: targetId,
            purchaseDate: result.purchaseDate.value,
            purchasePrice: result.purchasePrice.value,
            quantity: result.quantity.value,
            fees: result.fees.value,
            buy: saved.buy,
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
    }, source: 'Position speichern');
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
                                child: Text(monthNames[index]),
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
        quantity: _number(_quantity.text) ?? 0,
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
