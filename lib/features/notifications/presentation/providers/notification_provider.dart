import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/features/notifications/data/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  bool _isEnabled = true;
  int _intervalMinutes = AppConstants.defaultReminderIntervalMinutes;
  int _startHour = AppConstants.defaultStartHour;
  int _endHour = AppConstants.defaultEndHour;
  final bool _isLoading = false;

  bool get isEnabled => _isEnabled;
  int get intervalMinutes => _intervalMinutes;
  int get startHour => _startHour;
  int get endHour => _endHour;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    await _loadSettings();
    if (_isEnabled) {
      await _scheduleReminders();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('notification_enabled') ?? true;
    _intervalMinutes = prefs.getInt('notification_interval') ??
        AppConstants.defaultReminderIntervalMinutes;
    _startHour =
        prefs.getInt('notification_start_hour') ?? AppConstants.defaultStartHour;
    _endHour =
        prefs.getInt('notification_end_hour') ?? AppConstants.defaultEndHour;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _isEnabled);
    await prefs.setInt('notification_interval', _intervalMinutes);
    await prefs.setInt('notification_start_hour', _startHour);
    await prefs.setInt('notification_end_hour', _endHour);
  }

  Future<void> _scheduleReminders() async {
    await _notificationService.scheduleWaterReminders(
      intervalMinutes: _intervalMinutes,
      startHour: _startHour,
      endHour: _endHour,
    );
  }

  Future<void> toggleEnabled(bool value) async {
    _isEnabled = value;
    notifyListeners();

    if (_isEnabled) {
      await _notificationService.requestPermissions();
      await _scheduleReminders();
    } else {
      await _notificationService.cancelAllReminders();
    }
    await _saveSettings();
  }

  Future<void> setInterval(int minutes) async {
    _intervalMinutes = minutes;
    notifyListeners();

    if (_isEnabled) {
      await _scheduleReminders();
    }
    await _saveSettings();
  }

  Future<void> setStartHour(int hour) async {
    _startHour = hour;
    notifyListeners();

    if (_isEnabled) {
      await _scheduleReminders();
    }
    await _saveSettings();
  }

  Future<void> setEndHour(int hour) async {
    _endHour = hour;
    notifyListeners();

    if (_isEnabled) {
      await _scheduleReminders();
    }
    await _saveSettings();
  }

  Future<void> sendTestNotification() async {
    await _notificationService.showInstantNotification(
      title: '💧 Test Notification',
      body: 'Water reminders are working! Great job staying hydrated!',
    );
  }
}
