import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _showTips = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get showTips => _showTips;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (!['en', 'es', 'pt'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleTips(bool value) {
    _showTips = value;
    notifyListeners();
  }
}
