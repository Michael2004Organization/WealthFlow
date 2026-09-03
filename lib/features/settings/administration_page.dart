import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/currencies.dart';
import '../../core/finance/portfolio_master_data.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class AdministrationPage extends ConsumerWidget {
  const AdministrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAdminProvider)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Nur für Administratoren',
            message:
                'Benutzerrollen und die gemeinsamen Portfolio-Stammdaten sind geschützt.',
          ),
        ),
      );
    }
    return const DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.group_outlined), text: 'Benutzer'),
              Tab(
                icon: Icon(Icons.candlestick_chart_rounded),
                text: 'Portfolio-Stammdaten',
              ),
              Tab(icon: Icon(Icons.percent_rounded), text: 'Steuern'),
              Tab(icon: Icon(Icons.error_outline_rounded), text: 'Fehlerlogs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _UsersAdmin(),
                _StocksAdmin(),
                _TaxAdmin(),
                _ErrorLogsAdmin(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersAdmin extends ConsumerWidget {
  const _UsersAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentId = ref.watch(currentUserIdProvider);
    return users.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (items) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const PageHeader(
            title: 'Benutzerverwaltung',
            subtitle:
                'Mitglieder verwalten ihre eigenen Finanzdaten. Administratoren verwalten zusätzlich Rollen und globale Portfolio-Stammdaten.',
          ),
          for (final user in items)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.displayName[0].toUpperCase()),
                ),
                title: Text(user.displayName),
                subtitle: Text(
                  user.email + (user.id == currentId ? ' · Du' : ''),
                ),
                trailing: SizedBox(
                  width: 150,
                  child: SearchableDropdownButtonFormField<String>(
                    initialValue: user.role,
                    decoration: const InputDecoration(labelText: 'Rolle'),
                    items: const [
                      DropdownMenuItem(
                        value: 'member',
                        child: Text('Mitglied'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: user.id == currentId
                        ? null
                        : (role) {
                            if (role != null) {
                              ref
                                  .read(databaseProvider)
                                  .updateUserRole(
                                    actorUserId: currentId!,
                                    userId: user.id,
                                    role: role,
                                  );
                            }
                          },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StocksAdmin extends ConsumerStatefulWidget {
  const _StocksAdmin();

  @override
  ConsumerState<_StocksAdmin> createState() => _StocksAdminState();
}

class _StocksAdminState extends ConsumerState<_StocksAdmin> {
  String _assetType = 'Alle';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stocks = ref.watch(stockMastersProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Portfolio-Stammdaten',
            subtitle:
                'Gemeinsamer, deduplizierter Katalog nach fester Anlageklasse.',
            action: FilledButton.icon(
              onPressed: () => _editStock(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Stammdaten'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 240,
                child: SearchableDropdownButtonFormField<String>(
                  initialValue: _assetType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Anlageklasse',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: ['Alle', ...supportedPortfolioAssetClasses]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _assetType = value ?? _assetType),
                ),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Suchen',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: stocks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) {
                final filtered = items.where((item) {
                  final haystack = [
                    item.name,
                    item.symbol,
                    item.isin,
                    item.wkn,
                    item.issuer,
                    item.underlying,
                  ].join(' ').toLowerCase();
                  return (_assetType == 'Alle' ||
                          item.assetType == _assetType) &&
                      haystack.contains(_query);
                }).toList();
                return filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.candlestick_chart_outlined,
                        title: 'Keine passenden Portfolio-Stammdaten',
                        message:
                            'Lege das Instrument zentral an oder passe den Filter an.',
                        action: FilledButton.icon(
                          onPressed: () => _editStock(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Stammdaten anlegen'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final stock = filtered[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (stock.symbol.isEmpty
                                          ? stock.name
                                          : stock.symbol)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text(stock.name),
                              subtitle: Text(
                                [
                                      stock.symbol,
                                      stock.isin,
                                      stock.instrumentSubtype,
                                      stock.underlying,
                                      stock.exchange,
                                      stock.currency,
                                      stock.sector,
                                    ]
                                    .where((value) => value.isNotEmpty)
                                    .join(' · '),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Bearbeiten',
                                    onPressed: () =>
                                        _editStock(context, ref, stock: stock),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Löschen',
                                    onPressed: () async {
                                      if (await confirmDelete(
                                        context,
                                        title:
                                            'Portfolio-Stammdaten entfernen?',
                                        message:
                                            '${stock.name} wird nicht mehr zur Auswahl angeboten.',
                                      )) {
                                        final userId = ref.read(
                                          currentUserIdProvider,
                                        );
                                        if (userId != null) {
                                          await ref
                                              .read(databaseProvider)
                                              .deleteStockMaster(
                                                userId,
                                                stock.id,
                                              );
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxAdmin extends ConsumerWidget {
  const _TaxAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates =
        ref.watch(countryTaxRatesProvider).valueOrNull ??
        const <CountryTaxRate>[];
    final configuration = ref.watch(appConfigurationProvider).valueOrNull;
    final accountCurrency =
        ref.watch(preferencesProvider).valueOrNull?.currency.toUpperCase() ??
        'EUR';
    return FutureBuilder<List<String>>(
      future: ref.read(databaseProvider).availableCountries(),
      builder: (context, snapshot) {
        final countries = snapshot.data ?? const <String>[];
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PageHeader(
              title: 'Steuerregeln',
              subtitle:
                  'Quellensteuern gelten global nach Herkunftsland. Ohne Eintrag gelten 0 %, für die USA standardmäßig 15 %.',
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
            for (final country in countries)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Quellensteuer bearbeiten',
                            onPressed: () => _editCountryTax(
                              context,
                              ref,
                              country,
                              _countryRate(country, rates),
                              rates
                                  .where(
                                    (item) =>
                                        normalizeCountry(item.country) ==
                                        normalizeCountry(country),
                                  )
                                  .firstOrNull,
                            ),
                            icon: const Icon(Icons.percent_rounded),
                          ),
                          IconButton(
                            tooltip: 'Wechselkurs bearbeiten',
                            onPressed: () => _editAdminCountryExchange(
                              context,
                              ref,
                              country,
                              accountCurrency,
                              rates
                                  .where(
                                    (item) =>
                                        normalizeCountry(item.country) ==
                                        normalizeCountry(country),
                                  )
                                  .firstOrNull,
                            ),
                            icon: const Icon(Icons.currency_exchange_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _TaxFact(
                            label: 'Länderwährung',
                            value: _countryCurrency(country, rates),
                          ),
                          _TaxFact(
                            label: 'Quellensteuer',
                            value:
                                '${_countryRate(country, rates).toStringAsFixed(2)} %',
                          ),
                          _TaxFact(
                            label:
                                'Wechselkurs · $accountCurrency (Kontowährung)',
                            value:
                                '1 ${_countryCurrency(country, rates)} = '
                                '${_countryExchangeRate(country, rates).toStringAsFixed(6)} $accountCurrency',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _countryRate(String country, List<CountryTaxRate> rates) {
    final stored = rates
        .where(
          (rate) =>
              rate.country.trim().toLowerCase() == country.trim().toLowerCase(),
        )
        .firstOrNull;
    if (stored != null) return stored.withholdingTaxRate;
    final normalized = country.trim().toLowerCase();
    return normalized == 'usa' ||
            normalized == 'us' ||
            normalized.contains('united states') ||
            normalized.contains('vereinigte staat')
        ? 15
        : 0;
  }

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
  var allowManual = current?.allowManualExchangeRate ?? true;
  final userId = ref.read(currentUserIdProvider);
  final hasApiKey = userId == null
      ? false
      : (await ref.read(secureSessionStoreProvider).readExchangeApiKey(userId))
                ?.isNotEmpty ??
            false;
  if (!context.mounted) return;
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
                      readOnly: hasApiKey && !allowManual,
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
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Manuelle Eingabe erlauben'),
                subtitle: Text(
                  hasApiKey
                      ? 'Bei Deaktivierung liefert ausschließlich die API den Kurs.'
                      : 'Wirkt, sobald ein Wechselkurs-API-Key hinterlegt ist.',
                ),
                value: allowManual,
                onChanged: (value) => setState(() => allowManual = value),
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
            onPressed: hasApiKey && !allowManual
                ? () => Navigator.pop(dialogContext, true)
                : () {
                    final parsed = double.tryParse(
                      rate.text.replaceAll(',', '.'),
                    );
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
          exchangeRate:
              double.tryParse(rate.text.replaceAll(',', '.')) ??
              current?.exchangeRate ??
              1,
          allowManualExchangeRate: allowManual,
        );
  }
  currency.dispose();
  rate.dispose();
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
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
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
            rate: double.parse(controller.text.replaceAll(',', '.')),
            currency: currency,
          );
    }
  }
  controller.dispose();
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
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
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
            rate: double.parse(rate.text.replaceAll(',', '.')),
            currency: currency,
          );
    }
  }
  country.dispose();
  rate.dispose();
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
            final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
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
            amount: double.parse(controller.text.replaceAll(',', '.')),
          );
    }
  }
  controller.dispose();
}

class _ErrorLogsAdmin extends ConsumerWidget {
  const _ErrorLogsAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(errorLogsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Fehlerprotokoll',
            subtitle:
                'Unbehandelte Flutter-, Plattform- und Hintergrundfehler.',
            action: OutlinedButton.icon(
              onPressed: () async {
                final actor = ref.read(currentUserIdProvider);
                if (actor != null) {
                  await ref.read(databaseProvider).clearErrorLogs(actor);
                }
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Leeren'),
            ),
          ),
          Expanded(
            child: logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Keine Fehler protokolliert',
                      message: 'Aktuell liegen keine Anwendungsfehler vor.',
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final log = items[index];
                        return Card(
                          child: ExpansionTile(
                            leading: const Icon(Icons.error_outline_rounded),
                            title: Text(
                              _errorUserSummary(log),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_errorArea(log)} · ${log.source} · '
                              '${DateFormat('dd.MM.yyyy HH:mm:ss').format(log.occurredAt.toLocal())}',
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Technische Meldung',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              SelectableText(log.message),
                              if (log.details.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SelectableText(log.details),
                                ),
                              if (log.stackTrace.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SelectableText(
                                  log.stackTrace,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: _copyableError(log)),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Fehler wurde kopiert.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy_rounded),
                                  label: const Text('Fehler kopieren'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

String _errorArea(AppErrorLog log) {
  final technical = '${log.details}\n${log.stackTrace}'.toLowerCase();
  const areas = <String, String>{
    'statistics_page.dart': 'Statistik',
    'dashboard_page.dart': 'Übersicht',
    'household_page.dart': 'Haushaltsbuch',
    'investments_page.dart': 'Portfolio',
    'dividends_page.dart': 'Dividenden',
    'administration_page.dart': 'Administration',
    'vehicles_page.dart': 'Fahrzeuge',
    'accounts_page.dart': 'Konten',
  };
  for (final entry in areas.entries) {
    if (technical.contains(entry.key)) return entry.value;
  }
  return 'Anwendung';
}

String _errorUserSummary(AppErrorLog log) {
  final technical = '${log.message}\n${log.details}\n${log.stackTrace}'
      .toLowerCase();
  final area = _errorArea(log);
  if (technical.contains('date_format') ||
      technical.contains('localeexists') ||
      technical.contains('intl')) {
    return '$area: Ein Datum konnte nicht angezeigt werden.';
  }
  if (technical.contains('database') || technical.contains('drift')) {
    return '$area: Daten konnten nicht gelesen oder gespeichert werden.';
  }
  if (technical.contains('overflow')) {
    return '$area: Ein Inhalt passte nicht in den verfügbaren Platz.';
  }
  if (technical.contains('network') ||
      technical.contains('socket') ||
      technical.contains('http')) {
    return '$area: Eine Netzwerkabfrage ist fehlgeschlagen.';
  }
  return '$area: Ein unerwarteter Fehler ist aufgetreten.';
}

String _copyableError(AppErrorLog log) =>
    'Kurzbeschreibung: ${_errorUserSummary(log)}\n'
    'Bereich: ${_errorArea(log)}\n'
    'Quelle: ${log.source}\n'
    'Zeitpunkt: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(log.occurredAt.toLocal())}\n'
    'Meldung: ${log.message}\n'
    '${log.details.isEmpty ? '' : 'Details: ${log.details}\n'}'
    '${log.stackTrace.isEmpty ? '' : 'Stacktrace:\n${log.stackTrace}'}';

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
  double countryRate() {
    final normalized = country.text.trim().toLowerCase();
    return rates
            .where((rate) => rate.country.trim().toLowerCase() == normalized)
            .firstOrNull
            ?.withholdingTaxRate ??
        (const {
              'usa',
              'us',
              'united states',
              'vereinigte staaten',
            }.contains(normalized)
            ? 15
            : 0);
  }

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
                  double.tryParse(value!.replaceAll(',', '.')) == null) {
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
                      required: isCrypto,
                    ),
                    if (!isCrypto) textField(isin, 'ISIN'),
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
                              child: Text(_adminMonthNames[index]),
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
              nominalValue: Value(
                double.tryParse(nominalValue.text.replaceAll(',', '.')) ?? 0,
              ),
              couponRate: Value(
                double.tryParse(couponRate.text.replaceAll(',', '.')) ?? 0,
              ),
              maturityDate: Value(maturityDate),
              strikePrice: Value(
                double.tryParse(strikePrice.text.replaceAll(',', '.')) ?? 0,
              ),
              knockOutBarrier: Value(
                double.tryParse(knockOutBarrier.text.replaceAll(',', '.')) ?? 0,
              ),
              leverage: Value(
                double.tryParse(leverage.text.replaceAll(',', '.')) ?? 0,
              ),
              subscriptionRatio: Value(
                double.tryParse(subscriptionRatio.text.replaceAll(',', '.')) ??
                    0,
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
              dividendPerShare: Value(
                double.tryParse(dividendPerShare.text.replaceAll(',', '.')) ??
                    0,
              ),
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

const _adminMonthNames = [
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
