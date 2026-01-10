import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ requires runtime notification permission
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    // Initialize timezone database; tz.local will be used
    tz_data.initializeTimeZones();
    
    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleReminder({
    required String noteId,
    required String title,
    required DateTime scheduledTime,
    required String locale,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final id = _generateNotificationId(noteId);
    // Prevent scheduling in the past
    final nowLocal = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(scheduledTime.toLocal(), tz.local);
    if (!scheduledDate.isAfter(nowLocal)) {
      scheduledDate = nowLocal.add(const Duration(minutes: 1));
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'note_reminders',
        'Note Reminders',
        channelDescription: 'Reminders for notes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      _getNotificationTitle(locale),
      _getNotificationBody(locale, title),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: noteId,
    );
  }

  Future<void> cancelReminder(String noteId) async {
    final id = _generateNotificationId(noteId);
    await _notificationsPlugin.cancel(id);
  }

  // Request Android 13+ notification permission; opens settings if permanently denied
  Future<bool> requestNotificationPermissionOrOpenSettings() async {
    if (!Platform.isAndroid) return true;
    final current = await Permission.notification.status;
    if (current.isGranted) return true;
    final result = await Permission.notification.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  int _generateNotificationId(String noteId) {
    return noteId.hashCode.abs();
  }

  String _getNotificationTitle(String locale) {
    switch (locale) {
      case 'es':
        return 'Recordatorio de Nota';
      case 'pt':
        return 'Lembrete de Nota';
      default:
        return 'Note Reminder';
    }
  }

  String _getNotificationBody(String locale, String title) {
    switch (locale) {
      case 'es':
        return 'Recordatorio para la nota: $title';
      case 'pt':
        return 'Lembrete para a nota: $title';
      default:
        return 'Reminder for note: $title';
    }
  }
}
