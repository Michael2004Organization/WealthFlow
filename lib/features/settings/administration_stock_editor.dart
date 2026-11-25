part of 'administration_page.dart';

Future<void> _editStock(
  BuildContext context,
  WidgetRef ref, {
  StockMaster? stock,
}) async {
  final name = TextEditingController(text: stock?.name);
  final symbol = TextEditingController(text: stock?.symbol);
  final isin = TextEditingController(text: stock?.isin);
  final wkn = TextEditingController(text: stock?.wkn);
  final currency = TextEditingController(text: stock?.currency ?? 'EUR');
  final dividendCurrency = TextEditingController(
    text: stock?.dividendCurrency ?? stock?.currency ?? 'EUR',
  );
  final country = TextEditingController(text: stock?.country);
  final exchange = TextEditingController(text: stock?.exchange);
  final broker = TextEditingController(text: stock?.broker);
  final sector = TextEditingController(text: stock?.sector);
  final companyData = TextEditingController(text: stock?.companyData);
  final issuer = TextEditingController(text: stock?.issuer);
  final underlying = TextEditingController(text: stock?.underlying);
  final instrumentCurrency = TextEditingController(
    text: stock?.instrumentCurrency ?? stock?.currency ?? 'EUR',
  );
  final nominalValue = TextEditingController(
    text: stock == null ? '' : stock.nominalValue.toString(),
  );
  final couponRate = TextEditingController(
    text: stock == null ? '' : stock.couponRate.toString(),
  );
  final strikePrice = TextEditingController(
    text: stock == null ? '' : stock.strikePrice.toString(),
  );
  final knockOutBarrier = TextEditingController(
    text: stock == null ? '' : stock.knockOutBarrier.toString(),
  );
  final leverage = TextEditingController(
    text: stock == null ? '' : stock.leverage.toString(),
  );
  final subscriptionRatio = TextEditingController(
    text: stock == null ? '' : stock.subscriptionRatio.toString(),
  );
  final dividendPerShare = TextEditingController(
    text: stock == null ? '0' : stock.dividendPerShare.toString(),
  );
  var assetType = stock?.assetType ?? supportedPortfolioAssetClasses.first;
  var instrumentSubtype = stock?.instrumentSubtype.isNotEmpty == true
      ? stock!.instrumentSubtype
      : 'Knock-Out';
  var positionDirection = stock?.positionDirection.isNotEmpty == true
      ? stock!.positionDirection
      : 'Long';
  var maturityDate = stock?.maturityDate;
  var dividendFrequency = stock?.dividendFrequency ?? 'jährlich';
  var dividendStartMonth = stock?.dividendStartMonth ?? 1;
  String? validationMessage;
  final rates = ref.read(countryTaxRatesProvider).valueOrNull ?? const [];
  final countries = <String>{
    ...ref
            .read(masterDataProvider)
            .valueOrNull
            ?.where((item) => item.kind == 'country')
            .map((item) => item.value) ??
        const <String>[],
    ...rates.map((rate) => rate.country),
    ...ref
            .read(stockMastersProvider)
            .valueOrNull
            ?.map((item) => item.country) ??
        const <String>[],
  }.where((value) => value.trim().isNotEmpty).toList()..sort();
  double countryRate() => withholdingTaxRateFor(country.text, rates);

  String? countryCurrency(String value) {
    final normalized = value.trim().toLowerCase();
    return rates
        .where((rate) => rate.country.trim().toLowerCase() == normalized)
        .firstOrNull
        ?.currency
        .toUpperCase();
  }

  if (country.text.trim().isNotEmpty) {
    dividendCurrency.text =
        countryCurrency(country.text) ??
        defaultCurrencyForCountry(country.text);
  }

  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final isBond = assetType == 'Anleihe';
        final isDerivative = const {
          'Derivate',
          'Hebelprodukt',
        }.contains(assetType);
        final isCrypto = assetType == 'Kryptowährung';
        final supportsDividends = const {
          'Aktie',
          'ETF',
          'Fonds',
        }.contains(assetType);
        Widget textField(
          TextEditingController controller,
          String label, {
          bool required = false,
          bool number = false,
          bool readOnly = false,
        }) => SizedBox(
          width: 285,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: number
                ? const TextInputType.numberWithOptions(decimal: true)
                : null,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              prefixIcon: readOnly
                  ? const Icon(Icons.lock_outline_rounded, size: 18)
                  : null,
            ),
            validator: (value) {
              if (required && (value?.trim().isEmpty ?? true)) {
                return 'Pflichtfeld';
              }
              if (number &&
                  value?.trim().isNotEmpty == true &&
                  parseAmount(value) == null) {
                return 'Ungültige Zahl';
              }
              return null;
            },
          ),
        );

        Widget currencyField(TextEditingController controller, String label) =>
            SizedBox(
              width: 285,
              child: SearchableDropdownButtonFormField<String>(
                key: ValueKey('$label-${controller.text}'),
                initialValue: controller.text.toUpperCase(),
                isExpanded: true,
                decoration: InputDecoration(labelText: '$label *'),
                items: supportedIsoCurrencies
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => controller.text = value ?? 'EUR',
              ),
            );

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(
            stock == null
                ? 'Portfolio-Stammdaten anlegen'
                : 'Portfolio-Stammdaten bearbeiten',
          ),
          content: SizedBox(
            width: 650,
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 285,
                      child: SearchableDropdownButtonFormField<String>(
                        initialValue: assetType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Anlageklasse *',
                        ),
                        items: supportedPortfolioAssetClasses
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: stock == null
                            ? (value) => setDialogState(() {
                                assetType = value ?? assetType;
                                validationMessage = null;
                              })
                            : null,
                      ),
                    ),
                    textField(name, 'Name', required: true),
                    textField(
                      symbol,
                      isCrypto ? 'Symbol' : 'Symbol / Ticker',
                      required: true,
                    ),
                    if (!isCrypto) textField(isin, 'ISIN', required: true),
                    if (!isCrypto) textField(wkn, 'WKN'),
                    currencyField(currency, 'Kurswährung'),
                    textField(exchange, 'Börse / Handelsplatz'),
                    textField(broker, 'Broker'),
                    if (!isCrypto) textField(sector, 'Branche / Sektor'),
                    SizedBox(
                      width: 285,
                      child: SearchableDropdownButtonFormField<String>(
                        key: ValueKey('country-${country.text}'),
                        initialValue: countries.contains(country.text)
                            ? country.text
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Land *',
                          helperText:
                              'Quellensteuer: ${countryRate().toStringAsFixed(2)} %',
                        ),
                        items: countries
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? 'Pflichtfeld'
                            : null,
                        onChanged: (value) => setDialogState(() {
                          country.text = value ?? '';
                          dividendCurrency.text =
                              countryCurrency(value ?? '') ??
                              defaultCurrencyForCountry(value);
                        }),
                      ),
                    ),
                    if (isBond || isDerivative)
                      textField(issuer, 'Emittent', required: isDerivative),
                    if (isDerivative) ...[
                      SizedBox(
                        width: 285,
                        child: SearchableDropdownButtonFormField<String>(
                          initialValue: instrumentSubtype,
                          decoration: const InputDecoration(
                            labelText: 'Produkttyp',
                          ),
                          items: const ['Knock-Out', 'Optionsschein', 'Faktor']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setDialogState(
                            () =>
                                instrumentSubtype = value ?? instrumentSubtype,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 285,
                        child: SearchableDropdownButtonFormField<String>(
                          initialValue: positionDirection,
                          decoration: const InputDecoration(
                            labelText: 'Richtung / Optionsart',
                          ),
                          items: const ['Long', 'Short', 'Call', 'Put']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              positionDirection = value ?? positionDirection,
                        ),
                      ),
                      textField(underlying, 'Basiswert', required: true),
                    ],
                    if (isBond || isDerivative)
                      currencyField(instrumentCurrency, 'Produktwährung'),
                    if (isBond) ...[
                      textField(nominalValue, 'Nennwert', number: true),
                      textField(couponRate, 'Kupon in %', number: true),
                    ],
                    if (isDerivative) ...[
                      if (instrumentSubtype == 'Optionsschein')
                        textField(strikePrice, 'Basispreis', number: true),
                      if (instrumentSubtype == 'Knock-Out')
                        textField(
                          knockOutBarrier,
                          'Knock-Out-Schwelle',
                          number: true,
                        ),
                      textField(leverage, 'Hebel / Faktor', number: true),
                      if (instrumentSubtype != 'Faktor')
                        textField(
                          subscriptionRatio,
                          'Bezugsverhältnis',
                          number: true,
                        ),
                    ],
                    if (isBond ||
                        (isDerivative && instrumentSubtype == 'Optionsschein'))
                      SizedBox(
                        width: 285,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: now,
                              lastDate: DateTime(now.year + 100),
                              initialDate:
                                  maturityDate ??
                                  DateTime(now.year + 1, now.month, now.day),
                            );
                            if (selected != null) {
                              setDialogState(() => maturityDate = selected);
                            }
                          },
                          icon: const Icon(Icons.event_rounded),
                          label: Text(
                            maturityDate == null
                                ? 'Fälligkeit / Laufzeit'
                                : DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(maturityDate!),
                          ),
                        ),
                      ),
                    if (supportsDividends) ...[
                      textField(
                        dividendCurrency,
                        'Dividendenwährung',
                        required: true,
                        readOnly: true,
                      ),
                      SizedBox(
                        width: 285,
                        child: SearchableDropdownButtonFormField<String>(
                          initialValue: dividendFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Auszahlungsrhythmus *',
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
                          onChanged: (value) =>
                              dividendFrequency = value ?? dividendFrequency,
                        ),
                      ),
                      SizedBox(
                        width: 285,
                        child: SearchableDropdownButtonFormField<int>(
                          initialValue: dividendStartMonth,
                          decoration: const InputDecoration(
                            labelText: 'Startmonat *',
                          ),
                          items: List.generate(
                            12,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(monthNames[index]),
                            ),
                          ),
                          onChanged: (value) =>
                              dividendStartMonth = value ?? dividendStartMonth,
                        ),
                      ),
                      textField(
                        dividendPerShare,
                        'Dividende je Stück / Ausschüttung',
                        required: true,
                        number: true,
                      ),
                    ],
                    textField(companyData, 'Optionale Zusatzdaten'),
                    if (validationMessage != null)
                      SizedBox(
                        width: 590,
                        child: Text(
                          validationMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
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
                if (!(key.currentState?.validate() ?? false)) return;
                final error = portfolioMasterValidationError(
                  assetType: assetType,
                  name: name.text,
                  country: country.text,
                  symbol: symbol.text,
                  isin: isin.text,
                  wkn: wkn.text,
                  instrumentSubtype: instrumentSubtype,
                  issuer: issuer.text,
                  underlying: underlying.text,
                );
                if (error != null) {
                  setDialogState(() => validationMessage = error);
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    ),
  );
  if (saved == true) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    try {
      await ref
          .read(databaseProvider)
          .saveStockMaster(
            userId,
            StockMastersCompanion.insert(
              id: stock?.id ?? const Uuid().v4(),
              name: name.text.trim(),
              assetType: Value(assetType),
              symbol: symbol.text.trim().toUpperCase(),
              isin: Value(isin.text.trim().toUpperCase()),
              wkn: Value(wkn.text.trim().toUpperCase()),
              instrumentSubtype: Value(
                const {'Derivate', 'Hebelprodukt'}.contains(assetType)
                    ? instrumentSubtype
                    : '',
              ),
              positionDirection: Value(
                const {'Derivate', 'Hebelprodukt'}.contains(assetType)
                    ? positionDirection
                    : '',
              ),
              issuer: Value(issuer.text.trim()),
              underlying: Value(underlying.text.trim()),
              instrumentCurrency: Value(
                instrumentCurrency.text.trim().toUpperCase(),
              ),
              nominalValue: Value(parseAmount(nominalValue.text) ?? 0),
              couponRate: Value(parseAmount(couponRate.text) ?? 0),
              maturityDate: Value(maturityDate),
              strikePrice: Value(parseAmount(strikePrice.text) ?? 0),
              knockOutBarrier: Value(parseAmount(knockOutBarrier.text) ?? 0),
              leverage: Value(parseAmount(leverage.text) ?? 0),
              subscriptionRatio: Value(
                parseAmount(subscriptionRatio.text) ?? 0,
              ),
              currency: Value(currency.text.trim().toUpperCase()),
              dividendCurrency: Value(
                dividendCurrency.text.trim().toUpperCase(),
              ),
              country: Value(country.text.trim()),
              exchange: Value(exchange.text.trim()),
              broker: Value(broker.text.trim()),
              sector: Value(sector.text.trim()),
              dividendFrequency: Value(dividendFrequency),
              dividendStartMonth: Value(dividendStartMonth),
              dividendPerShare: Value(parseAmount(dividendPerShare.text) ?? 0),
              companyData: Value(companyData.text.trim()),
              createdAt: stock?.createdAt ?? now,
              updatedAt: now,
            ),
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    }
  }
  for (final controller in [
    name,
    symbol,
    isin,
    wkn,
    currency,
    dividendCurrency,
    country,
    exchange,
    broker,
    sector,
    companyData,
    issuer,
    underlying,
    instrumentCurrency,
    nominalValue,
    couponRate,
    strikePrice,
    knockOutBarrier,
    leverage,
    subscriptionRatio,
    dividendPerShare,
  ]) {
    controller.dispose();
  }
}
