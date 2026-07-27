import 'package:flutter/material.dart';

import 'accounts_page.dart';
import 'dividends_page.dart';
import 'investments_page.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    icon: Icon(Icons.account_balance_rounded),
                    text: 'Konten',
                  ),
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
              children: [AccountsPage(), InvestmentsPage(), DividendsPage()],
            ),
          ),
        ],
      ),
    );
  }
}
