import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthflow_core/database/app_database.dart';

import '../../app/app_theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/save_feedback.dart';

/// Bookings deleted in the last 30 days, ready to be restored.
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleted = ref.watch(deletedLedgerEntriesProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'Papierkorb'),
              Text(
                'Gelöschte Buchungen bleiben ${trashRetention.inDays} Tage '
                'hier. Beim Wiederherstellen wird auch der Kontostand wieder '
                'angepasst; Umbuchungen kommen mit beiden Seiten zurück.',
                style: TextStyle(color: WealthColors.of(context).muted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: deleted.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => LoadErrorMessage(
                    'Papierkorb konnte nicht geladen werden',
                    error: error,
                  ),
                  data: (items) {
                    final visible = _oneLegPerTransfer(items);
                    if (visible.isEmpty) {
                      return const EmptyState(
                        icon: Icons.delete_outline_rounded,
                        title: 'Papierkorb ist leer',
                        message:
                            'Hier landen Buchungen, die du löschst. Du kannst '
                            'sie 30 Tage lang wiederherstellen.',
                      );
                    }
                    return ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _TrashTile(entry: visible[index]),
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
}

/// A transfer is deleted with both legs; show it once.
List<LedgerEntry> _oneLegPerTransfer(List<LedgerEntry> entries) {
  final seen = <String>{};
  return [
    for (final entry in entries)
      if (!(entry.sourceType == 'transfer' || entry.sourceType == 'saving') ||
          entry.sourceId.isEmpty ||
          seen.add(entry.sourceId))
        entry,
  ];
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WealthColors.of(context);
    final title = entry.merchant.isNotEmpty ? entry.merchant : entry.category;
    final deletedAt = entry.deletedAt?.toLocal();
    final linked =
        entry.sourceType == 'transfer' || entry.sourceType == 'saving';
    return Card(
      child: ListTile(
        leading: IconTile(
          icon: entry.isIncome
              ? Icons.south_west_rounded
              : linked
              ? Icons.swap_horiz_rounded
              : Icons.north_east_rounded,
          background: entry.isIncome ? colors.incomeSoft : colors.expenseSoft,
          foreground: entry.isIncome ? colors.income : colors.expense,
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${linked ? 'Umbuchung' : entry.category} · '
          '${shortDate(entry.bookingDate)}'
          '${deletedAt == null ? '' : ' · gelöscht am ${shortDate(deletedAt)}'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${entry.isIncome ? '+' : '−'}${money(entry.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              tooltip: 'Wiederherstellen',
              icon: const Icon(Icons.restore_from_trash_rounded),
              onPressed: () => _restore(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final done = await saveWithFeedback(
      context,
      () => ref.read(databaseProvider).restoreFromTrash(entry),
      failure: 'Wiederherstellen fehlgeschlagen',
      source: 'Papierkorb',
    );
    if (done) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Buchung wiederhergestellt')),
      );
    }
  }
}
