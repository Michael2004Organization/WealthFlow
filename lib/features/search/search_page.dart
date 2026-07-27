import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String _query = '';
  String _type = 'Alle';

  @override
  Widget build(BuildContext context) {
    final results = _results(ref);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Globale Suche',
                subtitle:
                    'Durchsuche Konten, Portfolio, Buchungen und Fahrzeuge.',
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 420,
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        labelText: 'Suchbegriff',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Datentyp'),
                      items:
                          const [
                                'Alle',
                                'Konten',
                                'Portfolio',
                                'Buchungen',
                                'Fahrzeuge',
                              ]
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
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _query.isEmpty
                    ? const EmptyState(
                        icon: Icons.manage_search_rounded,
                        title: 'Was suchst du?',
                        message:
                            'Gib einen Namen, ein Symbol, eine Kategorie, einen Händler oder ein Kennzeichen ein.',
                      )
                    : results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Keine Treffer',
                        message:
                            'Prüfe den Suchbegriff oder ändere den Filter.',
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(result.icon)),
                              title: Text(
                                result.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${result.type} · ${result.subtitle}',
                              ),
                              trailing: result.value == null
                                  ? null
                                  : Text(
                                      result.value!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              onTap: () =>
                                  ref.read(shellIndexProvider.notifier).state =
                                      result.shellIndex,
                            ),
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

  List<_SearchResult> _results(WidgetRef ref) {
    if (_query.isEmpty) return const [];
    final output = <_SearchResult>[];
    bool matchesType(String type) => _type == 'Alle' || _type == type;
    if (matchesType('Konten')) {
      for (final item in ref.watch(accountsProvider).valueOrNull ?? const []) {
        if ('${item.bankName} ${item.label} ${item.holder} ${item.iban}'
            .toLowerCase()
            .contains(_query)) {
          output.add(
            _SearchResult(
              type: 'Konten',
              title: item.label,
              subtitle: item.bankName,
              value: money(item.balance, currency: item.currency),
              icon: Icons.account_balance_rounded,
              shellIndex: 1,
            ),
          );
        }
      }
    }
    if (matchesType('Portfolio')) {
      for (final item
          in ref.watch(investmentsProvider).valueOrNull ?? const []) {
        if ('${item.name} ${item.symbol} ${item.isin} ${item.wkn} ${item.broker} ${item.sector}'
            .toLowerCase()
            .contains(_query)) {
          output.add(
            _SearchResult(
              type: 'Portfolio',
              title: item.name,
              subtitle: '${item.assetType} · ${item.symbol}',
              value: money(item.quantity * item.currentPrice),
              icon: Icons.candlestick_chart_rounded,
              shellIndex: 1,
            ),
          );
        }
      }
    }
    if (matchesType('Buchungen')) {
      for (final item
          in ref.watch(ledgerEntriesProvider).valueOrNull ?? const []) {
        if ('${item.merchant} ${item.description} ${item.category} ${item.paymentMethod}'
            .toLowerCase()
            .contains(_query)) {
          output.add(
            _SearchResult(
              type: 'Buchungen',
              title: item.merchant.isEmpty ? item.description : item.merchant,
              subtitle:
                  '${item.category} · ${DateFormat('dd.MM.yyyy').format(item.bookingDate)}',
              value: '${item.isIncome ? '+' : '−'}${money(item.amount)}',
              icon: Icons.receipt_long_rounded,
              shellIndex: 2,
            ),
          );
        }
      }
    }
    if (matchesType('Fahrzeuge')) {
      for (final item in ref.watch(vehiclesProvider).valueOrNull ?? const []) {
        if ('${item.make} ${item.model} ${item.licensePlate} ${item.fuelType}'
            .toLowerCase()
            .contains(_query)) {
          output.add(
            _SearchResult(
              type: 'Fahrzeuge',
              title: '${item.make} ${item.model}',
              subtitle: '${item.vehicleType} · ${item.licensePlate}',
              icon: item.vehicleType == 'Motorrad'
                  ? Icons.two_wheeler_rounded
                  : Icons.directions_car_rounded,
              shellIndex: 4,
            ),
          );
        }
      }
    }
    return output.take(100).toList();
  }
}

class _SearchResult {
  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.shellIndex,
    this.value,
  });
  final String type;
  final String title;
  final String subtitle;
  final String? value;
  final IconData icon;
  final int shellIndex;
}
