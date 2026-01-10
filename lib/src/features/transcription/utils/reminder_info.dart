class ReminderInfo {
  final bool hasReminder;
  final DateTime reminderTime;
  final String cleanedText;

  ReminderInfo({
    required this.hasReminder,
    required this.reminderTime,
    required this.cleanedText,
  });
}
