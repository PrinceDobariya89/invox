import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYearFormat = DateFormat('MMM yyyy');

  static String toDisplay(DateTime? date) {
    if (date == null) return '-';
    return _displayFormat.format(date);
  }

  static String toShort(DateTime? date) {
    if (date == null) return '-';
    return _shortFormat.format(date);
  }

  static String toIso(DateTime? date) {
    if (date == null) return '';
    return _isoFormat.format(date);
  }

  static String toMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String toShortMonthYear(DateTime date) {
    return _shortMonthYearFormat.format(date);
  }

  static DateTime? parseIso(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Calculates days overdue relative to now
  static int daysOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (today.isAfter(due)) {
      return today.difference(due).inDays;
    }
    return 0;
  }
}

