class AppConstants {
  AppConstants._();

  // Default values
  static const int defaultDailyGoalMl = 2000;
  static const int defaultReminderIntervalMinutes = 120;
  static const int defaultStartHour = 8;
  static const int defaultEndHour = 22;

  // Quick add amounts (ml)
  static const List<int> quickAddAmounts = [100, 150, 200, 250, 330, 500];

  // Drink types
  static const List<String> drinkTypes = [
    'Water',
    'Tea',
    'Coffee',
    'Juice',
    'Milk',
    'Other',
  ];

  // Drink type icons (material icon code points)
  static const Map<String, int> drinkTypeIcons = {
    'Water': 0xe798, // water_drop
    'Tea': 0xf0f4, // emoji_food_beverage
    'Coffee': 0xe176, // coffee
    'Juice': 0xea60, // local_drink
    'Milk': 0xea60, // local_drink
    'Other': 0xea60, // local_drink
  };

  // Reminder intervals (minutes)
  static const List<int> reminderIntervals = [30, 60, 90, 120, 180, 240];

  // Goal range
  static const int minGoalMl = 500;
  static const int maxGoalMl = 5000;
  static const int goalStepMl = 100;

  // Max intake per log
  static const int maxIntakePerLogMl = 2000;
  static const int minIntakePerLogMl = 10;

  // Notification channel
  static const String notificationChannelId = 'water_reminder_channel';
  static const String notificationChannelName = 'Water Reminders';
  static const String notificationChannelDesc =
      'Scheduled reminders to drink water';

  // SQLite
  static const String sqliteDbName = 'water_reminder.db';
  static const int sqliteDbVersion = 1;

  // SharedPreferences keys
  static const String prefKeyDarkMode = 'dark_mode';
  static const String prefKeyOnboarded = 'onboarded';
  static const String prefKeyLastSync = 'last_sync';
}
