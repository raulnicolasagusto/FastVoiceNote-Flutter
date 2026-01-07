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
}
