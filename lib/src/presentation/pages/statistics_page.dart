import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';
import '../../domain/models.dart';
import '../widgets.dart';

class StatisticsPage extends ConsumerWidget { const StatisticsPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => ref.watch(financeProvider).when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (data) { final values = <String, int>{}; for (final entry in data.entries.where((e) => e.kind == TransactionKind.expense)) { values[entry.category] = (values[entry.category] ?? 0) + entry.amount; } return CustomScrollView(slivers: [const SliverPadding(padding: EdgeInsets.fromLTRB(24, 28, 24, 12), sliver: SliverToBoxAdapter(child: PageHeading('Statistik', subtitle: 'Interaktive Auswertung deiner Finanzdaten.'))), SliverPadding(padding: const EdgeInsets.all(24), sliver: SliverLayoutBuilder(builder: (_, c) { final count = c.crossAxisExtent > 760 ? 2 : 1; final charts = [
    _ChartCard(title: 'Vermögensverteilung', description: 'Konten und Wertpapierdepot', values: {'Konten': data.accountTotal, 'Portfolio': data.portfolioTotal}),
    _ChartCard(title: 'Ausgaben nach Kategorie', description: 'Alle erfassten Ausgaben', values: values),
    _ChartCard(title: 'Cashflow', description: 'Einnahmen gegenüber Ausgaben', values: {'Einnahmen': data.income, 'Ausgaben': data.expenses}),
    _ChartCard(title: 'Fahrzeugkosten', description: 'Kumulierte Kosten je Fahrzeug', values: {for (final v in data.vehicles) v.name: v.cost}),
  ]; return SliverGrid.builder(itemCount: charts.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, mainAxisExtent: 310, mainAxisSpacing: 16, crossAxisSpacing: 16), itemBuilder: (_, i) => charts[i]); }))]); }); }

class _ChartCard extends StatelessWidget { const _ChartCard({required this.title, required this.description, required this.values}); final String title; final String description; final Map<String, int> values;
  @override Widget build(BuildContext context) { final maxValue = values.values.fold<int>(0, math.max); return Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), Text(description, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 24), Expanded(child: values.isEmpty || maxValue == 0 ? const Center(child: Text('Noch keine Daten')) : Semantics(label: '$title: ${values.entries.map((e) => '${e.key} ${money(e.value)}').join(', ')}', child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: values.entries.map((entry) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 7), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Tooltip(message: '${entry.key}: ${money(entry.value)}', child: AnimatedContainer(duration: const Duration(milliseconds: 500), height: 145 * entry.value / maxValue + 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(10))))), const SizedBox(height: 8), Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall)]))).toList())))]))); }
}
