import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';

abstract class WaterIntakeRepository {
  Future<int> addWaterLog(WaterLog log);
  Future<List<WaterLog>> getLogsByDate(String userId, String date);
  Future<List<WaterLog>> getAllLogs(String userId);
  Future<int> getTodayTotal(String userId, String todayDate);
  Future<void> updateWaterLog(WaterLog log);
  Future<void> deleteWaterLog(int id);
  Future<List<WaterLog>> getUnsyncedLogs(String userId);
  Future<void> markAsSynced(int id);
  Future<List<Map<String, dynamic>>> getDailySummary(String userId, int days);
}
