import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(icon: Icon(Icons.group_outlined), text: 'Benutzer'),
              Tab(
                icon: Icon(Icons.candlestick_chart_rounded),
                text: 'Aktien-Stammdaten',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(children: [_UsersAdmin(), _StocksAdmin()]),
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

Future<void> _editStock(
  BuildContext context,
  WidgetRef ref, {
  StockMaster? stock,
}) async {
  final name = TextEditingController(text: stock?.name);
  final symbol = TextEditingController(text: stock?.symbol);
  final isin = TextEditingController(text: stock?.isin);
  final currency = TextEditingController(text: stock?.currency ?? 'EUR');
  final country = TextEditingController(text: stock?.country);
  final exchange = TextEditingController(text: stock?.exchange);
  final sector = TextEditingController(text: stock?.sector);
  final companyData = TextEditingController(text: stock?.companyData);
  final key = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
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
                  (currency, 'Währung', true),
                  (country, 'Land', false),
                  (exchange, 'Börse', false),
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
            currency: Value(currency.text.trim().toUpperCase()),
            country: Value(country.text.trim()),
            exchange: Value(exchange.text.trim()),
            sector: Value(sector.text.trim()),
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
    currency,
    country,
    exchange,
    sector,
    companyData,
  ]) {
    controller.dispose();
  }
}
