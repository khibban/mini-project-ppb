class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = int.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    if (amount > 2000) {
      return 'Maximum 2000ml per entry';
    }
    return null;
  }

  static String? validateGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Goal is required';
    }
    final goal = int.tryParse(value.trim());
    if (goal == null || goal < 500) {
      return 'Minimum goal is 500ml';
    }
    if (goal > 5000) {
      return 'Maximum goal is 5000ml';
    }
    return null;
  }
}
