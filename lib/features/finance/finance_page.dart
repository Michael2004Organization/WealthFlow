import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
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
    final colors = WealthColors.of(context);
    final padding = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.neutralSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _controller,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1f121a1f),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: colors.neutral,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    tabs: const [
                      Tab(text: 'Konten'),
                      Tab(text: 'Depot'),
                      Tab(text: 'Dividenden'),
                    ],
                  ),
                ),
              ),
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
