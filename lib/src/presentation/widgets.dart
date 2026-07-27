import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String money(int cents) => NumberFormat.simpleCurrency(locale: 'de_DE', name: 'EUR').format(cents / 100);

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {this.subtitle, this.action, super.key});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)), if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]])), if (action != null) action!]);
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.icon, required this.title, required this.message, super.key});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))])));
}

Future<String?> textPrompt(BuildContext context, String title, String label) {
  final controller = TextEditingController();
  return showDialog<String>(context: context, builder: (context) => AlertDialog(title: Text(title), content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Übernehmen'))]));
}
