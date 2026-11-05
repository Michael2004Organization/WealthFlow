part of '../investments_page.dart';

Future<void> _showExchangeRates(BuildContext context, WidgetRef ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  final database = ref.read(databaseProvider);
  final countries = await database.availableCountries();
  final rates =
      ref.read(countryTaxRatesProvider).valueOrNull ?? const <CountryTaxRate>[];
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
                    onSave: ({required currency, required exchangeRate}) =>
                        database.saveCountryExchangeRate(
                          actorUserId: userId,
                          country: country,
                          currency: currency,
                          exchangeRate: exchangeRate,
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
    required this.onSave,
  });

  final String country;
  final String baseCurrency;
  final String initialCurrency;
  final double initialRate;
  final Future<void> Function({
    required String currency,
    required double exchangeRate,
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
  bool _saving = false;

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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Kurs zu ${widget.baseCurrency}',
            ),
          ),
        ),
        IconButton(
          tooltip: 'Wechselkurs speichern',
          onPressed: _saving
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
