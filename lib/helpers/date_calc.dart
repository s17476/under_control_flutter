class DateCalc {
  // this method calculates the date of next cyclic task execution
  // date is counted from task execution date according
  // interval parameter
  static DateTime? getNextDate(DateTime date, String interval) {
    DateTime? resultDate;
    List<String> duration = interval.split(' ');
    if (duration[1] == 'week' || duration[1] == 'weeks') {
      resultDate = DateTime(
        date.year,
        date.month,
        date.day + (int.parse(duration[0]) * 7),
      );
    } else if (duration[1] == 'month' || duration[1] == 'months') {
      resultDate = DateTime(
        date.year,
        date.month + int.parse(duration[0]),
        date.day,
      );
    } else if (duration[1] == 'year' || duration[1] == 'years') {
      resultDate = DateTime(
        date.year + int.parse(duration[0]),
        date.month,
        date.day,
      );
    }
    return resultDate;
  }
}
