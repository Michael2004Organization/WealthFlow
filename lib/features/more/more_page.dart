import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../reminders/reminders_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../settings/master_data_page.dart';
import '../settings/administration_page.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});
  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  String _sortMode = 'default';
  final List<String> _customOrder = const [
    'reminders',
    'search',
    'masterData',
    'settings',
    'administration',
  ].toList();
  String? _loadedForUser;

  static const _destinations = [
    _MoreDestination(
      'reminders',
      'Erinnerungen',
      'Termine und Benachrichtigungen',
      Icons.notifications_active_rounded,
      Colors.deepPurple,
      RemindersPage(),
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
    _MoreDestination(
      'administration',
      'Administration',
      'Benutzerrollen und Portfolio-Stammdaten',
      Icons.admin_panel_settings_rounded,
      Colors.redAccent,
      AdministrationPage(),
      adminOnly: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null && _loadedForUser != userId) {
      _loadedForUser = userId;
      Future<void>.microtask(() => _loadLayout(userId));
    }
    final selectedKey = ref.watch(moreDestinationProvider);
    _MoreDestination? selected;
    for (final destination in _destinations.where(
      (destination) => !destination.adminOnly || isAdmin,
    )) {
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
    final destinations = _destinations
        .where((destination) => !destination.adminOnly || isAdmin)
        .toList();
    if (_sortMode == 'name') {
      destinations.sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    } else if (_sortMode == 'custom') {
      destinations.sort(
        (a, b) =>
            _customOrder.indexOf(a.key).compareTo(_customOrder.indexOf(b.key)),
      );
    }
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
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    initialValue: _sortMode,
                    decoration: const InputDecoration(
                      labelText: 'Sortierung',
                      prefixIcon: Icon(Icons.sort_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('Standardreihenfolge'),
                      ),
                      DropdownMenuItem(value: 'name', child: Text('Name A–Z')),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Eigene Reihenfolge'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _sortMode = value);
                      _persistLayout();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 650
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final indexed in destinations.indexed)
                        SizedBox(
                          width: width,
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () =>
                                  ref
                                      .read(moreDestinationProvider.notifier)
                                      .state = indexed
                                      .$2
                                      .key,
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: indexed.$2.color.withValues(
                                          alpha: .14,
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Icon(
                                        indexed.$2.icon,
                                        color: indexed.$2.color,
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
                                            indexed.$2.label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(indexed.$2.subtitle),
                                        ],
                                      ),
                                    ),
                                    if (_sortMode == 'custom')
                                      Column(
                                        children: [
                                          IconButton(
                                            tooltip: 'Nach oben',
                                            onPressed: indexed.$1 == 0
                                                ? null
                                                : () => _moveDestination(
                                                    indexed.$2.key,
                                                    destinations[indexed.$1 - 1]
                                                        .key,
                                                  ),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_up_rounded,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Nach unten',
                                            onPressed:
                                                indexed.$1 ==
                                                    destinations.length - 1
                                                ? null
                                                : () => _moveDestination(
                                                    indexed.$2.key,
                                                    destinations[indexed.$1 + 1]
                                                        .key,
                                                  ),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
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

  void _moveDestination(String key, String targetKey) {
    setState(() {
      final oldIndex = _customOrder.indexOf(key);
      final newIndex = _customOrder.indexOf(targetKey);
      final item = _customOrder.removeAt(oldIndex);
      _customOrder.insert(newIndex, item);
      _sortMode = 'custom';
    });
    _persistLayout();
  }

  Future<void> _loadLayout(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedOrder = preferences.getStringList('more.cardOrder.$userId');
    if (!mounted || _loadedForUser != userId) return;
    setState(() {
      _sortMode = preferences.getString('more.sortMode.$userId') ?? 'default';
      if (storedOrder != null) {
        _customOrder
          ..clear()
          ..addAll(storedOrder.where(_customOrderDefaults.contains))
          ..addAll(
            _customOrderDefaults.where((key) => !storedOrder.contains(key)),
          );
      }
    });
  }

  Future<void> _persistLayout() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('more.sortMode.$userId', _sortMode);
    await preferences.setStringList('more.cardOrder.$userId', _customOrder);
  }

  static const _customOrderDefaults = [
    'reminders',
    'search',
    'masterData',
    'settings',
    'administration',
  ];
}

class _MoreDestination {
  const _MoreDestination(
    this.key,
    this.label,
    this.subtitle,
    this.icon,
    this.color,
    this.page, {
    this.adminOnly = false,
  });
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final bool adminOnly;
}
