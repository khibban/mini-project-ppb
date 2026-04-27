import 'package:flutter/material.dart';
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_local_datasource.dart';
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_remote_datasource.dart';
import 'package:water_reminder_app/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:water_reminder_app/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:water_reminder_app/services/connectivity_service.dart';

class SyncService {
  final WaterLogLocalDatasource _waterLocalDatasource;
  final WaterLogRemoteDatasource _waterRemoteDatasource;
  final GoalLocalDatasource _goalLocalDatasource;
  final GoalRemoteDatasource _goalRemoteDatasource;
  final ConnectivityService _connectivityService;

  SyncService({
    required WaterLogLocalDatasource waterLocalDatasource,
    required WaterLogRemoteDatasource waterRemoteDatasource,
    required GoalLocalDatasource goalLocalDatasource,
    required GoalRemoteDatasource goalRemoteDatasource,
    required ConnectivityService connectivityService,
  })  : _waterLocalDatasource = waterLocalDatasource,
        _waterRemoteDatasource = waterRemoteDatasource,
        _goalLocalDatasource = goalLocalDatasource,
        _goalRemoteDatasource = goalRemoteDatasource,
        _connectivityService = connectivityService;

  /// Sync all unsynced data to Firebase
  Future<SyncResult> syncAll(String userId) async {
    if (!_connectivityService.isConnected) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedLogs: 0,
        syncedGoals: 0,
      );
    }

    int syncedLogs = 0;
    int syncedGoals = 0;

    try {
      // Sync water logs
      final unsyncedLogs =
          await _waterLocalDatasource.getUnsyncedLogs(userId);
      if (unsyncedLogs.isNotEmpty) {
        await _waterRemoteDatasource.batchUploadLogs(unsyncedLogs);
        for (final log in unsyncedLogs) {
          await _waterLocalDatasource.markAsSynced(log.id!);
        }
        syncedLogs = unsyncedLogs.length;
      }

      // Sync goals
      final unsyncedGoals =
          await _goalLocalDatasource.getUnsyncedGoals(userId);
      if (unsyncedGoals.isNotEmpty) {
        await _goalRemoteDatasource.batchUploadGoals(unsyncedGoals);
        for (final goal in unsyncedGoals) {
          await _goalLocalDatasource.markAsSynced(goal.id!);
        }
        syncedGoals = unsyncedGoals.length;
      }

      return SyncResult(
        success: true,
        message: 'Sync complete!',
        syncedLogs: syncedLogs,
        syncedGoals: syncedGoals,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedLogs: syncedLogs,
        syncedGoals: syncedGoals,
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedLogs;
  final int syncedGoals;

  const SyncResult({
    required this.success,
    required this.message,
    required this.syncedLogs,
    required this.syncedGoals,
  });

  int get totalSynced => syncedLogs + syncedGoals;
}
