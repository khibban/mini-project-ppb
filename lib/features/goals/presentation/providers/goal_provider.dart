import 'package:flutter/material.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';
import 'package:water_reminder_app/features/goals/domain/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository;

  GoalProvider(this._repository);

  UserGoal? _currentGoal;
  List<UserGoal> _goalHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserGoal? get currentGoal => _currentGoal;
  List<UserGoal> get goalHistory => _goalHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentTargetMl =>
      _currentGoal?.dailyTargetMl ?? AppConstants.defaultDailyGoalMl;

  Future<void> loadCurrentGoal(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentGoal = await _repository.getCurrentGoal(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load goal: $e';
      notifyListeners();
    }
  }

  Future<void> loadGoalHistory(String userId) async {
    try {
      _goalHistory = await _repository.getAllGoals(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load goal history: $e';
      notifyListeners();
    }
  }

  Future<bool> setGoal({
    required String userId,
    required int dailyTargetMl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final goal = UserGoal(
        userId: userId,
        dailyTargetMl: dailyTargetMl,
        startDate: DateTime.now(),
      );

      await _repository.addGoal(goal);
      await loadCurrentGoal(userId);
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to set goal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoal(UserGoal goal, String userId) async {
    try {
      await _repository.updateGoal(goal);
      await loadCurrentGoal(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update goal: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(int id, String userId) async {
    try {
      await _repository.deleteGoal(id);
      await loadCurrentGoal(userId);
      await loadGoalHistory(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete goal: $e';
      notifyListeners();
      return false;
    }
  }
}
