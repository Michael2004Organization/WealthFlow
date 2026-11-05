part of '../app_database.dart';

/// Daueraufträge: Regeln ohne festes Ende, die ihre Buchungen am
/// Fälligkeitstag anlegen.
extension StandingOrderQueries on AppDatabase {
  Stream<List<StandingOrder>> watchStandingOrders(String userId) =>
      (select(standingOrders)
            ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.dayOfMonth),
              (row) => OrderingTerm.asc(row.merchant),
            ]))
          .watch();

  /// Creates or changes an order. A change only affects bookings that are
  /// not created yet, i.e. from the next due date on.
  Future<void> saveStandingOrder(StandingOrdersCompanion value) async {
    if (value.amount.value <= 0) {
      throw ArgumentError('Der Betrag muss größer als 0 sein.');
    }
    await into(standingOrders).insertOnConflictUpdate(value);
    await applyStandingOrders(value.userId.value);
    _schedulePersist(value.userId.value);
  }

  /// Ends the order today; bookings already created stay.
  Future<void> endStandingOrder(String id, String userId) async {
    final now = DateTime.now();
    await (update(
      standingOrders,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      StandingOrdersCompanion(
        endDate: Value(DateTime(now.year, now.month, now.day)),
        updatedAt: Value(now.toUtc()),
      ),
    );
    _schedulePersist(userId);
  }

  Future<void> deleteStandingOrder(String id, String userId) async {
    final now = DateTime.now().toUtc();
    await (update(
      standingOrders,
    )..where((row) => row.id.equals(id) & row.userId.equals(userId))).write(
      StandingOrdersCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    _schedulePersist(userId);
  }

  /// Creates the bookings of every order that came due up to [today].
  ///
  /// Booking ids are derived from the order and the due date, so two devices
  /// that both create a booking never duplicate it, and a booking that
  /// already arrived by sync is not overwritten.
  Future<bool> applyStandingOrders(String userId, {DateTime? today}) async {
    final now = today ?? DateTime.now();
    final orders =
        await (select(standingOrders)..where(
              (row) => row.userId.equals(userId) & row.deletedAt.isNull(),
            ))
            .get();
    var created = false;
    for (final order in orders) {
      final dates = standingOrderDueDates(
        interval: order.interval,
        dayOfMonth: order.dayOfMonth,
        start: order.startDate,
        end: order.endDate,
        after: order.lastDueDate,
        through: now,
      );
      if (dates.isEmpty) continue;
      final ids = {
        for (final date in dates) _standingOrderEntryId(order, date),
      };
      final existing = {
        for (final row in await (select(
          ledgerEntries,
        )..where((row) => row.id.isIn(ids))).get())
          row.id,
      };
      final entries = [
        for (final date in dates)
          if (!existing.contains(_standingOrderEntryId(order, date)))
            ..._standingOrderEntries(order, date),
      ];
      await transaction(() async {
        if (entries.isNotEmpty) await saveLedgerEntries(entries);
        // Not an edit of the order, so updatedAt stays: a change made on
        // another device in the meantime still wins on sync.
        await (update(standingOrders)..where((row) => row.id.equals(order.id)))
            .write(StandingOrdersCompanion(lastDueDate: Value(dates.last)));
      });
      created = created || entries.isNotEmpty;
    }
    if (created) _schedulePersist(userId);
    return created;
  }

  String _standingOrderEntryId(StandingOrder order, DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'so-${order.id}-${date.year}${two(date.month)}${two(date.day)}';
  }

  List<LedgerEntriesCompanion> _standingOrderEntries(
    StandingOrder order,
    DateTime date,
  ) {
    final now = DateTime.now().toUtc();
    final id = _standingOrderEntryId(order, date);
    final linked = order.kind == 'transfer' || order.kind == 'saving';
    final budgetMonth = DateTime(date.year, date.month);
    return [
      LedgerEntriesCompanion.insert(
        id: id,
        userId: order.userId,
        bookingDate: date,
        budgetMonth: Value(budgetMonth),
        amount: order.amount,
        isIncome: Value(order.kind == 'income'),
        category: order.category.isEmpty ? 'Sonstiges' : order.category,
        merchant: Value(order.merchant),
        description: Value(order.description),
        paymentMethod: Value(order.paymentMethod),
        recurrenceId: Value(order.id),
        sourceType: Value(linked ? order.kind : 'manual'),
        sourceId: Value(linked ? id : ''),
        accountId: Value(order.accountId),
        createdAt: now,
        updatedAt: now,
      ),
      if (linked && order.targetAccountId.isNotEmpty)
        LedgerEntriesCompanion.insert(
          id: '$id-in',
          userId: order.userId,
          bookingDate: date,
          budgetMonth: Value(budgetMonth),
          amount: order.amount,
          isIncome: const Value(true),
          category: order.kind == 'saving'
              ? 'Sparen / Investieren'
              : 'Umbuchung',
          merchant: Value(order.merchant),
          description: Value(order.description),
          paymentMethod: Value(order.paymentMethod),
          recurrenceId: Value(order.id),
          sourceType: Value(order.kind),
          sourceId: Value(id),
          accountId: Value(order.targetAccountId),
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  /// Turns a series of monthly bookings into a standing order. Bookings that
  /// are not due yet are removed; the order creates them from now on.
  Future<String> convertSeriesToStandingOrder(
    String recurrenceId,
    String userId, {
    DateTime? today,
  }) async {
    final now = today ?? DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day + 1);
    final series =
        await (select(ledgerEntries)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.recurrenceId.equals(recurrenceId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    if (recurrenceId.isEmpty || series.isEmpty) {
      throw StateError('Die Serie wurde nicht gefunden.');
    }
    series.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    final outgoing = series.where((entry) => !entry.isIncome).toList();
    final linked =
        series.first.sourceType == 'transfer' ||
        series.first.sourceType == 'saving';
    final template = (linked ? outgoing : series).last;
    final target = linked
        ? series.where((entry) => entry.isIncome).firstOrNull?.accountId
        : null;
    final past = (linked ? outgoing : series)
        .where((entry) => entry.bookingDate.isBefore(endOfToday))
        .toList();
    final orderId = AppDatabase._uuid.v4();
    await transaction(() async {
      for (final entry in series.where(
        (entry) => !entry.bookingDate.isBefore(endOfToday) && !entry.isIncome,
      )) {
        await deleteLedgerEntry(entry.id, userId);
      }
      for (final entry in series.where(
        (entry) => !entry.bookingDate.isBefore(endOfToday) && entry.isIncome,
      )) {
        await deleteLedgerEntry(entry.id, userId);
      }
      final stamp = DateTime.now().toUtc();
      await into(standingOrders).insert(
        StandingOrdersCompanion.insert(
          id: orderId,
          userId: userId,
          accountId: template.accountId,
          targetAccountId: Value(target ?? ''),
          kind: Value(
            linked
                ? template.sourceType
                : template.isIncome
                ? 'income'
                : 'expense',
          ),
          amount: template.amount,
          category: Value(template.category),
          merchant: Value(template.merchant),
          description: Value(template.description),
          paymentMethod: Value(template.paymentMethod),
          dayOfMonth: template.bookingDate.day,
          startDate: series.first.bookingDate,
          lastDueDate: Value(past.lastOrNull?.bookingDate),
          createdAt: stamp,
          updatedAt: stamp,
        ),
      );
    });
    await applyStandingOrders(userId, today: now);
    _schedulePersist(userId);
    return orderId;
  }
}
