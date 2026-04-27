import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/features/sync/data/sync_service.dart';
import 'package:water_reminder_app/services/connectivity_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncProvider({
    required SyncService syncService,
    required ConnectivityService connectivityService,
  })  : _syncService = syncService,
        _connectivityService = connectivityService;

  bool _isSyncing = false;
  String? _lastSyncMessage;
  DateTime? _lastSyncTime;
  bool _isConnected = false;

  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isConnected => _isConnected;

  void initialize(String userId) {
    _isConnected = _connectivityService.isConnected;
    _loadLastSyncTime();

    _connectivitySubscription =
        _connectivityService.onConnectionChanged.listen((connected) {
      _isConnected = connected;
      notifyListeners();

      // Auto-sync when connection is restored
      if (connected && !_isSyncing) {
        syncNow(userId);
      }
    });
  }

  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(AppConstants.prefKeyLastSync);
    if (lastSync != null) {
      _lastSyncTime = DateTime.parse(lastSync);
      notifyListeners();
    }
  }

  Future<SyncResult> syncNow(String userId) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedLogs: 0,
        syncedGoals: 0,
      );
    }

    _isSyncing = true;
    _lastSyncMessage = 'Syncing...';
    notifyListeners();

    final result = await _syncService.syncAll(userId);

    _isSyncing = false;
    _lastSyncMessage = result.message;
    if (result.success) {
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.prefKeyLastSync,
        _lastSyncTime!.toIso8601String(),
      );
    }
    notifyListeners();

    return result;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
