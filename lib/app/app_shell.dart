import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/calculators/calculators_page.dart';
import '../features/finance/finance_page.dart';
import '../features/household/household_page.dart';
import '../features/more/more_page.dart';
import '../features/statistics/statistics_page.dart';
import '../features/vehicles/vehicles_page.dart';
import '../core/widgets/common_widgets.dart';
import 'app_theme.dart';

/// Width from which the sidebar replaces the bottom navigation.
const desktopBreakpoint = 900.0;

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  /// Shell pages in [IndexedStack] order; the indices are used by
  /// [selectShellDestination] throughout the app.
  static const _destinations = [
    _Destination('Übersicht', Icons.space_dashboard_outlined),
    _Destination('Vermögen', Icons.show_chart_rounded),
    _Destination('Haushalt', Icons.receipt_long_outlined),
    _Destination('Statistik', Icons.query_stats_rounded),
    _Destination('Rechner', Icons.calculate_outlined),
    _Destination('Fahrzeuge', Icons.directions_car_outlined),
    _Destination('Mehr', Icons.more_horiz_rounded),
  ];

  /// Sidebar order on larger screens.
  static const _desktopOrder = [0, 2, 1, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(shellIndexProvider);
    const pages = [
      DashboardPage(),
      FinancePage(),
      HouseholdPage(),
      StatisticsPage(),
      CalculatorsPage(),
      VehiclesPage(),
      MorePage(),
    ];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            openMore(ref, 'search'),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            openMore(ref, 'search'),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            startNewBooking(context, ref),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = IndexedStack(index: selected, children: pages);
            if (constraints.maxWidth < desktopBreakpoint) {
              return Scaffold(
                body: SafeArea(bottom: false, child: content),
                bottomNavigationBar: _PhoneNavigation(selected: selected),
              );
            }
            return Scaffold(
              body: Row(
                children: [
                  _Sidebar(selected: selected),
                  Expanded(child: SafeArea(left: false, child: content)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Übersicht · Haushalt · + · Vermögen · Mehr. Statistik, Rechner and
/// Fahrzeuge are opened from "Mehr" on phones.
class _PhoneNavigation extends ConsumerWidget {
  const _PhoneNavigation({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final colors = WealthColors.of(context);
    Widget item(int index) {
      final destination = AppShell._destinations[index];
      final active =
          selected == index ||
          (index == 6 && const [3, 4, 5].contains(selected));
      return Expanded(
        child: Semantics(
          selected: active,
          button: true,
          label: destination.label,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => selectShellDestination(ref, index),
            radius: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 30,
                  decoration: BoxDecoration(
                    color: active ? colors.incomeSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    destination.icon,
                    size: 21,
                    color: active ? colors.income : colors.neutral,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? colors.income : colors.neutral,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                item(0),
                item(2),
                Expanded(
                  child: Center(
                    child: Tooltip(
                      message: 'Neue Buchung',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: .35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => startNewBooking(context, ref),
                            child: Icon(
                              Icons.add_rounded,
                              size: 28,
                              color: scheme.onPrimary,
                              semanticLabel: 'Neue Buchung',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                item(1),
                item(6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final colors = WealthColors.of(context);
    final user = ref.watch(authControllerProvider).user;
    final name = user?.displayName ?? '';
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppLogo(),
                  const SizedBox(width: 10),
                  Text(
                    'WealthFlow',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => startNewBooking(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Buchung'),
              ),
              const SizedBox(height: 10),
              _SearchButton(onTap: () => openMore(ref, 'search')),
              const SizedBox(height: 18),
              for (final index in AppShell._desktopOrder)
                _SidebarItem(
                  destination: AppShell._destinations[index],
                  active: selected == index,
                  onTap: () => selectShellDestination(ref, index),
                ),
              const Spacer(),
              Divider(color: colors.border, height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => openMore(ref, 'settings'),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.incomeSoft,
                        foregroundColor: colors.income,
                        child: Text(
                          name.isEmpty ? 'W' : name[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name.isEmpty ? 'Account' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    return Material(
      color: colors.ground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: colors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Suchen', style: TextStyle(color: colors.muted)),
              ),
              Text(
                'Strg K',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final _Destination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WealthColors.of(context);
    final foreground = active
        ? colors.income
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Semantics(
        selected: active,
        child: Material(
          color: active ? colors.incomeSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              height: 42,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(destination.icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                  Text(
                    destination.label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
