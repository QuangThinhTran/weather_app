import 'package:intl/intl.dart';

class DateFormatter {
  static String formatLastUpdated(DateTime dateTime) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(dateTime);
  }

  static String formatForecastDate(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final today = DateTime(now.year, now.month, now.day);
    
    if (isSameDay(dateTime, today)) {
      return 'Hôm nay';
    } else if (isSameDay(dateTime, tomorrow)) {
      return 'Ngày mai';
    } else {
      final formatter = DateFormat('EEE, MMM d');
      return formatter.format(dateTime);
    }
  }

  static String formatHourlyTime(DateTime dateTime) {
    final formatter = DateFormat('h a');
    return formatter.format(dateTime);
  }

  static String formatFullDate(DateTime dateTime) {
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    return formatter.format(dateTime);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(dateTime, tomorrow);
  }
}