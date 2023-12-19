class DsaDate {
  int day;
  int month;
  int year;

  DsaDate(this.year, this.month, this.day);

  bool isEqual(DsaDate other) {
    return year == other.year && month == other.month && day == other.day;
  }

  void copyFrom(DsaDate other) {
    day = other.day;
    month = other.month;
    year = other.year;
  }

  static DsaDate copy(DsaDate other){
    return DsaDate(0,0,1)..copyFrom(other);
  }

  static final List<String> months = [
    "Praios", "Rondra", "Efferd", "Travia", "Boron",
    "Hesinde", "Firun", "Tsa", "Phex", "Peraine",
    "Ingerimm", "Rahja"
  ];

  static final List<String> weekdays = [
    "Rohalstag", "Feuertag", "Wassertag", "Windstag", "Erdtag",
    "Markttag", "Praiostag"
  ];

  static final List<String> weekdaysShort = [
    "RO", "FE", "WA", "WI", "ER",
    "MA", "PR"
  ];
  static int getDaysInMonth(int month){
    return month == 11 ? 35 : 30;
  }

  String getWeekday() {
    List<int> monthDays = List.filled(11, 30, growable: true)..add(35);
    int totalDays = day - 2;
    for (int i = 0; i < month; i++) {
      totalDays += monthDays[i];
    }
    totalDays += (year * 365);

    int weekdayIndex = totalDays % 7;
    return DsaDate.weekdays[weekdayIndex];
  }

  @override
  String toString() {
    return '$day. ${months[month]} $year BF';
  }

  static DsaDate nextDay(DsaDate currentDay) {
    int newDay = currentDay.day + 1;
    int newMonth = currentDay.month;
    int newYear = currentDay.year;

    if (newDay > getDaysInMonth(currentDay.month)) {
      newDay = 1;
      newMonth += 1;

      if (newMonth > 11) { // Überschreiten des Jahres
        newMonth = 0;
        newYear += 1;
      }
    }

    return DsaDate(newYear, newMonth, newDay);
  }

  static DsaDate previousDay(DsaDate currentDay) {
    int newDay = currentDay.day - 1;
    int newMonth = currentDay.month;
    int newYear = currentDay.year;

    if (newDay < 1) {
      newMonth -= 1;

      if (newMonth < 0) { // Übergang ins vorherige Jahr
        newMonth = 11; // Letzter Monat des Jahres
        newYear -= 1;
        newDay = getDaysInMonth(newMonth); // Letzter Tag des letzten Monats
      } else {
        newDay = getDaysInMonth(newMonth); // Letzter Tag des vorherigen Monats
      }
    }

    return DsaDate(newYear, newMonth, newDay);
  }

  static DsaDate? fromString(String dateString) {
    final parts = dateString.split(' ');
    if (parts.length != 4) {
      //throw FormatException('Invalid date format');
      return null;
    }

    final day = int.tryParse(parts[0].replaceAll('.', ''));
    final monthName = parts[1];
    final year = int.tryParse(parts[2]);

    if (day == null || year == null) {
      //throw FormatException('Invalid day or year in date');
      return null;
    }

    final month = months.indexOf(monthName);
    if (month == -1) {
      //throw FormatException('Invalid month name');
      return null;
    }

    return DsaDate(year, month, day);
  }
}
