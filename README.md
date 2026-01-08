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

### 🎨 **Rich Note Features**
- **Color-coded notes** with 12 predefined color themes
- **Pin favorites** for quick access
- **Image attachments** (camera or gallery)
- **File attachments** with preview
- **Search within notes** with text highlighting
- **Share notes** as text or images
- **Home screen widgets** for quick access

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
│   │   │   ├── views/         # Detail screen
│   │   │   ├── widgets/       # Checklist, Color picker, etc.
│   │   │   └── services/      # Image, Share, Widget services
│   │   ├── settings/          # Theme, Language, Tips
│   │   └── transcription/     # Voice recording & processing
│   │       ├── services/      # Audio recorder service
│   │       ├── utils/         # Checklist & Add-to-note processors
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

## 🎯 Core Features Deep Dive

### Voice-to-Checklist Detection

The app uses intelligent natural language processing to detect checklist intentions:

**Supported Trigger Phrases:**
- **English**: "new list", "new grocery list", "shopping list", "todo list", etc.
- **Spanish**: "nueva lista", "lista de compras", "lista del super", etc.
- **Portuguese**: "nova lista", "lista de compras", "lista do mercado", etc.

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
```

**Key Features:**
- PCM 16-bit audio recording at 16kHz (Whisper native format)
- Float32 sample normalization (-1.0 to 1.0)
- Thread-safe FFI calls with mutex protection
- Efficient memory management with calloc/free
- Language-specific transcription (en/es/pt)

### Database Schema

```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  color TEXT NOT NULL,
  has_image INTEGER DEFAULT 0,
  has_voice INTEGER DEFAULT 0,
  is_pinned INTEGER DEFAULT 0,
  is_locked INTEGER DEFAULT 0,
  folder_id TEXT
);

CREATE TABLE attachments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  note_id TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_name TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (note_id) REFERENCES notes(id)
);
```

## 📱 Screenshots

*(Add screenshots here showcasing different features)*

## 🧪 Testing

The project includes comprehensive test files for voice detection:

```bash
# Run voice detection tests
dart test_voice_detection.dart

# Run checklist creation tests
dart test_demo_in_note_voice.dart

# Run error handling tests
dart test_error_handling.dart
```

## 🛠️ Development Guidelines

### Code Style
- Follow Dart/Flutter official style guide
- Use `const` constructors where possible
- Prefer `StatelessWidget` over `StatefulWidget` when state is not needed
- Always use localized strings (never hardcode text)

### Adding New Features
1. Create feature-specific folder under `lib/src/features/`
2. Follow clean architecture: `models/`, `views/`, `widgets/`, `services/`
3. Add translations to all 3 `.arb` files simultaneously
4. Update documentation in `agents/` folder
5. Write tests for critical functionality

### Localization Workflow
1. Add key to `app_en.arb`, `app_es.arb`, `app_pt.arb`
2. Run `flutter gen-l10n`
3. Use `AppLocalizations.of(context)!.keyName` in code
4. Never hardcode strings visible to users

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[Whisper.cpp](https://github.com/ggerganov/whisper.cpp)** by Georgi Gerganov - Efficient C++ implementation of OpenAI's Whisper
- **[OpenAI Whisper](https://github.com/openai/whisper)** - Original speech recognition model
- **Flutter Team** - Amazing cross-platform framework
- **Drift Team** - Reactive persistence library for Flutter

## 📧 Contact

- **GitHub**: [@yourusername](https://github.com/yourusername)
- **Email**: your.email@example.com
- **LinkedIn**: [Your Name](https://linkedin.com/in/yourprofile)

## 🎖️ Skills Demonstrated

This project showcases expertise in:

### Flutter/Dart Development
- ✅ Clean Architecture & SOLID principles
- ✅ State Management (Provider pattern)
- ✅ Navigation (GoRouter)
- ✅ Custom widgets & animations
- ✅ Material Design 3 implementation

### Native Integration
- ✅ FFI (Foreign Function Interface)
- ✅ C++ native module development
- ✅ CMake build configuration
- ✅ Platform-specific code (Android/iOS)

### AI & Machine Learning
- ✅ On-device AI model integration
- ✅ Speech-to-text processing
- ✅ Natural language processing
- ✅ Multi-language AI model optimization

### Database & Persistence
- ✅ SQLite with Drift ORM
- ✅ Complex queries & relationships
- ✅ Data migration strategies
- ✅ Efficient data caching

### Internationalization
- ✅ Multi-language support (3 languages)
- ✅ ARB file management
- ✅ Locale-aware formatting
- ✅ RTL support ready

### UX/UI Design
- ✅ Material Design 3
- ✅ Responsive layouts
- ✅ Dark/Light theme support
- ✅ Accessibility considerations
- ✅ Micro-interactions

### Software Engineering Best Practices
- ✅ Modular architecture
- ✅ Code reusability
- ✅ Documentation
- ✅ Testing strategies
- ✅ Version control (Git)

---

**Built with ❤️ using Flutter**

*This project demonstrates production-ready code suitable for real-world applications and showcases a wide range of technical skills relevant to modern mobile development.*
