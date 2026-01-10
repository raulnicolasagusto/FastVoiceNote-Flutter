// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FastVoiceNote';

  @override
  String get notesTitle => 'Notes';

  @override
  String get searchPlaceholder => 'Search notes';

  @override
  String get allTab => 'All';

  @override
  String get folderTab => 'Folder';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get showTips => 'Show Tips';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get newNote => 'New Note';

  @override
  String get quickVoiceNote => 'Quick Voice Note';

  @override
  String get recording => 'Recording...';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get moreOptions => 'More Options';

  @override
  String get checklist => 'Checklist';

  @override
  String get reminder => 'Reminder';

  @override
  String get disableReminder => 'Disable Reminder';

  @override
  String get reminderDisabled => 'Reminder disabled';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get share => 'Share';

  @override
  String get addToHomeScreen => 'Add to Home Screen';

  @override
  String get addItem => 'Add item';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get deleteCancel => 'Cancel';

  @override
  String get deleteSingleTitle => 'Delete note';

  @override
  String get deleteSingleMessage =>
      'Are you sure you want to delete this note?';

  @override
  String get deleteMultipleTitle => 'Delete notes';

  @override
  String deleteMultipleMessage(Object count) {
    return 'Delete $count selected notes?';
  }

  @override
  String get addMedia => 'Add Media';

  @override
  String get takePicture => 'Take a picture';

  @override
  String get uploadFile => 'Upload a picture or file';

  @override
  String get photoAddedSuccess => 'Photo added successfully';

  @override
  String get noteLockedTitle => 'Note Locked';

  @override
  String get noteLockedMessage =>
      'The note is locked. Unlock it to make changes.';

  @override
  String get noteLockedDeleteMultiple =>
      'Cannot delete notes. One or more notes are locked.';

  @override
  String get noteLocked => 'Note locked';

  @override
  String get noteUnlocked => 'Note unlocked';

  @override
  String get ok => 'OK';

  @override
  String get shareOptions => 'Share Options';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get createdWithNotes => 'Created with Fast Voice Note';

  @override
  String get tipChecklistVoice =>
      'Tap the quick voice note button and say \"new list\" followed by the items. We\'ll automatically create a checklist you can mark as you go.';

  @override
  String get tipReminder =>
      'After recording a note or creating a list, say something like \"remind me tomorrow at 4 PM\". A reminder will be scheduled for that note.';

  @override
  String get shortcutQuickVoice => 'Quick Voice Note';

  @override
  String get shortcutQuickVoiceDesc => 'Start recording a voice note instantly';

  @override
  String get processing => 'Processing...';

  @override
  String get tapToCreateFirstNote => 'Tap to create your first note';

  @override
  String get reminderNotificationTitle => 'Note Reminder';

  @override
  String reminderNotificationBody(Object title) {
    return 'Reminder for note: $title';
  }
}
