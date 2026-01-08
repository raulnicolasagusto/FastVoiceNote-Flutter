import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Service to manage home screen widgets for notes
class HomeWidgetService {
  static const String _widgetName = 'NoteWidgetReceiver';
  static const String _androidName = 'NoteWidgetReceiver';
  static const String _qualifiedAndroidName = 
      'com.fastvoicenote.fast_voice_note.NoteWidgetReceiver';

  /// Pin a note widget to the home screen
  /// Returns true if the request was successful
  Future<bool> pinNoteToHomeScreen({
    required String title,
    required String content,
    required String colorHex,
  }) async {
    try {
      // Check if pinning is supported
      final isSupported = await HomeWidget.isRequestPinWidgetSupported();
      if (isSupported != true) {
        debugPrint('Pin widget not supported on this device');
        return false;
      }

      // Save widget data
      await HomeWidget.saveWidgetData<String>('widget_title', title);
      await HomeWidget.saveWidgetData<String>('widget_content', content);
      await HomeWidget.saveWidgetData<String>('widget_color', colorHex);

      // Update widget
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _androidName,
        qualifiedAndroidName: _qualifiedAndroidName,
      );

      // Request to pin widget
      await HomeWidget.requestPinWidget(
        name: _widgetName,
        androidName: _androidName,
        qualifiedAndroidName: _qualifiedAndroidName,
      );

      return true;
    } catch (e) {
      debugPrint('Error pinning widget to home screen: $e');
      return false;
    }
  }

  /// Update an existing widget with new data
  Future<void> updateWidget({
    required String title,
    required String content,
    required String colorHex,
  }) async {
    try {
      // Save new data
      await HomeWidget.saveWidgetData<String>('widget_title', title);
      await HomeWidget.saveWidgetData<String>('widget_content', content);
      await HomeWidget.saveWidgetData<String>('widget_color', colorHex);

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _androidName,
        qualifiedAndroidName: _qualifiedAndroidName,
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
      rethrow;
    }
  }

  /// Check if pin widget is supported on this device
  Future<bool> isPinWidgetSupported() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      debugPrint('Error checking pin widget support: $e');
      return false;
    }
  }
}
