import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';
import 'package:water_reminder_app/services/database/sqlite_service.dart';

class WaterLogSqliteDatasource {
  // ── CREATE ──
  Future<int> insertWaterLog(WaterLog log) async {
    final db = await SqliteService.database;
    return await db.insert('water_logs', {
      'user_id': log.userId,
      'amount': log.amount,
      'drink_type': log.drinkType,
      'timestamp': log.timestamp.toIso8601String(),
      'date': log.date,
      'is_synced': log.isSynced ? 1 : 0,
      'synced_at': log.syncedAt?.toIso8601String(),
    });
  }

  // ── READ ──
  Future<List<WaterLog>> getLogsByDate(String userId, String date) async {
    final db = await SqliteService.database;
    final results = await db.query(
      'water_logs',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'timestamp DESC',
    );
    return results.map(_fromRow).toList();
  }

  Future<List<WaterLog>> getAllLogs(String userId) async {
    final db = await SqliteService.database;
    final results = await db.query(
      'water_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return results.map(_fromRow).toList();
  }

  Future<int> getTodayTotal(String userId, String todayDate) async {
    final db = await SqliteService.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM water_logs WHERE user_id = ? AND date = ?',
      [userId, todayDate],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getDailySummary(
      String userId, int days) async {
    final db = await SqliteService.database;
    return await db.rawQuery('''
      SELECT date, SUM(amount) as total, COUNT(*) as count
      FROM water_logs
      WHERE user_id = ?
      GROUP BY date
      ORDER BY date DESC
      LIMIT ?
    ''', [userId, days]);
  }

  // ── UPDATE ──
  Future<int> updateWaterLog(WaterLog log) async {
    final db = await SqliteService.database;
    return await db.update(
      'water_logs',
      {
        'amount': log.amount,
        'drink_type': log.drinkType,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  // ── DELETE ──
  Future<int> deleteWaterLog(int id) async {
    final db = await SqliteService.database;
    return await db.delete(
      'water_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── HELPERS ──
  WaterLog _fromRow(Map<String, dynamic> row) {
    return WaterLog(
      id: row['id'] as int,
      userId: row['user_id'] as String,
      amount: row['amount'] as int,
      drinkType: (row['drink_type'] ?? 'Water') as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      date: row['date'] as String,
      isSynced: row['is_synced'] == 1,
      syncedAt: row['synced_at'] != null
          ? DateTime.parse(row['synced_at'] as String)
          : null,
    );
  }
}
