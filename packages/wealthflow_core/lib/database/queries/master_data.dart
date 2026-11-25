part of '../app_database.dart';

/// Where a master data kind is used: table and column, for counting and for
/// carrying a rename over to every row that holds the old value.
const _masterDataUsages = {
  'category': [
    ('ledger_entries', 'category'),
    ('standing_orders', 'category'),
    ('category_budgets', 'category'),
  ],
  'merchant': [('ledger_entries', 'merchant'), ('standing_orders', 'merchant')],
  'paymentMethod': [
    ('ledger_entries', 'payment_method'),
    ('standing_orders', 'payment_method'),
  ],
  'broker': [('investments', 'broker')],
  'country': [('investments', 'country')],
  'sector': [('investments', 'sector')],
};

/// Usage of one master data value.
class MasterDataUsage {
  const MasterDataUsage({this.household = 0, this.portfolio = 0});

  /// Bookings, standing orders and budgets.
  final int household;

  /// Portfolio positions.
  final int portfolio;

  int get total => household + portfolio;
}

/// Stammdaten: anlegen, zählen, umbenennen, zusammenführen.
extension MasterDataQueries on AppDatabase {
  /// Kinds whose values are counted and renamed across the data.
  static Set<String> get trackedKinds => _masterDataUsages.keys.toSet();

  /// How often each value is used, keyed by kind and then by value
  /// (case-sensitive, as stored). Values used but missing from the master
  /// data are included, so they can be offered for adoption.
  Future<Map<String, Map<String, MasterDataUsage>>> masterDataUsage(
    String userId,
  ) async {
    final result = <String, Map<String, MasterDataUsage>>{};
    for (final MapEntry(key: kind, value: places)
        in _masterDataUsages.entries) {
      final counts = result.putIfAbsent(kind, () => {});
      for (final (table, column) in places) {
        final rows = await customSelect(
          'SELECT $column AS value, COUNT(*) AS uses FROM $table '
          "WHERE user_id = ? AND deleted_at IS NULL AND trim($column) != '' "
          'GROUP BY $column',
          variables: [Variable.withString(userId)],
          readsFrom: {
            ledgerEntries,
            standingOrders,
            categoryBudgets,
            investments,
          },
        ).get();
        final portfolio = table == 'investments';
        for (final row in rows) {
          final value = row.read<String>('value');
          final uses = row.read<int>('uses');
          final current = counts[value] ?? const MasterDataUsage();
          counts[value] = MasterDataUsage(
            household: current.household + (portfolio ? 0 : uses),
            portfolio: current.portfolio + (portfolio ? uses : 0),
          );
        }
      }
    }
    return result;
  }

  /// Adds [value] to [kind]. A value deleted earlier is restored instead,
  /// because (user, kind, value) is unique. Returns false if an active entry
  /// with the same name (ignoring case) already exists.
  Future<bool> addMasterDatum(String userId, String kind, String value) async {
    final name = value.trim();
    if (name.isEmpty) return false;
    final rows = await (select(
      masterData,
    )..where((row) => row.userId.equals(userId) & row.kind.equals(kind))).get();
    final lower = name.toLowerCase();
    if (rows.any(
      (r) => r.deletedAt == null && r.value.toLowerCase() == lower,
    )) {
      return false;
    }
    final now = DateTime.now().toUtc();
    final deleted = rows.where((r) => r.value == name).firstOrNull;
    if (deleted != null) {
      await (update(masterData)..where((r) => r.id.equals(deleted.id))).write(
        MasterDataCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    } else {
      await into(masterData).insert(
        MasterDataCompanion.insert(
          id: AppDatabase._uuid.v4(),
          userId: userId,
          kind: kind,
          value: name,
          createdAt: now,
          updatedAt: Value(now),
        ),
      );
    }
    _schedulePersist(userId);
    return true;
  }

  /// Brings back an entry removed with [deleteMasterDatum] (undo).
  Future<void> restoreMasterDatum(String id, String userId) async {
    await (update(
      masterData,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      MasterDataCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  /// Renames [item] to [newValue] and changes every booking, standing order,
  /// budget and position that used the old value. If [newValue] already
  /// exists in the same kind, the two are merged: [item] is removed and all
  /// its uses move to the existing entry. Returns the number of changed rows.
  Future<int> renameMasterDatum(MasterDataData item, String newValue) async {
    final name = newValue.trim();
    if (name.isEmpty || name == item.value) return 0;
    final now = DateTime.now().toUtc();
    var changed = 0;
    await transaction(() async {
      final siblings =
          await (select(masterData)..where(
                (row) =>
                    row.userId.equals(item.userId) & row.kind.equals(item.kind),
              ))
              .get();
      final target = siblings
          .where((r) => r.id != item.id && r.value == name)
          .firstOrNull;
      // A case-only change of the same entry, or a merge into another one.
      final caseTwin = siblings
          .where(
            (r) =>
                r.id != item.id &&
                r.deletedAt == null &&
                r.value.toLowerCase() == name.toLowerCase(),
          )
          .firstOrNull;
      // Prefer an active entry; a deleted one with exactly this name must be
      // revived, because (user, kind, value) is unique.
      final mergeInto =
          (target?.deletedAt == null ? target : null) ?? caseTwin ?? target;

      if (item.kind == 'category') {
        await _mergeBudgets(item.userId, item.value, name, now);
      }
      for (final (table, column) in _masterDataUsages[item.kind] ?? const []) {
        changed += await customUpdate(
          'UPDATE $table SET $column = ?, updated_at = ? '
          'WHERE user_id = ? AND $column = ? AND deleted_at IS NULL',
          variables: [
            Variable.withString(mergeInto?.value ?? name),
            Variable.withDateTime(now),
            Variable.withString(item.userId),
            Variable.withString(item.value),
          ],
          updates: {
            ledgerEntries,
            standingOrders,
            categoryBudgets,
            investments,
          },
          updateKind: UpdateKind.update,
        );
      }

      if (mergeInto != null) {
        await (update(masterData)..where((r) => r.id.equals(item.id))).write(
          MasterDataCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
        if (mergeInto.deletedAt != null) {
          await (update(
            masterData,
          )..where((r) => r.id.equals(mergeInto.id))).write(
            MasterDataCompanion(
              deletedAt: const Value(null),
              updatedAt: Value(now),
            ),
          );
        }
      } else {
        await (update(masterData)..where((r) => r.id.equals(item.id))).write(
          MasterDataCompanion(value: Value(name), updatedAt: Value(now)),
        );
      }
    });
    _schedulePersist(item.userId);
    return changed;
  }

  /// Before category [from] becomes [to]: if [to] (ignoring case) already
  /// has an active budget, the budget of [from] is removed so the merged
  /// category keeps exactly one.
  Future<void> _mergeBudgets(
    String userId,
    String from,
    String to,
    DateTime now,
  ) async {
    final budgets =
        await (select(categoryBudgets)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    final hasTarget = budgets.any(
      (b) => b.category != from && b.category.toLowerCase() == to.toLowerCase(),
    );
    if (!hasTarget) return;
    for (final budget in budgets.where((b) => b.category == from)) {
      await (update(
        categoryBudgets,
      )..where((r) => r.id.equals(budget.id))).write(
        CategoryBudgetsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }
  }
}
