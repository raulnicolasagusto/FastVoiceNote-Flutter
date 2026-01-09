import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _showTips = true;

  static const _prefLocaleKey = 'app_locale_code';
  static const _prefThemeModeKey = 'app_theme_mode'; // 'dark' | 'light' | 'system'
  static const _prefShowTipsKey = 'app_show_tips'; // bool

  SettingsProvider({Locale? initialLocale, ThemeMode? initialThemeMode, bool? initialShowTips}) {
    if (initialLocale != null) {
      _locale = initialLocale;
    }
    if (initialThemeMode != null) {
      _themeMode = initialThemeMode;
    }
    if (initialShowTips != null) {
      _showTips = initialShowTips;
    }
    // Load any missing values from prefs
    _loadSettingsFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get showTips => _showTips;

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefThemeModeKey, isDark ? 'dark' : 'light');
    } catch (_) {}
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    if (!['en', 'es', 'pt'].contains(locale.languageCode)) return;
    _locale = locale;
    // Persist selection
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLocaleKey, _locale.languageCode);
    } catch (_) {}
    notifyListeners();
  }

  void toggleTips(bool value) async {
    _showTips = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefShowTipsKey, _showTips);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _loadSettingsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Locale
      final code = prefs.getString(_prefLocaleKey);
      if (code != null && ['en', 'es', 'pt'].contains(code)) {
        _locale = Locale(code);
      }
      // Theme
      final themeStr = prefs.getString(_prefThemeModeKey);
      if (themeStr != null) {
        switch (themeStr) {
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
        }
      }
      // Tips
      final tips = prefs.getBool(_prefShowTipsKey);
      if (tips != null) {
        _showTips = tips;
      }
      notifyListeners();
    } catch (_) {}
  }
}
