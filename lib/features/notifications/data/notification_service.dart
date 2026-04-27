import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:water_reminder_app/core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleWaterReminders({
    int intervalMinutes = AppConstants.defaultReminderIntervalMinutes,
    int startHour = AppConstants.defaultStartHour,
    int endHour = AppConstants.defaultEndHour,
  }) async {
    // Cancel all existing reminders first
    await cancelAllReminders();

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 100;

    // Schedule reminders for the active hours
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        if (hour == startHour && minute == 0) continue; // Skip exact start

        var scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If the time has passed today, schedule for tomorrow
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        // Only schedule within active hours
        if (scheduledTime.hour >= endHour) continue;

        await _plugin.zonedSchedule(
          notificationId++,
          '💧 Time to drink water!',
          _getRandomMessage(),
          scheduledTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              AppConstants.notificationChannelId,
              AppConstants.notificationChannelName,
              channelDescription: AppConstants.notificationChannelDesc,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              styleInformation: const BigTextStyleInformation(''),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      // Move to next interval block
      if (intervalMinutes >= 60) break;
    }

    // Also schedule repeating by generating for each interval slot
    int id = 200;
    var nextTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, startHour, 0);
    if (nextTime.isBefore(now)) {
      // Find next valid reminder time from now
      while (nextTime.isBefore(now)) {
        nextTime = nextTime.add(Duration(minutes: intervalMinutes));
      }
    }

    while (nextTime.hour < endHour) {
      await _plugin.zonedSchedule(
        id++,
        '💧 Stay Hydrated!',
        _getRandomMessage(),
        nextTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      nextTime = nextTime.add(Duration(minutes: intervalMinutes));
      if (id > 250) break; // Safety cap
    }
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  String _getRandomMessage() {
    final messages = [
      'Your body needs water to stay healthy! 🚰',
      'A glass of water can boost your energy! ⚡',
      'Stay hydrated for better focus and productivity! 🧠',
      'Don\'t forget to drink water! Your body will thank you 💙',
      'Hydration is key! Take a sip now 🥤',
      'Water break time! Keep up the great work 💪',
      'Feeling thirsty? Your reminder to drink water! 💧',
      'Keep sipping! You\'re doing great today! 🌊',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
}
