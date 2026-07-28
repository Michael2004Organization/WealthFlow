import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/finance/dividend_math.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import 'investments_page.dart';

class DividendsPage extends ConsumerWidget {
  const DividendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investments = ref.watch(investmentsProvider);
    return investments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Dividenden konnten nicht geladen werden: $error'),
      ),
      data: (items) {
        final dividendItems =
            items.where((item) => item.annualDividend > 0).toList()..sort(
              (a, b) => dividendPerMonth(
                b.annualDividend,
                b.quantity,
              ).compareTo(dividendPerMonth(a.annualDividend, a.quantity)),
            );
        final monthly = dividendItems.fold<double>(
          0,
          (sum, item) =>
              sum + dividendPerMonth(item.annualDividend, item.quantity),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: 'Dividenden',
                    subtitle:
                        'Erträge und Ausschüttungsrhythmus deiner Positionen.',
                    action: FilledButton.icon(
                      onPressed: () => openFinance(ref, 1),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Positionen verwalten'),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth < 700
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 32) / 3;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Jahr',
                              value: money(dividendPerYearFromMonth(monthly)),
                              icon: Icons.calendar_today_rounded,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Quartal',
                              value: money(
                                dividendPerQuarterFromMonth(monthly),
                              ),
                              icon: Icons.date_range_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: MetricCard(
                              title: 'Pro Monat',
                              value: money(monthly),
                              icon: Icons.today_rounded,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (dividendItems.isEmpty)
                    SizedBox(
                      height: 360,
                      child: EmptyState(
                        icon: Icons.payments_rounded,
                        title: 'Noch keine Dividenden',
                        message:
                            'Hinterlege bei deinen Portfolio-Positionen die Dividende je Stück und Monat.',
                        action: FilledButton.icon(
                          onPressed: () => openFinance(ref, 1),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Position bearbeiten'),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chartWidth = constraints.maxWidth < 820
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 16) * .48;
                        final listWidth = constraints.maxWidth < 820
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 16) * .52;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: chartWidth,
                              height: 390,
                              child: _DividendChart(items: dividendItems),
                            ),
                            SizedBox(
                              width: listWidth,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nach Unternehmen',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      for (final item in dividendItems)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          onTap: () => showInvestmentEditor(
                                            context,
                                            ref,
                                            investment: item,
                                          ),
                                          leading: CircleAvatar(
                                            child: Text(
                                              item.symbol.isEmpty
                                                  ? item.name[0]
                                                  : item.symbol[0],
                                            ),
                                          ),
                                          title: Text(item.name),
                                          subtitle: Text(
                                            '${item.dividendFrequency} · '
                                            '${money(item.annualDividend)} je Stück/Monat',
                                          ),
                                          trailing: Text(
                                            '${money(dividendPerMonth(item.annualDividend, item.quantity))}/Monat',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
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
      },
    );
  }
}

class _DividendChart extends StatelessWidget {
  const _DividendChart({required this.items});
  final List<Investment> items;

  @override
  Widget build(BuildContext context) {
    final palette = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verteilung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 58,
                  sectionsSpace: 3,
                  sections: [
                    for (var index = 0; index < items.length; index++)
                      PieChartSectionData(
                        value: dividendPerMonth(
                          items[index].annualDividend,
                          items[index].quantity,
                        ),
                        title: items[index].symbol.isEmpty
                            ? items[index].name
                            : items[index].symbol,
                        color: palette[index % palette.length],
                        radius: 72,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
