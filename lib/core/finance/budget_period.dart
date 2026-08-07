/// Returns the first Monday-to-Friday day of [month].
DateTime firstWorkingDay(DateTime month) {
  var day = DateTime(month.year, month.month, 1);
  while (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
    day = day.add(const Duration(days: 1));
  }
  return day;
}

/// Returns the last Monday-to-Friday day of [month].
DateTime lastWorkingDay(DateTime month) {
  var day = DateTime(month.year, month.month + 1, 0);
  while (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
    day = day.subtract(const Duration(days: 1));
  }
  return day;
}

DateTime budgetMonthOf(DateTime bookingDate, DateTime? explicitBudgetMonth) {
  final value = explicitBudgetMonth ?? bookingDate;
  return DateTime(value.year, value.month);
}

/// Date from which a ledger entry affects budget totals and the app balance.
///
/// A payment without an explicit budget month becomes effective on its real
/// booking date. Advance payments become effective on the first day of their
/// economic month (for example salary paid on 31 July for August).
DateTime ledgerEffectiveDate(
  DateTime bookingDate,
  DateTime? explicitBudgetMonth,
) {
  if (explicitBudgetMonth == null) {
    return DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
  }
  final budgetMonth = DateTime(
    explicitBudgetMonth.year,
    explicitBudgetMonth.month,
  );
  final bookingMonth = DateTime(bookingDate.year, bookingDate.month);
  return budgetMonth == bookingMonth
      ? DateTime(bookingDate.year, bookingDate.month, bookingDate.day)
      : budgetMonth;
}

/// Calculates the real payment date for a payment belonging to [budgetMonth].
///
/// Start and middle are paid in the same economic month. End is paid on the
/// last working day of the previous month, as commonly used for
/// salaries and subscriptions paid in advance.
DateTime paymentDateForBudgetMonth({
  required DateTime budgetMonth,
  required String timing,
  required int selectedDay,
}) {
  final month = DateTime(budgetMonth.year, budgetMonth.month);
  return switch (timing) {
    'start' => firstWorkingDay(month),
    'middle' => DateTime(month.year, month.month, 15),
    'end' => lastWorkingDay(DateTime(month.year, month.month - 1)),
    _ => DateTime(
      month.year,
      month.month,
      selectedDay.clamp(1, DateTime(month.year, month.month + 1, 0).day),
    ),
  };
}
