import 'package:flutter/material.dart';
import 'package:water_reminder_app/core/utils/date_utils.dart';
import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';
import 'package:water_reminder_app/features/water_intake/domain/repositories/water_intake_repository.dart';

class WaterIntakeProvider extends ChangeNotifier {
  final WaterIntakeRepository _repository;

  WaterIntakeProvider(this._repository);

  List<WaterLog> _todayLogs = [];
  List<WaterLog> _allLogs = [];
  int _todayTotal = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<WaterLog> get todayLogs => _todayLogs;
  List<WaterLog> get allLogs => _allLogs;
  int get todayTotal => _todayTotal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double getProgress(int goalMl) {
    if (goalMl <= 0) return 0;
    return (_todayTotal / goalMl).clamp(0.0, 1.5);
  }

  int getRemaining(int goalMl) {
    final remaining = goalMl - _todayTotal;
    return remaining > 0 ? remaining : 0;
  }

  // ── LOAD DATA ──
  Future<void> loadTodayData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final todayDate = AppDateUtils.toDateString(DateTime.now());
      _todayLogs = await _repository.getLogsByDate(userId, todayDate);
      _todayTotal = await _repository.getTodayTotal(userId, todayDate);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }

  Future<void> loadAllLogs(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _allLogs = await _repository.getAllLogs(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load history: $e';
      notifyListeners();
    }
  }

  // ── ADD ──
  Future<bool> addWaterLog({
    required String userId,
    required int amount,
    String drinkType = 'Water',
  }) async {
    try {
      final now = DateTime.now();
      final log = WaterLog(
        userId: userId,
        amount: amount,
        drinkType: drinkType,
        timestamp: now,
        date: AppDateUtils.toDateString(now),
      );

      await _repository.addWaterLog(log);
      await loadTodayData(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add water log: $e';
      notifyListeners();
      return false;
    }
  }

  // ── UPDATE ──
  Future<bool> updateWaterLog(WaterLog log, String userId) async {
    try {
      await _repository.updateWaterLog(log);
      await loadTodayData(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update log: $e';
      notifyListeners();
      return false;
    }
  }

  // ── DELETE ──
  Future<bool> deleteWaterLog(int id, String userId) async {
    try {
      await _repository.deleteWaterLog(id);
      await loadTodayData(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete log: $e';
      notifyListeners();
      return false;
    }
  }

  // ── DAILY SUMMARY ──
  Future<List<Map<String, dynamic>>> getDailySummary(
      String userId, int days) async {
    return await _repository.getDailySummary(userId, days);
  }
}
