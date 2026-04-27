class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Water Reminder';
  static const String appTagline = 'Stay hydrated, stay healthy';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String hasAccount = 'Already have an account? ';
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';

  // Home
  static const String todayIntake = "Today's Intake";
  static const String dailyGoal = 'Daily Goal';
  static const String addWater = 'Add Water';
  static const String quickAdd = 'Quick Add';
  static const String recentLogs = 'Recent Logs';
  static const String noLogs = 'No water logs yet. Start drinking!';

  // Water
  static const String water = 'Water';
  static const String tea = 'Tea';
  static const String coffee = 'Coffee';
  static const String juice = 'Juice';
  static const String milk = 'Milk';
  static const String other = 'Other';

  // Goals
  static const String setGoal = 'Set Goal';
  static const String editGoal = 'Edit Goal';
  static const String goalTarget = 'Daily Target (ml)';
  static const String goalSaved = 'Goal saved successfully!';

  // Notifications
  static const String notifications = 'Notifications';
  static const String reminderEnabled = 'Reminders Enabled';
  static const String reminderInterval = 'Reminder Interval';
  static const String activeHours = 'Active Hours';
  static const String startTime = 'Start Time';
  static const String endTime = 'End Time';

  // History
  static const String history = 'History';
  static const String editLog = 'Edit Log';
  static const String deleteLog = 'Delete Log';
  static const String confirmDelete = 'Are you sure you want to delete this log?';

  // Profile
  static const String profile = 'Profile';
  static const String syncData = 'Sync Data';
  static const String syncSuccess = 'Data synced successfully!';
  static const String lastSynced = 'Last synced';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email.';
  static const String errorShortPassword = 'Password must be at least 6 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorEmptyField = 'This field is required.';
}
