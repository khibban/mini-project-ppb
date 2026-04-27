import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Services
import 'package:water_reminder_app/services/connectivity_service.dart';

// Auth
import 'package:water_reminder_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:water_reminder_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';

// Water Intake
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_local_datasource.dart';
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_sqlite_datasource.dart';
import 'package:water_reminder_app/features/water_intake/data/datasources/water_log_remote_datasource.dart';
import 'package:water_reminder_app/features/water_intake/data/repositories/water_intake_repository_impl.dart';
import 'package:water_reminder_app/features/water_intake/presentation/providers/water_intake_provider.dart';

// Goals
import 'package:water_reminder_app/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:water_reminder_app/features/goals/data/datasources/goal_sqlite_datasource.dart';
import 'package:water_reminder_app/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:water_reminder_app/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:water_reminder_app/features/goals/presentation/providers/goal_provider.dart';

// Notifications
import 'package:water_reminder_app/features/notifications/data/notification_service.dart';
import 'package:water_reminder_app/features/notifications/presentation/providers/notification_provider.dart';

// Sync
import 'package:water_reminder_app/features/sync/data/sync_service.dart';
import 'package:water_reminder_app/features/sync/presentation/providers/sync_provider.dart';

// App
import 'package:water_reminder_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  // Initialize datasources
  final authDatasource = FirebaseAuthDatasource();
  final waterLocalDatasource = WaterLogLocalDatasource();
  final waterSqliteDatasource = WaterLogSqliteDatasource();
  final waterRemoteDatasource = WaterLogRemoteDatasource();
  final goalLocalDatasource = GoalLocalDatasource();
  final goalSqliteDatasource = GoalSqliteDatasource();
  final goalRemoteDatasource = GoalRemoteDatasource();

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(authDatasource);
  final waterIntakeRepository =
      WaterIntakeRepositoryImpl(waterLocalDatasource, waterSqliteDatasource);
  final goalRepository =
      GoalRepositoryImpl(goalLocalDatasource, goalSqliteDatasource);

  // Initialize sync service
  final syncService = SyncService(
    waterLocalDatasource: waterLocalDatasource,
    waterRemoteDatasource: waterRemoteDatasource,
    goalLocalDatasource: goalLocalDatasource,
    goalRemoteDatasource: goalRemoteDatasource,
    connectivityService: connectivityService,
  );

  // Initialize notification service
  final notificationService = NotificationService();

  runApp(
    MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),

        // Water Intake
        ChangeNotifierProvider(
          create: (_) => WaterIntakeProvider(waterIntakeRepository),
        ),

        // Goals
        ChangeNotifierProvider(
          create: (_) => GoalProvider(goalRepository),
        ),

        // Notifications
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService)..initialize(),
        ),

        // Sync
        ChangeNotifierProvider(
          create: (_) => SyncProvider(
            syncService: syncService,
            connectivityService: connectivityService,
          ),
        ),
      ],
      child: const WaterReminderApp(),
    ),
  );
}
