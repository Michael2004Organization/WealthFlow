import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../calculators/calculators_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../settings/master_data_page.dart';
import '../vehicles/vehicles_page.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});
  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  static const _destinations = [
    _MoreDestination(
      'vehicles',
      'Fahrzeuge',
      'Autos, Motorräder und Kosten',
      Icons.directions_car_rounded,
      Colors.blue,
      VehiclesPage(),
    ),
    _MoreDestination(
      'calculators',
      'Rechner',
      'Zinseszins, Entnahme und Fahrten',
      Icons.calculate_rounded,
      Colors.teal,
      CalculatorsPage(),
    ),
    _MoreDestination(
      'search',
      'Globale Suche',
      'Alle Daten zentral durchsuchen',
      Icons.manage_search_rounded,
      Colors.purple,
      SearchPage(),
    ),
    _MoreDestination(
      'masterData',
      'Stammdaten',
      'Händler, Zahlungsarten und Vorschläge',
      Icons.list_alt_rounded,
      Colors.indigo,
      MasterDataPage(),
    ),
    _MoreDestination(
      'settings',
      'Account',
      'Profil, Darstellung und Server',
      Icons.settings_rounded,
      Colors.orange,
      SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedKey = ref.watch(moreDestinationProvider);
    _MoreDestination? selected;
    for (final destination in _destinations) {
      if (destination.key == selectedKey) selected = destination;
    }
    if (selected != null) {
      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: ListTile(
                leading: IconButton(
                  onPressed: () =>
                      ref.read(moreDestinationProvider.notifier).state = null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Zurück',
                ),
                title: Text(
                  selected.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          Expanded(child: selected.page),
        ],
      );
    }
    final destinations = _destinations;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Mehr',
                subtitle: 'Werkzeuge und Einstellungen für WealthFlow.',
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 650
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final destination in destinations)
                        SizedBox(
                          width: width,
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () =>
                                  ref
                                      .read(moreDestinationProvider.notifier)
                                      .state = destination
                                      .key,
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: destination.color.withValues(
                                          alpha: .14,
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Icon(
                                        destination.icon,
                                        color: destination.color,
                                        size: 29,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            destination.label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(destination.subtitle),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreDestination {
  const _MoreDestination(
    this.key,
    this.label,
    this.subtitle,
    this.icon,
    this.color,
    this.page,
  );
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}
