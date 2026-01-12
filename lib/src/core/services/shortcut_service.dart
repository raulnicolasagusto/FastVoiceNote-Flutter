import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import '../utils/quick_voice_intent.dart';

class ShortcutService {
  static final ShortcutService _instance = ShortcutService._internal();
  factory ShortcutService() => _instance;
  ShortcutService._internal();

  final QuickActions _quickActions = const QuickActions();

  void initialize() {
    _quickActions.initialize((shortcutType) {
      if (shortcutType == 'quick_voice_note') {
        QuickVoiceNoteIntent.trigger();
      }
    });
  }

  void updateShortcuts(Locale locale) {
    String label;

    switch (locale.languageCode) {
      case 'es':
        label = 'Nota de Voz Rápida';
        break;
      case 'pt':
        label = 'Nota de Voz Rápida';
        break;
      case 'en':
      default:
        label = 'Quick Voice Note';
        break;
    }

    _quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: 'quick_voice_note',
        localizedTitle: label,
        icon: 'ic_launcher',
      ),
    ]);
  }
}
