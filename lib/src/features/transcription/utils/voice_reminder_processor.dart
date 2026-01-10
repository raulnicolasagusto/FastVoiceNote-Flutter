import 'date_time_extractor.dart';
import 'reminder_info.dart';

class VoiceReminderProcessor {
  static const Map<String, List<String>> _triggerKeywords = {
    'en': [
      'remind me',
      'set reminder',
      'notify me',
      'remind about',
      'notification for',
      'schedule reminder',
      'alarm for',
      'remind me at',
      'set reminder for',
      'reminder at',
    ],
    'es': [
      'recuérdame',
      'recuerdame',
      'activa notificación',
      'activa notificacion',
      'avísame',
      'avisame',
      'programa recordatorio',
      'recordatorio para',
      'avísame a las',
      'avisame a las',
      'notifica el',
      'alarma para',
      'recordatorio a las',
      'notificación para',
      'notificacion para',
    ],
    'pt': [
      'lembre-me',
      'lembre me',
      'ative notificação',
      'ative notificacao',
      'avise-me',
      'avise me',
      'agenda lembrete',
      'lembrete para',
      'avise-me às',
      'avise me as',
      'notifique o',
      'alarme para',
      'lembrete às',
      'lembrete as',
      'notificação para',
      'notificacao para',
    ],
  };

  static ReminderInfo detectReminder(String text, String language) {
    final normalizedText = text.toLowerCase();
    final keywords = _triggerKeywords[language] ?? _triggerKeywords['en']!;

    bool hasTrigger = false;
    for (final keyword in keywords) {
      if (normalizedText.contains(keyword)) {
        hasTrigger = true;
        break;
      }
    }

    if (!hasTrigger) {
      return ReminderInfo(
        hasReminder: false,
        reminderTime: DateTime.now(),
        cleanedText: text,
      );
    }

    final reminderTime = DateTimeExtractor.extractDateTime(text, language);

    if (reminderTime == null) {
      return ReminderInfo(
        hasReminder: false,
        reminderTime: DateTime.now(),
        cleanedText: text,
      );
    }

    return ReminderInfo(
      hasReminder: true,
      reminderTime: reminderTime,
      cleanedText: text,
    );
  }
}
