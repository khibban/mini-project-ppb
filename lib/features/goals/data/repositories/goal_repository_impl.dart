import 'package:water_reminder_app/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:water_reminder_app/features/goals/data/datasources/goal_sqlite_datasource.dart';
import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';
import 'package:water_reminder_app/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDatasource _localDatasource;
  final GoalSqliteDatasource _sqliteDatasource;

  GoalRepositoryImpl(this._localDatasource, this._sqliteDatasource);

  @override
  Future<int> addGoal(UserGoal goal) async {
    // Deactivate any existing active goal first
    await _localDatasource.deactivateCurrentGoal(goal.userId);
    await _sqliteDatasource.deactivateCurrentGoal(goal.userId);

    final isarId = await _localDatasource.addGoal(goal);
    await _sqliteDatasource.insertGoal(goal.copyWith(id: isarId));
    return isarId;
  }

  @override
  Future<UserGoal?> getCurrentGoal(String userId) {
    return _localDatasource.getCurrentGoal(userId);
  }

  @override
  Future<List<UserGoal>> getAllGoals(String userId) {
    return _localDatasource.getAllGoals(userId);
  }

  @override
  Future<void> updateGoal(UserGoal goal) async {
    await _localDatasource.updateGoal(goal);
    await _sqliteDatasource.updateGoal(goal);
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _localDatasource.deleteGoal(id);
    await _sqliteDatasource.deleteGoal(id);
  }

  @override
  Future<void> deactivateCurrentGoal(String userId) async {
    await _localDatasource.deactivateCurrentGoal(userId);
    await _sqliteDatasource.deactivateCurrentGoal(userId);
  }

  @override
  Future<List<UserGoal>> getUnsyncedGoals(String userId) {
    return _localDatasource.getUnsyncedGoals(userId);
  }

  @override
  Future<void> markAsSynced(int id) {
    return _localDatasource.markAsSynced(id);
  }
}
