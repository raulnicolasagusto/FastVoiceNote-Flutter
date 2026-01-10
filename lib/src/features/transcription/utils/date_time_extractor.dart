import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class DateTimeExtractor {
  static bool _isInitialized = false;

  static void _ensureInitialized() {
    if (!_isInitialized) {
      tz_data.initializeTimeZones();
      _isInitialized = true;
    }
  }

  static DateTime? extractDateTime(String text, String language) {
    final lowerText = text.toLowerCase();

    final timeMatch = _extractTime(lowerText);
    if (timeMatch == null) return null;

    final relativeDay = _extractRelativeDay(lowerText, language);

    final baseDate = relativeDay ?? DateTime.now();
    final reminderTime = _combineDateTime(baseDate, timeMatch);

    return isValidReminderTime(reminderTime) ? reminderTime : null;
  }

  static bool isValidReminderTime(DateTime dateTime) {
    final now = DateTime.now();
    final minFuture = now.add(const Duration(minutes: 1));
    return dateTime.isAfter(minFuture);
  }

  static DateTime? _extractTime(String text) {
    final time24hPattern = RegExp(r'\b([01]?[0-9]|2[0-3]):([0-5][0-9])\b');
    final time12hPattern = RegExp(r'\b(0?[1-9]|1[0-2]):([0-5][0-9])\s?(AM|PM|am|pm)\b');

    final match12h = time12hPattern.firstMatch(text);
    if (match12h != null) {
      final hour = int.parse(match12h.group(1)!);
      final minute = int.parse(match12h.group(2)!);
      final period = match12h.group(3)!.toLowerCase();

      int hour24 = hour;
      if (period == 'pm' && hour != 12) {
        hour24 += 12;
      } else if (period == 'am' && hour == 12) {
        hour24 = 0;
      }

      return DateTime(2024, 1, 1, hour24, minute);
    }

    final match24h = time24hPattern.firstMatch(text);
    if (match24h != null) {
      final hour = int.parse(match24h.group(1)!);
      final minute = int.parse(match24h.group(2)!);
      return DateTime(2024, 1, 1, hour, minute);
    }

    return null;
  }

  static DateTime? _extractRelativeDay(String text, String language) {
    Map<String, List<String>> dayPatterns = {
      'en': ['today', 'tomorrow'],
      'es': ['hoy', 'mañana', 'maana'],
      'pt': ['hoje', 'amanhã', 'amanha'],
    };

    final patterns = dayPatterns[language] ?? dayPatterns['en']!;
    final now = DateTime.now();

    for (final pattern in patterns) {
      if (text.contains(pattern)) {
        if (pattern == 'today' || pattern == 'hoy' || pattern == 'hoje') {
          return now;
        } else if (pattern == 'tomorrow' || pattern == 'mañana' || pattern == 'maana' || pattern == 'amanhã' || pattern == 'amanha') {
          return now.add(const Duration(days: 1));
        }
      }
    }

    return null;
  }

  static DateTime _combineDateTime(DateTime baseDate, DateTime timeOnly) {
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      timeOnly.hour,
      timeOnly.minute,
    );
  }

  static DateTime toLocalTimeZone(DateTime dateTime) {
    _ensureInitialized();
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
