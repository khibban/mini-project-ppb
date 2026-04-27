import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_local_datasource.dart';
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_sqlite_datasource.dart';
import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';
import 'package:water_reminder_app/features/water_intake/domain/repositories/water_intake_repository.dart';

class WaterIntakeRepositoryImpl implements WaterIntakeRepository {
  final WaterLogLocalDatasource _localDatasource;
  final WaterLogSqliteDatasource _sqliteDatasource;

  WaterIntakeRepositoryImpl(this._localDatasource, this._sqliteDatasource);

  @override
  Future<int> addWaterLog(WaterLog log) async {
    // Write to both Isar (fast, primary) and SQLite (relational)
    final isarId = await _localDatasource.addWaterLog(log);
    await _sqliteDatasource.insertWaterLog(log.copyWith(id: isarId));
    return isarId;
  }

  @override
  Future<List<WaterLog>> getLogsByDate(String userId, String date) {
    // Read from Isar (faster)
    return _localDatasource.getLogsByDate(userId, date);
  }

  @override
  Future<List<WaterLog>> getAllLogs(String userId) {
    return _localDatasource.getAllLogs(userId);
  }

  @override
  Future<int> getTodayTotal(String userId, String todayDate) {
    return _localDatasource.getTodayTotal(userId, todayDate);
  }

  @override
  Future<void> updateWaterLog(WaterLog log) async {
    await _localDatasource.updateWaterLog(log);
    await _sqliteDatasource.updateWaterLog(log);
  }

  @override
  Future<void> deleteWaterLog(int id) async {
    await _localDatasource.deleteWaterLog(id);
    await _sqliteDatasource.deleteWaterLog(id);
  }

  @override
  Future<List<WaterLog>> getUnsyncedLogs(String userId) {
    return _localDatasource.getUnsyncedLogs(userId);
  }

  @override
  Future<void> markAsSynced(int id) {
    return _localDatasource.markAsSynced(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailySummary(String userId, int days) {
    // SQLite excels at aggregation queries
    return _sqliteDatasource.getDailySummary(userId, days);
  }
}
