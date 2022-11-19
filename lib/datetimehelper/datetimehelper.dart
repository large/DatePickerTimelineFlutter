///Helper class for handling day light saving
///October for instance gets two 30.10
///Duration will add it twice because of a "correct" time estimate

extension DateTimeExtensions on DateTime {
  //Using "duration" will mess up during
  DateTime addDays(int daysToAdd) {
    return DateTime(
      this.year,
      this.month,
      this.day + daysToAdd,
      this.hour,
      this.minute,
      this.second,
      this.millisecond,
      this.microsecond,
    );
  }

  ///Return directly just year, month and day without time
  DateTime dateWithoutTime()
  {
    return DateTime(this.year, this.month, this.day);
  }

  /// Return true if date is equal
  bool compareDateWithoutTime(DateTime date) {
    return this.day == date.day &&
        this.month == date.month &&
        this.year == date.year;
  }
}
