# FastVoiceNote 🎤📝

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A powerful, AI-powered voice note-taking application built with **Flutter** that leverages **Whisper.cpp** for on-device speech-to-text transcription. Create notes, checklists, and reminders using your voice - all processed locally with no internet connection required.

## ✨ Key Features

### 🎙️ **Voice-to-Text Transcription**
- **On-device AI processing** using Whisper.cpp (Tiny Q5_1 model)
- **Multi-language support**: English, Spanish, and Portuguese
- **No internet required** - complete privacy and offline functionality
- **Smart transcription** with error correction for common speech-to-text mistakes

### 📋 **Intelligent Checklist Creation**
- **Voice-triggered checklists** - say "new list" followed by items
- **Automatic item extraction** from natural speech
- **Multi-language keyword detection** (12+ trigger phrases per language)
- **Smart separators** - recognizes commas, "and", "also", etc.
- **Interactive checklists** - tap to check/uncheck items

### 🗒️ **In-Note Voice Recording**
- **Context-aware recording** - add voice notes to existing notes
- **Automatic checklist expansion** - say "add" to extend lists
- **Seamless text appending** for regular notes
- **Voice integration** from note detail view

### 🎙️ **Meeting Recording (Long-form Audio)**
- **Smart chunking** - Audio divided into 20-second segments with 2-second overlap
- **Resilient processing** - Continues transcription even if chunks fail (marks `[inaudible]`)
- **Auto-stop at 1 hour** - Maximum recording duration enforced automatically
- **Real-time timer** - Visible countdown during recording (HH:MM:SS format)
- **Progress tracking** - Shows "Processing chunk X of Y" during transcription
- **Quality metrics** - Displays transcription success percentage at the end
- **Full transcription** - Generates complete meeting transcript with metadata
- **Meeting details** - Includes duration, audio segments processed, and quality score
- **Language-aware** - Uses app's selected language (EN/ES/PT) from settings
- **Error recovery** - Never aborts due to single chunk failures

### 🎨 **Rich Note Features**
- **Color-coded notes** with 12 predefined color themes
- **Pin favorites** for quick access
- **Smart reminders** with scheduled notifications
- **Image attachments** (camera or gallery)
- **File attachments** with preview
- **Search within notes** with text highlighting
- **Share notes** as text or images
- **Home screen widgets** for quick access

### 🎨 **Drawing Canvas (Sketches)**
- **Fluid drawing engine** - High-performance sketching with CustomPainter
- **Smart Eraser Tool** - Gradually remove content with adjustable thickness
- **Pro Color Palette** - Pick any color for your annotations and sketches
- **Variable Brush Thickness** - From fine details to broad strokes
- **Undo/Redo support** - Effortless correction for your drawings
- **Local Persistence** - Drawings are saved as PNG and stored as note attachments


### ⏰ **Smart Reminders & Notifications**
- **Scheduled notifications** for time-sensitive notes
- **On-device alarm scheduling** with exact timing
- **Toggle on/off** - easily activate/deactivate reminders
- **Persistent across reboots** - reminders survive device restarts
- **Battery-optimized** - works with Android's Doze mode
- **Custom notification icon** with Material Design
- **Multi-language support** for reminder messages

### 🌍 **Complete Internationalization**
- **3 languages fully supported**: English, Spanish, Portuguese
- **Automatic language detection** for voice transcription
- **Dynamic UI translations** with proper localization
- **Cultural considerations** for date/time formatting

### 💡 **Interactive User Guidance**
- **Smart tooltips** that educate users about features
- **Loop-based learning** for new users
- **Manual dismissal** with toggle control
- **Context-sensitive help** system

### 🎭 **Modern UI/UX**
- **Material Design 3** with dynamic theming
- **Light and Dark modes**
- **Staggered grid layout** (masonry style)
- **Smooth animations** and transitions
- **Auto-save functionality** - no "Save" button needed
- **Inline editing** with tap-to-edit paradigm

## 🏗️ Architecture

### Technology Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **AI Model**: Whisper.cpp (Tiny Q5_1, ~32MB)
- **Database**: Drift (SQLite wrapper)
- **State Management**: Provider pattern
- **Navigation**: GoRouter
- **Native Bridge**: FFI (Foreign Function Interface)
- **Localization**: flutter_localizations with ARB files

### Project Structure

```
lib/
 ├── src/
 │   ├── core/
 │   │   ├── database/          # Drift database implementation
 │   │   ├── l10n/              # Localization files (3 languages)
 │   │   ├── router/            # GoRouter configuration
 │   │   ├── theme/             # Material 3 themes
 │   │   └── transcription/     # Whisper FFI bridge
 │   ├── features/
 │   │   ├── home/              # Home screen with note grid
 │   │   ├── notes/             # Note CRUD operations
 │   │   │   ├── models/        # Note, Checklist models
 │   │   │   ├── providers/     # State management
 │   │   │   ├── views/         # Detail screen, Drawing canvas screen
 │   │   │   ├── widgets/       # Checklist, Color picker, etc.
 │   │   │   └── services/      # Image, Share, Widget services
 │   │   ├── notifications/     # Reminder notifications
 │   │   │   └── services/      # Notification scheduling service
 │   │   ├── settings/          # Theme, Language, Tips
 │   │   └── transcription/     # Voice recording & processing
 │   │       ├── services/      # Audio recorder & Meeting recorder services
 │   │       ├── utils/         # Checklist, Add-to-note, Audio chunker, Meeting processors
 │   │       └── widgets/       # Recording dialog
 │   └── shared/
 │       └── widgets/           # Reusable components (Drawer, etc.)
 └── main.dart                  # App entry point

native/
├── native_lib.cpp             # C++ FFI wrapper for Whisper
└── whisper.cpp/               # Whisper.cpp library (submodule)

android/
└── app/src/main/cpp/
    └── CMakeLists.txt         # Native build configuration

assets/
└── models/
    └── ggml-tiny-q5_1.bin     # Whisper AI model (~32MB)
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for platform-specific builds)
- CMake 3.18+ (for native compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/FastVoiceNote-Flutter.git
   cd FastVoiceNote-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Generate database code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## ⚡ Android App Shortcut & Deep Links

- **App Shortcut:** Long-press the app icon to trigger "Quick Voice Note" and start recording instantly.
- **Deep Link Scheme:** `fastvoicenote://quick_voice_note` opens the app and auto-starts recording.
- **Implementation:**
   - Manifest + intent filter in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
   - Shortcut definition in [android/app/src/main/res/xml/shortcuts.xml](android/app/src/main/res/xml/shortcuts.xml)
   - Runtime handling with `app_links` in [lib/main.dart](lib/main.dart) and a global stream in [lib/src/core/utils/quick_voice_intent.dart](lib/src/core/utils/quick_voice_intent.dart)
- **Note:** Shortcut support is Android-specific.

## 🛡️ Privacy & Play Store Compliance

- **Privacy Policy URL:** https://fastvoicenote.blogspot.com/p/privacy-policy.html
- **Data Safety:** Declares microphone access; transcription is processed locally on-device; no data is collected or shared.
- **Manifest Permissions:** `RECORD_AUDIO` only; `CAMERA` removed.
- **Submission Tips:** In Play Console, add the policy URL under App content → Privacy policy and complete Data Safety with the above details.

## 🔧 Settings Persistence

- **Theme Mode:** Dark/Light/System selection is persisted via `SharedPreferences`.
- **Show Tips:** The guidance toggle is persisted and respected across restarts.
- **Locale:** The chosen language (`en`, `es`, `pt`) is saved and applied on startup.
- **Key Files:** [lib/src/features/settings/providers/settings_provider.dart](lib/src/features/settings/providers/settings_provider.dart), [lib/main.dart](lib/main.dart)

## 🎯 Core Features Deep Dive

### Smart Reminders & Notifications

The app includes a robust notification system for time-based reminders:

**Key Features:**
- **Exact alarms** - Uses `AndroidScheduleMode.exactAllowWhileIdle` for precise timing
- **Permission handling** - Automatically requests notification and alarm permissions on Android 13+
- **Timezone aware** - Correctly handles timezone conversions using `timezone` package
- **Boot persistence** - Reminders survive device restarts with `BOOT_COMPLETED` receiver
- **Battery optimization** - Works with Android Doze mode using `WAKE_LOCK`
- **Visual feedback** - Custom monochrome notification icon for Android standards

**Architecture:**
```
Note with reminder → NotificationService → flutter_local_notifications
        ↓                       ↓
  Database (reminderAt)    Android AlarmManager
        ↓                       ↓
    Provider updates        Exact alarm scheduled
        ↓                       ↓
    UI refreshes           Notification fires at exact time
```

**Implementation Details:**
- **Service:** `lib/src/features/notifications/services/notification_service.dart`
- **Permissions:** `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `WAKE_LOCK`
- **Manifest receivers:** `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`
- **Icon:** Custom `ic_notification.xml` drawable for proper Android notification appearance

**User Flow:**
1. Open note options → Select "Reminder"
2. Pick date and time
3. System schedules exact alarm
4. At scheduled time, notification appears with note title
5. To disable: Open options → "Disable Reminder" (no date picker, instant removal)

### Voice-to-Checklist Detection

The app uses intelligent natural language processing to detect checklist intentions:

**Supported Trigger Phrases:**
- **English**: "new list", "new grocery list", "shopping list", "todo list", etc.
- **Spanish**: "nueva lista", "lista de compras", "lista del super", etc.
- **Portuguese**: "nova lista", "lista de compras", "lista do mercado", etc.

### Meeting Recording & Transcription

For long-form audio recordings (up to 1 hour), the app uses intelligent chunking:

**Architecture:**
```
Recording (up to 1 hour)
         ↓
Stop (manual or auto)
         ↓
Audio chunking (20s chunks + 2s overlap)
         ↓
Chunk-by-chunk transcription with Whisper
         ↓
Resilient error handling (continue on failures)
         ↓
Concatenate + metadata generation
         ↓
Create note with full transcription
```

**Key Features:**
- **Chunk Duration**: 20 seconds per segment
- **Overlap**: 2 seconds between chunks (prevents cut words)
- **Sample Rate**: 16,000 Hz (Whisper native format)
- **Max Duration**: 1 hour (auto-stop enforced)
- **Error Handling**: Marks failed chunks as `[inaudible]` and continues
- **Progress Tracking**: Real-time UI feedback during processing
- **Quality Scoring**: Calculates % of successfully transcribed chunks

**Files:**
- Service: `lib/src/features/transcription/services/meeting_recorder_service.dart`
- Chunking: `lib/src/features/transcription/utils/audio_chunker.dart`
- Processing: `lib/src/features/transcription/utils/meeting_transcription_processor.dart`

**Example Flow:**
```
User says: "new list apples, milk, bread, and eggs"
        ↓
AI transcribes with Whisper
        ↓
VoiceToChecklistProcessor detects trigger
        ↓
Extracts items: ["apples", "milk", "bread", "eggs"]
        ↓
Creates interactive checklist note
```

### Whisper Integration

**Architecture:**
```
Flutter UI → AudioRecorderService → WhisperBridge → FFI → native_lib.cpp → whisper.cpp → Model
Flutter UI → MeetingRecorderService → AudioChunker → MeetingTranscriptionProcessor → WhisperBridge
```

**Key Features:**
- PCM 16-bit audio recording at 16kHz (Whisper native format)
- Float32 sample normalization (-1.0 to 1.0)
- Thread-safe FFI calls with mutex protection
- Efficient memory management with calloc/free
- Language-specific transcription (en/es/pt)
- Smart chunking with overlap for long recordings
- Resilient error handling (never aborts on single chunk failures)
- ✅ Version control (Git)

---

**Built with ❤️ using Flutter**

*This project demonstrates production-ready code suitable for real-world applications and showcases a wide range of technical skills relevant to modern mobile development.*
