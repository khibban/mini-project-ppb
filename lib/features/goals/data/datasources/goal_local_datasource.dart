import 'package:isar/isar.dart';
import 'package:water_reminder_app/features/goals/data/models/goal_isar_model.dart';
import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';
import 'package:water_reminder_app/services/database/isar_service.dart';

class GoalLocalDatasource {
  Future<Isar> get _isar => IsarService.instance;

  Future<int> addGoal(UserGoal goal) async {
    final isar = await _isar;
    final isarGoal = GoalIsar()
      ..userId = goal.userId
      ..dailyTargetMl = goal.dailyTargetMl
      ..startDate = goal.startDate
      ..endDate = goal.endDate
      ..isSynced = false;

    return await isar.writeTxn(() => isar.goalIsars.put(isarGoal));
  }

  Future<UserGoal?> getCurrentGoal(String userId) async {
    final isar = await _isar;
    final goal = await isar.goalIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .endDateIsNull()
        .sortByStartDateDesc()
        .findFirst();

    if (goal == null) return null;
    return _toEntity(goal);
  }

  Future<List<UserGoal>> getAllGoals(String userId) async {
    final isar = await _isar;
    final goals = await isar.goalIsars
        .filter()
        .userIdEqualTo(userId)
        .sortByStartDateDesc()
        .findAll();

    return goals.map(_toEntity).toList();
  }

  Future<void> updateGoal(UserGoal goal) async {
    final isar = await _isar;
    final existing = await isar.goalIsars.get(goal.id!);
    if (existing == null) return;

    existing
      ..dailyTargetMl = goal.dailyTargetMl
      ..endDate = goal.endDate
      ..isSynced = false;

    await isar.writeTxn(() => isar.goalIsars.put(existing));
  }

  Future<void> deactivateCurrentGoal(String userId) async {
    final isar = await _isar;
    final current = await isar.goalIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .endDateIsNull()
        .findFirst();

    if (current != null) {
      current.endDate = DateTime.now();
      await isar.writeTxn(() => isar.goalIsars.put(current));
    }
  }

  Future<bool> deleteGoal(int id) async {
    final isar = await _isar;
    return await isar.writeTxn(() => isar.goalIsars.delete(id));
  }

  Future<void> markAsSynced(int id) async {
    final isar = await _isar;
    final goal = await isar.goalIsars.get(id);
    if (goal == null) return;
    goal
      ..isSynced = true
      ..syncedAt = DateTime.now();
    await isar.writeTxn(() => isar.goalIsars.put(goal));
  }

  Future<List<UserGoal>> getUnsyncedGoals(String userId) async {
    final isar = await _isar;
    final goals = await isar.goalIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .isSyncedEqualTo(false)
        .findAll();
    return goals.map(_toEntity).toList();
  }

  UserGoal _toEntity(GoalIsar model) {
    return UserGoal(
      id: model.id,
      userId: model.userId,
      dailyTargetMl: model.dailyTargetMl,
      startDate: model.startDate,
      endDate: model.endDate,
      isSynced: model.isSynced,
      syncedAt: model.syncedAt,
    );
  }
}
