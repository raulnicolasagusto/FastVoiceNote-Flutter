import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/settings/providers/settings_provider.dart';
import 'src/features/notes/providers/notes_provider.dart';
import 'src/core/l10n/generated/app_localizations.dart';
import 'src/core/utils/quick_voice_intent.dart';
import 'src/features/notifications/services/notification_service.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'src/core/database/app_database.dart';
import 'src/core/services/ad_service.dart';
import 'src/core/services/shortcut_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdService().initialize();

  // Initialize Dynamic Shortcuts
  ShortcutService().initialize();

  // Initialize notification service with error handling
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
    // Continue app initialization even if notifications fail
  }

  // Load persisted settings to avoid flicker on startup
  Locale? initialLocale;
  ThemeMode? initialThemeMode;
  bool? initialShowTips;
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale_code');
    if (code != null && ['en', 'es', 'pt'].contains(code)) {
      initialLocale = Locale(code);
    }
    final themeStr = prefs.getString('app_theme_mode');
    switch (themeStr) {
      case 'dark':
        initialThemeMode = ThemeMode.dark;
        break;
      case 'light':
        initialThemeMode = ThemeMode.light;
        break;
      case 'system':
        initialThemeMode = ThemeMode.system;
        break;
    }
    initialShowTips = prefs.getBool('app_show_tips');
  } catch (_) {}

  final database = AppDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            initialLocale: initialLocale,
            initialThemeMode: initialThemeMode,
            initialShowTips: initialShowTips,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NotesProvider(database)),
      ],
      child: const FastVoiceNoteApp(),
    ),
  );
}

class FastVoiceNoteApp extends StatefulWidget {
  const FastVoiceNoteApp({super.key});

  @override
  State<FastVoiceNoteApp> createState() => _FastVoiceNoteAppState();
}

class _FastVoiceNoteAppState extends State<FastVoiceNoteApp> {
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle initial link when app is launched
    _handleInitialLink();

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Wait a bit to ensure the app is fully loaded
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'fastvoicenote') {
      if (uri.host == 'quick_voice_note') {
        // Trigger quick voice note
        QuickVoiceNoteIntent.trigger();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp.router(
      title: 'FastVoiceNote',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('pt'), // Portuguese
      ],
    );
  }
}
