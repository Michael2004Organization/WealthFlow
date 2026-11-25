import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/amount_input.dart';
import 'package:wealthflow_core/finance/currencies.dart';
import 'package:wealthflow_core/finance/withholding_tax_defaults.dart';
import 'package:wealthflow_core/finance/portfolio_master_data.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
part 'administration_stock_editor.dart';
part 'administration_error_logs.dart';
part 'administration_tax.dart';

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
          const PageHeader(title: 'Benutzerverwaltung'),
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
