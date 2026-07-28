import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/finance/finance_page.dart';
import '../features/household/household_page.dart';
import '../features/more/more_page.dart';
import '../features/statistics/statistics_page.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _destinations = [
    _Destination(
      'Übersicht',
      Icons.space_dashboard_outlined,
      Icons.space_dashboard_rounded,
    ),
    _Destination(
      'Finanzen',
      Icons.account_balance_outlined,
      Icons.account_balance_rounded,
    ),
    _Destination(
      'Haushalt',
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
    ),
    _Destination(
      'Statistik',
      Icons.query_stats_outlined,
      Icons.query_stats_rounded,
    ),
    _Destination('Mehr', Icons.grid_view_outlined, Icons.grid_view_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(shellIndexProvider);
    final user = ref.watch(authControllerProvider).user;
    final pages = const [
      DashboardPage(),
      FinancePage(),
      HouseholdPage(),
      StatisticsPage(),
      MorePage(),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final content = IndexedStack(index: selected, children: pages);
        if (!desktop) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'WealthFlow',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    tooltip: 'Account öffnen',
                    onPressed: () => openMore(ref, 'settings'),
                    icon: CircleAvatar(
                      child: Text(
                        (user?.displayName.isNotEmpty ?? false)
                            ? user!.displayName[0].toUpperCase()
                            : 'W',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  ref.read(shellIndexProvider.notifier).state = value,
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 1180,
                  selectedIndex: selected,
                  onDestinationSelected: (value) =>
                      ref.read(shellIndexProvider.notifier).state = value,
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        if (constraints.maxWidth >= 1180) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'WealthFlow',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: [
                    for (final destination in _destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                      ),
                  ],
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton(
                          tooltip: '${user?.displayName ?? 'Profil'} öffnen',
                          onPressed: () => openMore(ref, 'settings'),
                          icon: CircleAvatar(
                            child: Text(
                              (user?.displayName.isNotEmpty ?? false)
                                  ? user!.displayName[0].toUpperCase()
                                  : 'W',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
