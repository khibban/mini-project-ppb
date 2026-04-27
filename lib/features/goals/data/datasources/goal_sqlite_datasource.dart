import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';
import 'package:water_reminder_app/services/database/sqlite_service.dart';

class GoalSqliteDatasource {
  // ── CREATE ──
  Future<int> insertGoal(UserGoal goal) async {
    final db = await SqliteService.database;
    return await db.insert('user_goals', {
      'user_id': goal.userId,
      'daily_target_ml': goal.dailyTargetMl,
      'start_date': goal.startDate.toIso8601String(),
      'end_date': goal.endDate?.toIso8601String(),
      'is_synced': goal.isSynced ? 1 : 0,
      'synced_at': goal.syncedAt?.toIso8601String(),
    });
  }

  // ── READ ──
  Future<UserGoal?> getCurrentGoal(String userId) async {
    final db = await SqliteService.database;
    final results = await db.query(
      'user_goals',
      where: 'user_id = ? AND end_date IS NULL',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _fromRow(results.first);
  }

  Future<List<UserGoal>> getAllGoals(String userId) async {
    final db = await SqliteService.database;
    final results = await db.query(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return results.map(_fromRow).toList();
  }

  // ── UPDATE ──
  Future<int> updateGoal(UserGoal goal) async {
    final db = await SqliteService.database;
    return await db.update(
      'user_goals',
      {
        'daily_target_ml': goal.dailyTargetMl,
        'end_date': goal.endDate?.toIso8601String(),
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deactivateCurrentGoal(String userId) async {
    final db = await SqliteService.database;
    await db.update(
      'user_goals',
      {
        'end_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ? AND end_date IS NULL',
      whereArgs: [userId],
    );
  }

  // ── DELETE ──
  Future<int> deleteGoal(int id) async {
    final db = await SqliteService.database;
    return await db.delete('user_goals', where: 'id = ?', whereArgs: [id]);
  }

  UserGoal _fromRow(Map<String, dynamic> row) {
    return UserGoal(
      id: row['id'] as int,
      userId: row['user_id'] as String,
      dailyTargetMl: row['daily_target_ml'] as int,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: row['end_date'] != null
          ? DateTime.parse(row['end_date'] as String)
          : null,
      isSynced: row['is_synced'] == 1,
      syncedAt: row['synced_at'] != null
          ? DateTime.parse(row['synced_at'] as String)
          : null,
    );
  }
}
