import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
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
                'Benutzerrollen und der gemeinsame Aktienkatalog sind geschützt.',
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
                text: 'Aktien-Stammdaten',
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
                'Mitglieder verwalten ihre eigenen Finanzdaten. Administratoren verwalten zusätzlich Rollen und globale Aktien-Stammdaten.',
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
                  child: DropdownButtonFormField<String>(
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

class _StocksAdmin extends ConsumerWidget {
  const _StocksAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocks = ref.watch(stockMastersProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Zentraler Aktienkatalog',
            subtitle:
                'Ein gemeinsamer Pool für alle Portfolios und spätere Batch-Abfragen.',
            action: FilledButton.icon(
              onPressed: () => _editStock(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Aktie'),
            ),
          ),
          Expanded(
            child: stocks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) => items.isEmpty
                  ? EmptyState(
                      icon: Icons.candlestick_chart_outlined,
                      title: 'Noch keine Aktien-Stammdaten',
                      message:
                          'Lege Aktien einmal zentral an. Mitglieder wählen sie anschließend nach Namen aus.',
                      action: FilledButton.icon(
                        onPressed: () => _editStock(context, ref),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Erste Aktie anlegen'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final stock = items[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(stock.symbol.substring(0, 1)),
                            ),
                            title: Text(stock.name),
                            subtitle: Text(
                              [
                                stock.symbol,
                                stock.isin,
                                stock.exchange,
                                stock.currency,
                                stock.sector,
                              ].where((value) => value.isNotEmpty).join(' · '),
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
                                      title: 'Aktie entfernen?',
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
                    ),
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
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.public_rounded),
                  ),
                  title: Text(country),
                  subtitle: const Text('Quellensteuer auf Dividenden'),
                  trailing: TextButton(
                    onPressed: () => _editCountryTax(
                      context,
                      ref,
                      country,
                      _countryRate(country, rates),
                    ),
                    child: Text(
                      '${_countryRate(country, rates).toStringAsFixed(2)} %',
                    ),
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
}

Future<void> _editCountryTax(
  BuildContext context,
  WidgetRef ref,
  String country,
  double current,
) async {
  final controller = TextEditingController(text: current.toStringAsFixed(2));
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Quellensteuer · $country'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Steuersatz',
            suffixText: '%',
          ),
          validator: (value) {
            final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
            return parsed == null || parsed < 0 || parsed > 100
                ? 'Wert zwischen 0 und 100 eingeben.'
                : null;
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
          .saveCountryTaxRate(
            actorUserId: actor,
            country: country,
            rate: double.parse(controller.text.replaceAll(',', '.')),
          );
    }
  }
  controller.dispose();
}

Future<void> _addCountryTax(BuildContext context, WidgetRef ref) async {
  final country = TextEditingController();
  final rate = TextEditingController(text: '0');
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
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
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Bitte ein Land eingeben.'
                  : null,
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
                              log.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${log.source} · ${DateFormat('dd.MM.yyyy HH:mm:ss').format(log.occurredAt.toLocal())}',
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
                              if (log.details.isNotEmpty)
                                SelectableText(log.details),
                              if (log.stackTrace.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SelectableText(
                                  log.stackTrace,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
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
  var dividendFrequency = stock?.dividendFrequency ?? 'jährlich';
  var dividendStartMonth = stock?.dividendStartMonth ?? 1;
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

  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(stock == null ? 'Aktie anlegen' : 'Aktie bearbeiten'),
        content: SizedBox(
          width: 620,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final field in [
                    (name, 'Name', true),
                    (symbol, 'Symbol / Ticker', true),
                    (isin, 'ISIN', false),
                    (wkn, 'WKN', false),
                    (currency, 'Kurswährung', true),
                    (dividendCurrency, 'Dividendenwährung', true),
                    (exchange, 'Börse', false),
                    (broker, 'Broker', false),
                    (sector, 'Branche / Sektor', false),
                    (companyData, 'Optionale Unternehmensdaten', false),
                  ])
                    SizedBox(
                      width: 285,
                      child: TextFormField(
                        controller: field.$1,
                        decoration: InputDecoration(labelText: field.$2),
                        validator: field.$3
                            ? (value) => (value?.trim().isEmpty ?? true)
                                  ? 'Pflichtfeld'
                                  : null
                            : null,
                      ),
                    ),
                  SizedBox(
                    width: 285,
                    child: TextFormField(
                      controller: country,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Land',
                        helperText:
                            'Quellensteuer: ${countryRate().toStringAsFixed(2)} %',
                        suffixIcon: PopupMenuButton<String>(
                          tooltip: 'Land auswählen',
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          onSelected: (value) => setDialogState(() {
                            country.text = value;
                            country.selection = TextSelection.collapsed(
                              offset: value.length,
                            );
                          }),
                          itemBuilder: (_) => countries
                              .map(
                                (value) => PopupMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 285,
                    child: DropdownButtonFormField<String>(
                      initialValue: dividendFrequency,
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
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => setDialogState(
                        () => dividendFrequency = value ?? dividendFrequency,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 285,
                    child: DropdownButtonFormField<int>(
                      initialValue: dividendStartMonth,
                      decoration: const InputDecoration(
                        labelText: 'Startmonat',
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_adminMonthNames[index]),
                        ),
                      ),
                      onChanged: (value) => setDialogState(
                        () => dividendStartMonth = value ?? dividendStartMonth,
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
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    await ref
        .read(databaseProvider)
        .saveStockMaster(
          userId,
          StockMastersCompanion.insert(
            id: stock?.id ?? const Uuid().v4(),
            name: name.text.trim(),
            symbol: symbol.text.trim().toUpperCase(),
            isin: Value(isin.text.trim().toUpperCase()),
            wkn: Value(wkn.text.trim().toUpperCase()),
            currency: Value(currency.text.trim().toUpperCase()),
            dividendCurrency: Value(dividendCurrency.text.trim().toUpperCase()),
            country: Value(country.text.trim()),
            exchange: Value(exchange.text.trim()),
            broker: Value(broker.text.trim()),
            sector: Value(sector.text.trim()),
            dividendFrequency: Value(dividendFrequency),
            dividendStartMonth: Value(dividendStartMonth),
            companyData: Value(companyData.text.trim()),
            createdAt: stock?.createdAt ?? now,
            updatedAt: now,
          ),
        );
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
