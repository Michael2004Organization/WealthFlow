import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'accounts_page.dart';
import 'dividends_page.dart';
import 'investments_page.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: ref.read(financeTabProvider),
    );
    _controller.addListener(_syncProvider);
  }

  void _syncProvider() {
    if (!_controller.indexIsChanging) {
      ref.read(financeTabProvider.notifier).state = _controller.index;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncProvider)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(financeTabProvider, (_, next) {
      if (_controller.index != next) _controller.animateTo(next);
    });
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: TabBar(
              controller: _controller,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.account_balance_rounded), text: 'Konten'),
                Tab(
                  icon: Icon(Icons.candlestick_chart_rounded),
                  text: 'Portfolio',
                ),
                Tab(icon: Icon(Icons.payments_rounded), text: 'Dividenden'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: const [
              AccountsPage(),
              InvestmentsPage(),
              DividendsPage(),
            ],
          ),
        ),
      ],
    );
  }
}
