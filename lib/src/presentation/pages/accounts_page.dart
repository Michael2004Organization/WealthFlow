import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';
import '../widgets.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});
  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await textPrompt(context, 'Konto hinzufügen', 'Kontobezeichnung');
    if (name == null || name.isEmpty || !context.mounted) return;
    final bank = await textPrompt(context, 'Konto hinzufügen', 'Bank');
    if (bank == null || !context.mounted) return;
    final amount = await textPrompt(context, 'Anfangssaldo', 'Betrag in EUR');
    if (amount == null) return;
    final cents = (double.tryParse(amount.replaceAll(',', '.')) ?? 0) * 100;
    await ref.read(financeProvider.notifier).addAccount(name: name, bank: bank, balance: cents.round());
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(padding: const EdgeInsets.all(24), child: Column(children: [PageHeading('Konten', subtitle: 'Alle Bankkonten und verfügbaren Salden.', action: FilledButton.icon(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: const Text('Konto'))), const SizedBox(height: 20), Expanded(child: ref.watch(financeProvider).when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (data) => data.accounts.isEmpty ? const EmptyState(icon: Icons.account_balance, title: 'Noch keine Konten', message: 'Füge dein erstes Bankkonto hinzu.') : ListView.separated(itemCount: data.accounts.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) { final account = data.accounts[index]; return Card(child: ListTile(contentPadding: const EdgeInsets.all(18), leading: CircleAvatar(child: Text(account.bank.isEmpty ? '?' : account.bank[0].toUpperCase())), title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(account.bank), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(money(account.balance), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), PopupMenuButton(itemBuilder: (_) => [PopupMenuItem(onTap: () => ref.read(financeProvider.notifier).removeAccount(account.id), child: const Text('Löschen'))])]))); }))))]));
}
