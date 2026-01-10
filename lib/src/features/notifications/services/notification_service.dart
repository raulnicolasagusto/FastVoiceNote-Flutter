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

    debugPrint('🔔 Initializing notification service...');

    // Initialize timezone database first
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

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

    final initialized = await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    debugPrint('🔔 Flutter local notifications initialized: $initialized');

    // Request notification permission on Android 13+
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      debugPrint('🔔 Notification permission status: $notificationStatus');
      
      if (!notificationStatus.isGranted) {
        debugPrint('⚠️ Notification permission NOT granted');
      }

      // Request exact alarm permission for Android 12+
      final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('🔔 Schedule exact alarm status: $scheduleExactAlarmStatus');
      
      if (!scheduleExactAlarmStatus.isGranted) {
        debugPrint('⚠️ Exact alarm permission not granted - will try to request');
        // Try to request (on some Android versions this opens settings automatically)
        try {
          await Permission.scheduleExactAlarm.request();
        } catch (e) {
          debugPrint('⚠️ Could not request exact alarm permission: $e');
        }
      }
    }

    _initialized = true;
    debugPrint('✅ Notification service fully initialized');
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

    // Check permissions before scheduling
    if (Platform.isAndroid) {
      final notificationPermission = await Permission.notification.status;
      if (!notificationPermission.isGranted) {
        debugPrint('⚠️ Cannot schedule reminder: notification permission not granted');
        throw Exception('Notification permission not granted');
      }
    }

    final id = _generateNotificationId(noteId);
    
    // Convert to TZDateTime for the local timezone
    final nowLocal = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    debugPrint('🔔 Current time: $nowLocal');
    debugPrint('🔔 Requested time: ${scheduledTime.toLocal()}');
    debugPrint('🔔 Scheduled TZ time: $scheduledDate');
    
    // Prevent scheduling in the past
    if (!scheduledDate.isAfter(nowLocal)) {
      scheduledDate = nowLocal.add(const Duration(minutes: 1));
      debugPrint('⚠️ Scheduled time was in the past, adjusted to 1 minute from now: $scheduledDate');
    }

    // Determine which schedule mode to use based on permissions
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    
    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isGranted) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
        debugPrint('✅ Using EXACT alarm mode');
      } else {
        debugPrint('⚠️ Using INEXACT alarm mode (exact alarm permission not granted)');
      }
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'note_reminders',
        'Note Reminders',
        channelDescription: 'Reminders for notes',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    debugPrint('🔔 ========== SCHEDULING REMINDER ==========');
    debugPrint('🔔 ID: $id');
    debugPrint('🔔 Scheduled for: ${scheduledDate.toString()}');
    debugPrint('🔔 Title: ${_getNotificationTitle(locale)}');
    debugPrint('🔔 Body: ${_getNotificationBody(locale, title)}');
    debugPrint('🔔 Schedule Mode: $scheduleMode');
    
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        _getNotificationTitle(locale),
        _getNotificationBody(locale, title),
        scheduledDate,
        notificationDetails,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: noteId,
      );
      
      debugPrint('✅ Reminder scheduled successfully!');
      debugPrint('🔔 =========================================');
      
      // Verify the notification was scheduled
      final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pendingNotifications.length}');
      final thisNotification = pendingNotifications.where((n) => n.id == id);
      if (thisNotification.isNotEmpty) {
        debugPrint('✅ Confirmed: Notification $id is in pending queue');
      } else {
        debugPrint('❌ WARNING: Notification $id NOT found in pending queue!');
      }
      
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
      debugPrint('🔔 =========================================');
      rethrow;
    }
  }

  Future<void> cancelReminder(String noteId) async {
    final id = _generateNotificationId(noteId);
    await _notificationsPlugin.cancel(id);
    debugPrint('🔕 Reminder cancelled for note: $noteId');
  }

  // Request Android 13+ notification permission; opens settings if permanently denied
  Future<bool> requestNotificationPermissionOrOpenSettings() async {
    if (!Platform.isAndroid) return true;
    
    final current = await Permission.notification.status;
    debugPrint('🔔 Current notification permission: $current');
    
    if (current.isGranted) return true;
    
    final result = await Permission.notification.request();
    debugPrint('🔔 Permission request result: $result');
    
    if (result.isGranted) return true;
    
    if (result.isPermanentlyDenied) {
      debugPrint('⚠️ Permission permanently denied, opening settings...');
      await openAppSettings();
    }
    
    return false;
  }

  // Show a quick test notification immediately to validate channel/permissions
  Future<void> showTestNotification({
    String locale = 'es',
    String? customTitle,
    String? customBody,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'note_reminders',
        'Note Reminders',
        channelDescription: 'Reminders for notes',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        customTitle ?? _getNotificationTitle(locale),
        customBody ?? _getNotificationBody(locale, 'Prueba'),
        details,
        payload: 'test',
      );
      debugPrint('✅ Test notification shown');
    } catch (e) {
      debugPrint('❌ Error showing test notification: $e');
      rethrow;
    }
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
