import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FastVoiceNote'**
  String get appTitle;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchPlaceholder;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @folderTab.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderTab;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @showTips.
  ///
  /// In en, this message translates to:
  /// **'Show Tips'**
  String get showTips;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @quickVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Quick Voice Note'**
  String get quickVoiceNote;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @disableReminder.
  ///
  /// In en, this message translates to:
  /// **'Disable Reminder'**
  String get disableReminder;

  /// No description provided for @reminderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Reminder disabled'**
  String get reminderDisabled;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get addToHomeScreen;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// No description provided for @deleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteCancel;

  /// No description provided for @deleteSingleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteSingleTitle;

  /// No description provided for @deleteSingleMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteSingleMessage;

  /// No description provided for @deleteMultipleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete notes'**
  String get deleteMultipleTitle;

  /// No description provided for @deleteMultipleMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected notes?'**
  String deleteMultipleMessage(Object count);

  /// No description provided for @addMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Media'**
  String get addMedia;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePicture;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a picture or file'**
  String get uploadFile;

  /// No description provided for @photoAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get photoAddedSuccess;

  /// No description provided for @noteLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Locked'**
  String get noteLockedTitle;

  /// No description provided for @noteLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'The note is locked. Unlock it to make changes.'**
  String get noteLockedMessage;

  /// No description provided for @noteLockedDeleteMultiple.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete notes. One or more notes are locked.'**
  String get noteLockedDeleteMultiple;

  /// No description provided for @noteLocked.
  ///
  /// In en, this message translates to:
  /// **'Note locked'**
  String get noteLocked;

  /// No description provided for @noteUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Note unlocked'**
  String get noteUnlocked;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @shareOptions.
  ///
  /// In en, this message translates to:
  /// **'Share Options'**
  String get shareOptions;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareAsImage;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @createdWithNotes.
  ///
  /// In en, this message translates to:
  /// **'Created with Fast Voice Note'**
  String get createdWithNotes;

  /// No description provided for @tipChecklistVoice.
  ///
  /// In en, this message translates to:
  /// **'Tap the quick voice note button and say \"new list\" followed by the items. We\'ll automatically create a checklist you can mark as you go.'**
  String get tipChecklistVoice;

  /// No description provided for @tipReminder.
  ///
  /// In en, this message translates to:
  /// **'After recording a note or creating a list, say something like \"remind me tomorrow at 4 PM\". A reminder will be scheduled for that note.'**
  String get tipReminder;

  /// No description provided for @shortcutQuickVoice.
  ///
  /// In en, this message translates to:
  /// **'Quick Voice Note'**
  String get shortcutQuickVoice;

  /// No description provided for @shortcutQuickVoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Start recording a voice note instantly'**
  String get shortcutQuickVoiceDesc;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @tapToCreateFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Tap to create your first note'**
  String get tapToCreateFirstNote;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Reminder'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder for note: {title}'**
  String reminderNotificationBody(Object title);

  /// No description provided for @reminderSetForToday.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for today at'**
  String get reminderSetForToday;

  /// No description provided for @reminderSetForDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for'**
  String get reminderSetForDate;

  /// No description provided for @tapToAddContent.
  ///
  /// In en, this message translates to:
  /// **'Tap to add content'**
  String get tapToAddContent;

  /// No description provided for @processingChunk.
  ///
  /// In en, this message translates to:
  /// **'Processing chunk {currentChunk} of {totalChunks}'**
  String processingChunk(int currentChunk, int totalChunks);

  /// No description provided for @meeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meeting;

  /// No description provided for @recordMeeting.
  ///
  /// In en, this message translates to:
  /// **'Record Meeting'**
  String get recordMeeting;

  /// No description provided for @inaudible.
  ///
  /// In en, this message translates to:
  /// **'[Inaudible]'**
  String get inaudible;

  /// No description provided for @meetingMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Metadata'**
  String get meetingMetadataTitle;

  /// No description provided for @meetingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get meetingDuration;

  /// No description provided for @meetingChunks.
  ///
  /// In en, this message translates to:
  /// **'Chunks'**
  String get meetingChunks;

  /// No description provided for @meetingQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get meetingQuality;

  /// No description provided for @transcribe.
  ///
  /// In en, this message translates to:
  /// **'TRANSCRIBE'**
  String get transcribe;

  /// No description provided for @noTextDetected.
  ///
  /// In en, this message translates to:
  /// **'No text detected in the image'**
  String get noTextDetected;

  /// No description provided for @transcribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get transcribing;

  /// No description provided for @drawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get drawing;

  /// No description provided for @drawingStudio.
  ///
  /// In en, this message translates to:
  /// **'Drawing Studio'**
  String get drawingStudio;

  /// No description provided for @brush.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get brush;

  /// No description provided for @eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraser;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @strokeSize.
  ///
  /// In en, this message translates to:
  /// **'Stroke Size'**
  String get strokeSize;

  /// No description provided for @openFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Open File?'**
  String get openFileTitle;

  /// No description provided for @openFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to open this file with an external application?'**
  String get openFileMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
