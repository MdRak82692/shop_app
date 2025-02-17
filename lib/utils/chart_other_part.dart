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

const List<String> months = [
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

String getCollectionName(String chartType) {
  switch (chartType) {
    case 'Investment':
      return 'investment';
    case 'Other Cost':
      return 'otherCost';
    case 'Products Cost':
      return 'products';
    case 'Products Sale':
      return 'sales';
    case 'Staff Salary':
      return 'staffsalary';
    default:
      return 'products';
  }
}

String getValueFieldName(String chartType) {
  switch (chartType) {
    case 'Investment':
      return 'sale';
    case 'Other Cost':
    case 'Products Cost':
      return 'cost';
    case 'Products Sale':
      return 'sale';
    case 'Staff Salary':
      return 'salary';
    default:
      return 'sale';
  }
}
