import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/models.dart';
import '../widgets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(financeProvider).when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('Daten konnten nicht geladen werden: $error')),
    data: (data) => CustomScrollView(slivers: [SliverPadding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 12), sliver: SliverToBoxAdapter(child: PageHeading('Guten Tag 👋', subtitle: 'Hier ist dein finanzieller Überblick.', action: IconButton.filledTonal(onPressed: () => showSearch(context: context, delegate: _Search(data)), icon: const Icon(Icons.search))))), SliverPadding(padding: const EdgeInsets.all(24), sliver: SliverLayoutBuilder(builder: (context, constraints) { final width = constraints.crossAxisExtent; final count = width >= 1000 ? 3 : width >= 600 ? 2 : 1; return SliverGrid.builder(itemCount: 6, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, mainAxisExtent: 168, crossAxisSpacing: 16, mainAxisSpacing: 16), itemBuilder: (context, index) { final cards = [
      _Metric('Gesamtvermögen', money(data.accountTotal + data.portfolioTotal), Icons.auto_graph_rounded, 'Konten und Depot'),
      _Metric('Kontostände', money(data.accountTotal), Icons.account_balance_wallet_rounded, '${data.accounts.length} Konten'),
      _Metric('Depotwert', money(data.portfolioTotal), Icons.candlestick_chart_rounded, '${data.positions.length} Positionen'),
      _Metric('Einnahmen', money(data.income), Icons.trending_up_rounded, 'Erfasster Zeitraum'),
      _Metric('Ausgaben', money(data.expenses), Icons.trending_down_rounded, 'Erfasster Zeitraum'),
      _Metric('Sparquote', data.income == 0 ? '–' : '${((data.income - data.expenses) / data.income * 100).toStringAsFixed(1)} %', Icons.savings_rounded, 'Einnahmen minus Ausgaben'),
    ]; return cards[index]; }); }))]),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, this.caption);
  final String label;
  final String value;
  final IconData icon;
  final String caption;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () {}, child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const Spacer(), const Icon(Icons.arrow_outward_rounded, size: 18)]), const Spacer(), Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 4), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), Text(caption, style: Theme.of(context).textTheme.bodySmall)]))));
}

class _Search extends SearchDelegate<String> {
  _Search(this.data);
  final FinanceData data;
  @override List<Widget> buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override Widget buildLeading(BuildContext context) => BackButton(onPressed: () => close(context, ''));
  @override Widget buildResults(BuildContext context) => _results();
  @override Widget buildSuggestions(BuildContext context) => _results();
  Widget _results() { final q = query.toLowerCase(); final values = <String>[...data.accounts.map((e) => '${e.bank} · ${e.name}'), ...data.positions.map((e) => '${e.symbol} · ${e.name}'), ...data.entries.map((e) => '${e.category} · ${e.merchant}'), ...data.vehicles.map((e) => '${e.kind} · ${e.name}')].where((e) => e.toLowerCase().contains(q)).toList(); return values.isEmpty ? const EmptyState(icon: Icons.search_off, title: 'Keine Treffer', message: 'Versuche einen anderen Suchbegriff.') : ListView.builder(itemCount: values.length, itemBuilder: (_, i) => ListTile(leading: const Icon(Icons.search), title: Text(values[i]))); }
}
