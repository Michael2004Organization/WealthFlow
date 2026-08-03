import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';

class MasterDataPage extends ConsumerWidget {
  const MasterDataPage({super.key});

  static const kinds = {
    'category': 'Haushaltskategorie',
    'merchant': 'Händler / Quelle',
    'paymentMethod': 'Zahlungsmethode',
    'broker': 'Broker',
    'country': 'Land',
    'sector': 'Branche',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(masterDataProvider);
    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Stammdaten',
                subtitle:
                    'Wiederkehrende Eingaben verwalten. Neue Händler und Zahlungsarten werden beim Buchen automatisch ergänzt.',
                action: FilledButton.icon(
                  onPressed: () => _add(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Eintrag'),
                ),
              ),
              Expanded(
                child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                  data: (items) => items.isEmpty
                      ? EmptyState(
                          icon: Icons.list_alt_rounded,
                          title: 'Noch keine Stammdaten',
                          message:
                              'Lege einen Eintrag an oder erfasse eine Buchung mit Händler beziehungsweise Zahlungsart.',
                          action: FilledButton.icon(
                            onPressed: () => _add(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Stammdatum anlegen'),
                          ),
                        )
                      : ListView(
                          children: [
                            for (final kind in kinds.entries) ...[
                              if (items.any((item) => item.kind == kind.key))
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    4,
                                    18,
                                    4,
                                    8,
                                  ),
                                  child: Text(
                                    kind.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              for (final item in items.where(
                                (item) => item.kind == kind.key,
                              ))
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.bookmark_outline),
                                    title: Text(item.value),
                                    trailing: IconButton(
                                      tooltip: 'Löschen',
                                      onPressed: () =>
                                          _delete(context, ref, item),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final value = TextEditingController();
    var kind = kinds.keys.first;
    final formKey = GlobalKey<FormState>();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stammdatum anlegen'),
        content: SizedBox(
          width: 430,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: 'Typ'),
                  items: kinds.entries
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.key,
                          child: Text(item.value),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) => kind = newValue ?? kind,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: value,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Wert'),
                  validator: (text) => (text?.trim().isEmpty ?? true)
                      ? 'Bitte einen Wert eingeben.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (submitted == true) {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ref
            .read(databaseProvider)
            .saveMasterDatum(
              MasterDataCompanion.insert(
                id: const Uuid().v4(),
                userId: userId,
                kind: kind,
                value: value.text.trim(),
                createdAt: DateTime.now().toUtc(),
              ),
            );
      }
    }
    value.dispose();
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MasterDataData item,
  ) async {
    if (!await confirmDelete(
      context,
      title: 'Stammdatum löschen?',
      message: '„${item.value}“ wird aus den Vorschlägen entfernt.',
    )) {
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref.read(databaseProvider).deleteMasterDatum(item.id, userId);
    }
  }
}
