part of 'administration_page.dart';

class _TaxAdmin extends ConsumerStatefulWidget {
  const _TaxAdmin();

  @override
  ConsumerState<_TaxAdmin> createState() => _TaxAdminState();
}

class _TaxAdminState extends ConsumerState<_TaxAdmin> {
  final _search = TextEditingController();
  final Set<String> _favorites = {};
  String? _loadedForUser;
  bool _onlyFavorites = false;
  Future<List<String>>? _countries;
  List<CountryTaxRate>? _countriesForRates;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rates =
        ref.watch(countryTaxRatesProvider).valueOrNull ??
        const <CountryTaxRate>[];
    final configuration = ref.watch(appConfigurationProvider).valueOrNull;
    final accountCurrency =
        ref.watch(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
        'EUR';
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null && userId != _loadedForUser) {
      _loadedForUser = userId;
      _loadFavorites(userId);
    }
    // Only reload the country list when the tax rates change, not on every
    // keystroke in the search field.
    if (_countries == null || !identical(_countriesForRates, rates)) {
      _countriesForRates = rates;
      _countries = ref.read(databaseProvider).availableCountries();
    }
    return FutureBuilder<List<String>>(
      future: _countries,
      builder: (context, snapshot) {
        final countries = snapshot.data ?? const <String>[];
        final query = _search.text.trim().toLowerCase();
        final matches = countries.where((country) {
          if (_onlyFavorites && !_isFavorite(country)) return false;
          if (query.isEmpty) return true;
          return country.toLowerCase().contains(query) ||
              _countryCurrency(country, rates).toLowerCase().contains(query);
        }).toList();
        final pinned = matches.where(_isFavorite).toList();
        final others = matches.where((c) => !_isFavorite(c)).toList();
        Widget card(String country) => _countryCard(
          context,
          country: country,
          rates: rates,
          accountCurrency: accountCurrency,
        );
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PageHeader(
              title: 'Steuerregeln',
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _addCountryTax(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Land hinzufügen'),
                  ),
                  OutlinedButton.icon(
                    onPressed: configuration == null
                        ? null
                        : () => _editMaximumAllowance(
                            context,
                            ref,
                            configuration.maximumTaxAllowance,
                          ),
                    icon: const Icon(Icons.savings_outlined),
                    label: Text(
                      'Freibetrag max. ${money(configuration?.maximumTaxAllowance ?? 1000)}',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Land oder Währung suchen',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Suche leeren',
                                onPressed: () =>
                                    setState(() => _search.clear()),
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                  FilterChip(
                    avatar: Icon(
                      _onlyFavorites
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: 18,
                    ),
                    label: Text('Nur Favoriten (${_favoriteCount(countries)})'),
                    selected: _onlyFavorites,
                    showCheckmark: false,
                    onSelected: (value) =>
                        setState(() => _onlyFavorites = value),
                  ),
                ],
              ),
            ),
            if (snapshot.hasData && matches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _onlyFavorites && query.isEmpty
                      ? 'Noch keine Favoriten. Über die Pinnadel an einem Land kannst du es oben anheften.'
                      : 'Kein Land passt zu „${_search.text.trim()}“.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (pinned.isNotEmpty) ...[
              _TaxSectionLabel(icon: Icons.push_pin_rounded, text: 'Favoriten'),
              for (final country in pinned) card(country),
            ],
            if (others.isNotEmpty) ...[
              if (pinned.isNotEmpty)
                _TaxSectionLabel(
                  icon: Icons.public_rounded,
                  text: 'Alle Länder',
                ),
              for (final country in others) card(country),
            ],
          ],
        );
      },
    );
  }

  Widget _countryCard(
    BuildContext context, {
    required String country,
    required List<CountryTaxRate> rates,
    required String accountCurrency,
  }) {
    final configuration = rates
        .where(
          (item) => normalizeCountry(item.country) == normalizeCountry(country),
        )
        .firstOrNull;
    final favorite = _isFavorite(country);
    final currency = _countryCurrency(country, rates);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.public_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    country,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: favorite
                      ? '$country von Favoriten lösen'
                      : '$country als Favorit anheften',
                  onPressed: () => _toggleFavorite(country),
                  isSelected: favorite,
                  icon: const Icon(Icons.push_pin_outlined),
                  selectedIcon: Icon(
                    Icons.push_pin_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TaxFact(label: 'Länderwährung', value: currency),
                  _TaxFact(
                    label: 'Quellensteuer',
                    value:
                        '${_countryRate(country, rates).toStringAsFixed(2)} %',
                  ),
                  _TaxFact(
                    label: 'Wechselkurs · $accountCurrency (Kontowährung)',
                    value:
                        '1 $currency = '
                        '${_countryExchangeRate(country, rates).toStringAsFixed(6)} $accountCurrency',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 4),
            // Labelled actions inside the card, so it is always clear which
            // country a button edits.
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _editCountryTax(
                    context,
                    ref,
                    country,
                    _countryRate(country, rates),
                    configuration,
                  ),
                  icon: const Icon(Icons.percent_rounded),
                  label: const Text('Quellensteuer bearbeiten'),
                ),
                TextButton.icon(
                  onPressed: () => _editAdminCountryExchange(
                    context,
                    ref,
                    country,
                    accountCurrency,
                    configuration,
                  ),
                  icon: const Icon(Icons.currency_exchange_rounded),
                  label: const Text('Wechselkurs bearbeiten'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isFavorite(String country) =>
      _favorites.contains(normalizeCountry(country));

  int _favoriteCount(List<String> countries) =>
      countries.where(_isFavorite).length;

  Future<void> _loadFavorites(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList('admin.taxFavorites.$userId');
    if (!mounted || _loadedForUser != userId) return;
    setState(() {
      _favorites
        ..clear()
        ..addAll(stored ?? const <String>[]);
    });
  }

  Future<void> _toggleFavorite(String country) async {
    final key = normalizeCountry(country);
    setState(() {
      if (!_favorites.remove(key)) _favorites.add(key);
    });
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'admin.taxFavorites.$userId',
      _favorites.toList()..sort(),
    );
  }

  double _countryRate(String country, List<CountryTaxRate> rates) =>
      withholdingTaxRateFor(country, rates);

  String _countryCurrency(String country, List<CountryTaxRate> rates) =>
      rates
          .where(
            (rate) =>
                normalizeCountry(rate.country) == normalizeCountry(country),
          )
          .firstOrNull
          ?.currency
          .toUpperCase() ??
      defaultCurrencyForCountry(country);

  double _countryExchangeRate(String country, List<CountryTaxRate> rates) =>
      rates
          .where(
            (rate) =>
                normalizeCountry(rate.country) == normalizeCountry(country),
          )
          .firstOrNull
          ?.exchangeRate ??
      1;
}

class _TaxSectionLabel extends StatelessWidget {
  const _TaxSectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxFact extends StatelessWidget {
  const _TaxFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text.rich(
      TextSpan(
        text: '$label\n',
        style: Theme.of(context).textTheme.labelSmall,
        children: [
          TextSpan(
            text: value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

Future<void> _editAdminCountryExchange(
  BuildContext context,
  WidgetRef ref,
  String country,
  String accountCurrency,
  CountryTaxRate? current,
) async {
  final currency = TextEditingController(
    text: current?.currency ?? defaultCurrencyForCountry(country),
  );
  final rate = TextEditingController(
    text: (current?.exchangeRate ?? 1).toStringAsFixed(6),
  );
  final userId = ref.read(currentUserIdProvider);
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Wechselkurs · $country'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final fields = [
                    TextFormField(
                      controller: currency,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Länderwährung',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    TextFormField(
                      initialValue: accountCurrency,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Zielwährung (Kontowährung)',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    TextFormField(
                      controller: rate,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Kurs zur Kontowährung',
                        prefixIcon: Icon(Icons.currency_exchange_rounded),
                      ),
                    ),
                  ];
                  if (constraints.maxWidth < 520) {
                    return Column(
                      children: [
                        for (var index = 0; index < fields.length; index++) ...[
                          fields[index],
                          if (index < fields.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var index = 0; index < fields.length; index++) ...[
                        Expanded(child: fields[index]),
                        if (index < fields.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
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
              final parsed = parseAmount(rate.text);
              if (currency.text.trim().length == 3 &&
                  parsed != null &&
                  parsed > 0) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ),
  );
  if (saved == true && userId != null) {
    await ref
        .read(databaseProvider)
        .saveCountryExchangeRate(
          actorUserId: userId,
          country: country,
          currency: currency.text.trim().toUpperCase(),
          exchangeRate: parseAmount(rate.text) ?? current?.exchangeRate ?? 1,
        );
  }
  disposeAfterClose(currency);
  disposeAfterClose(rate);
}

Future<void> _editCountryTax(
  BuildContext context,
  WidgetRef ref,
  String country,
  double current,
  CountryTaxRate? configuration,
) async {
  final controller = TextEditingController(text: current.toStringAsFixed(2));
  var currency =
      configuration?.currency.toUpperCase() ??
      defaultCurrencyForCountry(country);
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Quellensteuer · $country'),
      content: StatefulBuilder(
        builder: (context, setState) => Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Steuersatz',
                  suffixText: '%',
                ),
                validator: (value) {
                  final parsed = parseAmount(value);
                  return parsed == null || parsed < 0 || parsed > 100
                      ? 'Wert zwischen 0 und 100 eingeben.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              SearchableDropdownButtonFormField<String>(
                initialValue: currency,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Landeswährung',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                items: supportedIsoCurrencies
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => currency = value ?? currency),
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
          child: const Text('Speichern'),
        ),
      ],
    ),
  );
  if (saved == true) {
    final actor = ref.read(currentUserIdProvider);
    if (actor != null) {
      await ref
          .read(databaseProvider)
          .saveCountryTaxRate(
            actorUserId: actor,
            country: country,
            rate: parseAmount(controller.text)!,
            currency: currency,
          );
    }
  }
  disposeAfterClose(controller);
}

Future<void> _addCountryTax(BuildContext context, WidgetRef ref) async {
  final country = TextEditingController();
  final rate = TextEditingController(text: '0');
  var currency = 'EUR';
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Steuerland hinzufügen'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: country,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Land'),
                onChanged: (value) =>
                    setState(() => currency = defaultCurrencyForCountry(value)),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Bitte ein Land eingeben.'
                    : null,
              ),
              const SizedBox(height: 12),
              SearchableDropdownButtonFormField<String>(
                key: ValueKey(currency),
                initialValue: currency,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Landeswährung'),
                items: supportedIsoCurrencies
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => currency = value ?? currency,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quellensteuer',
                  suffixText: '%',
                ),
                validator: (value) {
                  final parsed = parseAmount(value);
                  return parsed == null || parsed < 0 || parsed > 100
                      ? 'Wert zwischen 0 und 100 eingeben.'
                      : null;
                },
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
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    final actor = ref.read(currentUserIdProvider);
    if (actor != null) {
      await ref
          .read(databaseProvider)
          .saveCountryTaxRate(
            actorUserId: actor,
            country: country.text.trim(),
            rate: parseAmount(rate.text)!,
            currency: currency,
          );
    }
  }
  disposeAfterClose(country);
  disposeAfterClose(rate);
}

Future<void> _editMaximumAllowance(
  BuildContext context,
  WidgetRef ref,
  double current,
) async {
  final controller = TextEditingController(text: current.toStringAsFixed(2));
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Maximaler Freistellungsauftrag'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Höchstbetrag',
            suffixText: '€',
          ),
          validator: (value) {
            final parsed = parseAmount(value);
            return parsed == null || parsed < 0 ? 'Ungültiger Betrag' : null;
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
    final actor = ref.read(currentUserIdProvider);
    if (actor != null) {
      await ref
          .read(databaseProvider)
          .setMaximumTaxAllowance(
            actorUserId: actor,
            amount: parseAmount(controller.text)!,
          );
    }
  }
  disposeAfterClose(controller);
}
