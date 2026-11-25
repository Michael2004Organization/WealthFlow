part of '../app_database.dart';

/// How long deleted bookings stay in the Papierkorb.
const trashRetention = Duration(days: 30);

/// Papierkorb: bookings deleted in the last 30 days can be restored.
///
/// Deleted rows stay in the database as tombstones for the sync, so the
/// Papierkorb only shows them; nothing is purged here.
extension TrashQueries on AppDatabase {
  /// Deleted bookings of the last [trashRetention], newest deletion first.
  /// Dividend bookings are left out: their confirmation is undone on the
  /// dividends page instead.
  Stream<List<LedgerEntry>> watchDeletedLedgerEntries(String userId) {
    final since = DateTime.now().toUtc().subtract(trashRetention);
    return (select(ledgerEntries)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.deletedAt.isBiggerOrEqualValue(since) &
                row.sourceType.isNotValue('dividend'),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.deletedAt)]))
        .watch();
  }

  /// Restores [entry] with its account effect. Both legs of a transfer or
  /// saving come back together.
  Future<int> restoreFromTrash(LedgerEntry entry) async {
    final entries = _isLinkedLedgerEntry(entry)
        ? await (select(ledgerEntries)..where(
                (row) =>
                    row.userId.equals(entry.userId) &
                    row.sourceId.equals(entry.sourceId) &
                    row.deletedAt.isNotNull(),
              ))
              .get()
        : [entry];
    await restoreLedgerEntries(entries);
    await captureNetWorth(entry.userId);
    _schedulePersist(entry.userId);
    return entries.length;
  }
}
