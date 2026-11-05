/// Months between two bookings of a standing order.
int standingOrderStep(String interval) => switch (interval) {
  'quarterly' => 3,
  'yearly' => 12,
  _ => 1,
};

/// The due day of [month], with [dayOfMonth] clamped to the month's length
/// (31 becomes 30 in April and 28 or 29 in February).
DateTime standingOrderDueDay(DateTime month, int dayOfMonth) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, dayOfMonth.clamp(1, lastDay));
}

/// Due dates after [after] (exclusive) up to [through] (inclusive). The
/// first due date is the first one on or after [start]; none after [end].
List<DateTime> standingOrderDueDates({
  required String interval,
  required int dayOfMonth,
  required DateTime start,
  DateTime? end,
  DateTime? after,
  required DateTime through,
}) {
  final step = standingOrderStep(interval);
  final startDay = DateTime(start.year, start.month, start.day);
  var month = DateTime(start.year, start.month);
  var due = standingOrderDueDay(month, dayOfMonth);
  if (due.isBefore(startDay)) {
    // The first booking is the next possible one; the rhythm counts from it.
    month = DateTime(month.year, month.month + 1);
    due = standingOrderDueDay(month, dayOfMonth);
  }
  final last = end == null || end.isAfter(through) ? through : end;
  final dates = <DateTime>[];
  // 1200 steps cover 100 years of monthly bookings.
  for (var guard = 0; guard < 1200 && !due.isAfter(last); guard++) {
    if (after == null || due.isAfter(after)) dates.add(due);
    month = DateTime(month.year, month.month + step);
    due = standingOrderDueDay(month, dayOfMonth);
  }
  return dates;
}

/// The next due date after [after], or null when the order has ended.
DateTime? nextStandingOrderDueDate({
  required String interval,
  required int dayOfMonth,
  required DateTime start,
  DateTime? end,
  required DateTime after,
}) {
  final dates = standingOrderDueDates(
    interval: interval,
    dayOfMonth: dayOfMonth,
    start: start,
    end: end,
    after: after,
    through: DateTime(after.year + 1, after.month, after.day + 1),
  );
  return dates.firstOrNull;
}
