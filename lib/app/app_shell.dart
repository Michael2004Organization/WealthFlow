import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/calculators/calculators_page.dart';
import '../features/finance/finance_page.dart';
import '../features/household/household_page.dart';
import '../features/more/more_page.dart';
import '../features/search/search_page.dart';
import '../features/statistics/statistics_page.dart';
import '../features/vehicles/vehicles_page.dart';
import '../core/widgets/common_widgets.dart';
import '../core/widgets/design_switcher.dart';
import '../core/widgets/privacy_button.dart';
import 'app_theme.dart';
import 'design.dart';

/// Width from which the sidebar replaces the bottom navigation.
const desktopBreakpoint = 900.0;

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  /// Shell pages in [IndexedStack] order; the indices are used by
  /// [selectShellDestination] throughout the app.
  static const _destinations = [
    _Destination('Cockpit', Icons.space_dashboard_outlined),
    _Destination('Vermögen', Icons.show_chart_rounded),
    _Destination('Haushalt', Icons.receipt_long_outlined),
    _Destination('Statistik', Icons.query_stats_rounded),
    _Destination('Rechner', Icons.calculate_outlined),
    _Destination('Fahrzeuge', Icons.directions_car_outlined),
    _Destination('Mehr', Icons.more_horiz_rounded),
  ];

  /// Sidebar groups on larger screens: daily use, then evaluation and tools.
  static const _mainPages = [
    ShellPage.cockpit,
    ShellPage.household,
    ShellPage.assets,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(shellIndexProvider);
    // Privat-Modus: [money] reads the flag, so a toggle rebuilds the tree.
    hideAmounts = ref.read(privacyModeProvider);
    ref.listen<bool>(privacyModeProvider, (_, hidden) {
      hideAmounts = hidden;
      _rebuildAll();
    });
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
            showSearchOverlay(context, ref),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showSearchOverlay(context, ref),
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

/// Cockpit · Haushalt · + · Vermögen · Mehr. Statistik, Rechner and
/// Fahrzeuge are opened from "Mehr" on phones.
class _PhoneNavigation extends ConsumerWidget {
  const _PhoneNavigation({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final colors = WealthColors.of(context);
    final style = DesignStyle.of(context);
    final terminal = style.design == AppDesign.terminal;
    Widget item(int index) {
      final destination = AppShell._destinations[index];
      final active =
          selected == index ||
          (index == ShellPage.more && ShellPage.tools.contains(selected));
      final foreground = active ? colors.income : colors.neutral;
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
                  // Terminal marks the active tab with a line, the others
                  // with a soft pill in the design's own roundness.
                  decoration: terminal
                      ? BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: active
                                  ? colors.income
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        )
                      : BoxDecoration(
                          color: active
                              ? colors.incomeSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            style.radiusControl.clamp(0, 15),
                          ),
                        ),
                  child: Icon(destination.icon, size: 21, color: foreground),
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: terminal ? style.numberFont : null,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
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
                item(ShellPage.cockpit),
                item(ShellPage.household),
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
                item(ShellPage.assets),
                item(ShellPage.more),
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
                  // Shrinks with large system fonts instead of overflowing.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'WealthFlow',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
              _SearchButton(onTap: () => showSearchOverlay(context, ref)),
              const SizedBox(height: 18),
              // Scrolls on short windows instead of overflowing.
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final index in [
                      ...AppShell._mainPages,
                      null,
                      ...ShellPage.tools,
                      ShellPage.more,
                    ])
                      if (index == null)
                        const _SidebarSection('Auswerten & Planen')
                      else
                        _SidebarItem(
                          destination: AppShell._destinations[index],
                          active: selected == index,
                          onTap: () => selectShellDestination(ref, index),
                        ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Expanded(child: DesignSwitcher(expanded: true)),
                  PrivacyButton(),
                ],
              ),
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

class _SidebarSection extends StatelessWidget {
  const _SidebarSection(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = DesignStyle.of(context);
    final terminal = style.design == AppDesign.terminal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(
        terminal ? '// ${label.toLowerCase()}' : label.toUpperCase(),
        style: TextStyle(
          fontFamily: terminal ? style.numberFont : null,
          fontSize: 11,
          letterSpacing: terminal ? 0 : .8,
          fontWeight: FontWeight.w700,
          color: WealthColors.of(context).muted,
        ),
      ),
    );
  }
}

/// One sidebar entry. Terminal marks the active page with a bar on the left,
/// Bento and Hell & Dunkel with a filled pill in their own roundness.
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
    final style = DesignStyle.of(context);
    final terminal = style.design == AppDesign.terminal;
    final radius = BorderRadius.circular(
      terminal ? 0 : style.radiusControl.clamp(0, 14),
    );
    final foreground = active
        ? colors.income
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Semantics(
        selected: active,
        child: Material(
          color: active && !terminal ? colors.incomeSoft : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Container(
              height: 42,
              decoration: terminal
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: active ? colors.income : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(destination.icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: terminal ? style.numberFont : null,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: foreground,
                      ),
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

/// Rebuilds every widget so amounts formatted by `money` pick up the
/// Privat-Modus, without losing any page or scroll state.
void _rebuildAll() {
  void mark(Element element) {
    element.markNeedsBuild();
    element.visitChildren(mark);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(mark);
}
