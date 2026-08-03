/// Returns the first Monday-to-Friday day of [month].
DateTime firstWorkingDay(DateTime month) {
  var day = DateTime(month.year, month.month, 1);
  while (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
    day = day.add(const Duration(days: 1));
  }
  return day;
}

/// Returns the penultimate Monday-to-Friday day of [month].
DateTime penultimateWorkingDay(DateTime month) {
  var day = DateTime(month.year, month.month + 1, 0);
  var workingDays = 0;
  while (true) {
    if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
      workingDays++;
      if (workingDays == 2) return day;
    }
    day = day.subtract(const Duration(days: 1));
  }
}

DateTime budgetMonthOf(DateTime bookingDate, DateTime? explicitBudgetMonth) {
  final value = explicitBudgetMonth ?? bookingDate;
  return DateTime(value.year, value.month);
}

/// Calculates the real payment date for a payment belonging to [budgetMonth].
///
/// Start and middle are paid in the same economic month. End is paid on the
/// penultimate working day of the previous month, as commonly used for
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
    'end' => penultimateWorkingDay(DateTime(month.year, month.month - 1)),
    _ => DateTime(
      month.year,
      month.month,
      selectedDay.clamp(1, DateTime(month.year, month.month + 1, 0).day),
    ),
  };
}
