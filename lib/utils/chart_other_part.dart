String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

int getDaysInMonth(int month, int year) {
  if (month == 2) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28;
  }
  return [4, 6, 9, 11].contains(month) ? 30 : 31;
}

String getCurrentMonthName() {
  int currentMonth = DateTime.now().month;
  return getMonthName(currentMonth);
}
