import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _displayTimeFormat = DateFormat('hh:mm a');
  static final DateFormat _fullFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  /// Returns date string in YYYY-MM-DD format
  static String toDateString(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Returns display-friendly date string
  static String toDisplayDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return _displayDateFormat.format(dateTime);
  }

  /// Returns display-friendly time string
  static String toDisplayTime(DateTime dateTime) {
    return _displayTimeFormat.format(dateTime);
  }

  /// Returns full display format
  static String toFullDisplay(DateTime dateTime) {
    return _fullFormat.format(dateTime);
  }

  /// Returns 24h time string
  static String toTimeString(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Returns start of today
  static DateTime get todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns end of today
  static DateTime get todayEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  /// Checks if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns a DateTime from a YYYY-MM-DD string
  static DateTime fromDateString(String dateString) {
    return _dateFormat.parse(dateString);
  }
}
