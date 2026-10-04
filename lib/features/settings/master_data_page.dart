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
    final assetClasses =
        ref.watch(assetClassesProvider).valueOrNull ??
        const <AssetClassesData>[];
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
              ),
              Expanded(
                child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => LoadErrorMessage(
                    'Stammdaten konnten nicht geladen werden',
                    error: error,
                  ),
                  data: (items) {
                    final sortedAssetClasses = [...assetClasses]
                      ..sort(
                        (a, b) => a.name.toLowerCase().compareTo(
                          b.name.toLowerCase(),
                        ),
                      );
                    return ListView(
                      children: [
                        Card(
                          child: ExpansionTile(
                            initiallyExpanded: false,
                            leading: const Icon(Icons.category_outlined),
                            title: const Text('Portfolio-Anlageklassen'),
                            subtitle: const Text(
                              'Feste Auswahlmöglichkeiten für alle Portfolios',
                            ),
                            children: [
                              if (sortedAssetClasses.isEmpty)
                                const ListTile(
                                  title: Text('Noch keine Einträge'),
                                ),
                              for (final assetClass in sortedAssetClasses)
                                ListTile(
                                  dense: true,
                                  title: Text(assetClass.name),
                                  trailing: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final kind in kinds.entries) ...[
                          _masterDataKindCard(
                            context,
                            ref,
                            kind: kind,
                            items: items,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _masterDataKindCard(
    BuildContext context,
    WidgetRef ref, {
    required MapEntry<String, String> kind,
    required List<MasterDataData> items,
  }) {
    final matching = items.where((item) => item.kind == kind.key).toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.bookmarks_outlined),
        title: Text(kind.value),
        subtitle: Text('${matching.length} Einträge · alphabetisch'),
        trailing: IconButton(
          tooltip: '${kind.value} hinzufügen',
          onPressed: () => _add(context, ref, initialKind: kind.key),
          icon: const Icon(Icons.add_rounded),
        ),
        children: [
          if (matching.isEmpty)
            const ListTile(title: Text('Noch keine Einträge')),
          for (final item in matching)
            ListTile(
              dense: true,
              leading: const Icon(Icons.bookmark_outline),
              title: Text(item.value),
              trailing: IconButton(
                tooltip: 'Löschen',
                onPressed: () => _delete(context, ref, item),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _add(
    BuildContext context,
    WidgetRef ref, {
    required String initialKind,
  }) async {
    final value = TextEditingController();
    var kind = initialKind;
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
