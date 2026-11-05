import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'bank_csv.dart';

/// A CSV row prepared for the import preview.
class BankImportCandidate {
  const BankImportCandidate({
    required this.row,
    required this.id,
    required this.duplicate,
    required this.category,
  });

  final BankCsvRow row;

  /// Follows from account and row, so importing the same file twice never
  /// creates a booking twice.
  final String id;

  /// Already imported, or a booking with the same day (±3 days), amount and
  /// direction exists on the account. Left out unless the user ticks it.
  final bool duplicate;

  /// Category of the newest earlier booking with the same merchant.
  final String category;

  bool get isIncome => row.amount > 0;
}

const _ids = Uuid();

List<BankImportCandidate> prepareBankImport({
  required List<BankCsvRow> rows,
  required String accountId,
  required List<LedgerEntry> existing,
}) {
  final known = {for (final entry in existing) entry.id};
  final onAccount = existing
      .where((entry) => entry.accountId == accountId && entry.deletedAt == null)
      .toList();
  final used = <String>{};
  final categories = <String, String>{};
  for (final entry in [
    ...existing,
  ]..sort((a, b) => a.bookingDate.compareTo(b.bookingDate))) {
    final key = _merchantKey(entry.merchant, entry.isIncome);
    if (key.isNotEmpty &&
        entry.category.isNotEmpty &&
        entry.sourceType != 'transfer' &&
        entry.sourceType != 'saving') {
      categories[key] = entry.category;
    }
  }
  final seen = <String, int>{};
  return [
    for (final row in rows)
      () {
        final day = DateTime(row.date.year, row.date.month, row.date.day);
        final key =
            '$accountId|${day.toIso8601String()}|${row.amount}|'
            '${row.counterparty}|${row.purpose}';
        // Two equal payments on one day stay two bookings.
        final occurrence = seen.update(key, (n) => n + 1, ifAbsent: () => 0);
        final id = 'csv-${_ids.v5(Namespace.url.value, '$key|$occurrence')}';
        var duplicate = known.contains(id);
        if (!duplicate) {
          final match = onAccount
              .where(
                (entry) =>
                    !used.contains(entry.id) &&
                    entry.isIncome == row.amount > 0 &&
                    (entry.amount - row.amount.abs()).abs() < .005 &&
                    entry.bookingDate.difference(day).inDays.abs() <= 3,
              )
              .firstOrNull;
          if (match != null) {
            used.add(match.id);
            duplicate = true;
          }
        }
        return BankImportCandidate(
          row: row,
          id: id,
          duplicate: duplicate,
          category:
              categories[_merchantKey(row.counterparty, row.amount > 0)] ??
              'Sonstiges',
        );
      }(),
  ];
}

String _merchantKey(String merchant, bool income) {
  final name = merchant.trim().toLowerCase();
  return name.isEmpty ? '' : '$income|$name';
}
