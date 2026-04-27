import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';

abstract class GoalRepository {
  Future<int> addGoal(UserGoal goal);
  Future<UserGoal?> getCurrentGoal(String userId);
  Future<List<UserGoal>> getAllGoals(String userId);
  Future<void> updateGoal(UserGoal goal);
  Future<void> deleteGoal(int id);
  Future<void> deactivateCurrentGoal(String userId);
  Future<List<UserGoal>> getUnsyncedGoals(String userId);
  Future<void> markAsSynced(int id);
}
