import 'package:isar/isar.dart';
import 'package:water_reminder_app/features/water_intake/data/models/water_log_isar_model.dart';
import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';
import 'package:water_reminder_app/services/database/isar_service.dart';

class WaterLogLocalDatasource {
  Future<Isar> get _isar => IsarService.instance;

  // ── CREATE ──
  Future<int> addWaterLog(WaterLog log) async {
    final isar = await _isar;
    final isarLog = WaterLogIsar()
      ..userId = log.userId
      ..amount = log.amount
      ..drinkType = log.drinkType
      ..timestamp = log.timestamp
      ..date = log.date
      ..isSynced = false;

    return await isar.writeTxn(() => isar.waterLogIsars.put(isarLog));
  }

  // ── READ ──
  Future<List<WaterLog>> getLogsByDate(String userId, String date) async {
    final isar = await _isar;
    final logs = await isar.waterLogIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .dateEqualTo(date)
        .sortByTimestampDesc()
        .findAll();

    return logs.map(_toEntity).toList();
  }

  Future<List<WaterLog>> getAllLogs(String userId) async {
    final isar = await _isar;
    final logs = await isar.waterLogIsars
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc()
        .findAll();

    return logs.map(_toEntity).toList();
  }

  Future<int> getTodayTotal(String userId, String todayDate) async {
    final isar = await _isar;
    final logs = await isar.waterLogIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .dateEqualTo(todayDate)
        .findAll();

    return logs.fold<int>(0, (sum, log) => sum + log.amount);
  }

  Future<List<WaterLog>> getUnsyncedLogs(String userId) async {
    final isar = await _isar;
    final logs = await isar.waterLogIsars
        .filter()
        .userIdEqualTo(userId)
        .and()
        .isSyncedEqualTo(false)
        .findAll();

    return logs.map(_toEntity).toList();
  }

  // ── UPDATE ──
  Future<void> updateWaterLog(WaterLog log) async {
    final isar = await _isar;
    final existing = await isar.waterLogIsars.get(log.id!);
    if (existing == null) return;

    existing
      ..amount = log.amount
      ..drinkType = log.drinkType
      ..isSynced = false;

    await isar.writeTxn(() => isar.waterLogIsars.put(existing));
  }

  Future<void> markAsSynced(int id) async {
    final isar = await _isar;
    final log = await isar.waterLogIsars.get(id);
    if (log == null) return;

    log
      ..isSynced = true
      ..syncedAt = DateTime.now();

    await isar.writeTxn(() => isar.waterLogIsars.put(log));
  }

  // ── DELETE ──
  Future<bool> deleteWaterLog(int id) async {
    final isar = await _isar;
    return await isar.writeTxn(() => isar.waterLogIsars.delete(id));
  }

  // ── HELPERS ──
  WaterLog _toEntity(WaterLogIsar model) {
    return WaterLog(
      id: model.id,
      userId: model.userId,
      amount: model.amount,
      drinkType: model.drinkType,
      timestamp: model.timestamp,
      date: model.date,
      isSynced: model.isSynced,
      syncedAt: model.syncedAt,
    );
  }
}
