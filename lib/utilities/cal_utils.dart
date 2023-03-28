int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

DateTime lastDayOfCurrentYear() {
  return DateTime(DateTime.now().year, 12 + 1, 1);
}

DateTime lastDayOfCurrentYearAndMore(int addYear) {
  return DateTime(DateTime.now().year + addYear, 12 + 1, 1);
}

int getNumMonthsLeft(DateTime input) {
  return 12 - input.month;
}

int getNumOfDaysInNextMonth(DateTime input) {
  return DateTime(input.year, input.month + 2, 0).day;
}
