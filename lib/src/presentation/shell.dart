import 'package:flutter/material.dart';

import 'pages/accounts_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/ledger_page.dart';
import 'pages/more_page.dart';
import 'pages/portfolio_page.dart';
import 'pages/statistics_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selected = 0;
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Übersicht'),
    NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'Konten'),
    NavigationDestination(icon: Icon(Icons.candlestick_chart_outlined), selectedIcon: Icon(Icons.candlestick_chart), label: 'Portfolio'),
    NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Haushalt'),
    NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Statistik'),
    NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Mehr'),
  ];
  static const _pages = [DashboardPage(), AccountsPage(), PortfolioPage(), LedgerPage(), StatisticsPage(), MorePage()];

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final desktop = constraints.maxWidth >= 840;
    final body = SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: KeyedSubtree(key: ValueKey(_selected), child: _pages[_selected])));
    if (!desktop) return Scaffold(body: body, bottomNavigationBar: NavigationBar(selectedIndex: _selected, onDestinationSelected: (value) => setState(() => _selected = value), destinations: _destinations));
    return Scaffold(body: Row(children: [NavigationRail(extended: constraints.maxWidth >= 1180, selectedIndex: _selected, onDestinationSelected: (value) => setState(() => _selected = value), leading: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Row(children: [const Icon(Icons.account_balance_wallet_rounded), if (constraints.maxWidth >= 1180) const Padding(padding: EdgeInsets.only(left: 12), child: Text('WealthFlow', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)))])), destinations: _destinations.map((e) => NavigationRailDestination(icon: e.icon, selectedIcon: e.selectedIcon, label: Text(e.label))).toList()), const VerticalDivider(width: 1), Expanded(child: body)]));
  });
}
