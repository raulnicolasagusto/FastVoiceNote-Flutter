import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _showTips = true;

  static const _prefLocaleKey = 'app_locale_code';

  SettingsProvider({Locale? initialLocale}) {
    if (initialLocale != null) {
      _locale = initialLocale;
    } else {
      _loadLocaleFromPrefs();
    }
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get showTips => _showTips;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
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

  void toggleTips(bool value) {
    _showTips = value;
    notifyListeners();
  }

  Future<void> _loadLocaleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefLocaleKey);
      if (code != null && ['en', 'es', 'pt'].contains(code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }
}
