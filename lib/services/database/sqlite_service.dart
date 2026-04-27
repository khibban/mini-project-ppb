import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';

class SqliteService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.sqliteDbName);

    return await openDatabase(
      path,
      version: AppConstants.sqliteDbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Water logs table
    await db.execute('''
      CREATE TABLE water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        drink_type TEXT NOT NULL DEFAULT 'Water',
        timestamp TEXT NOT NULL,
        date TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // User goals table
    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        daily_target_ml INTEGER NOT NULL DEFAULT 2000,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Notification settings table
    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        interval_minutes INTEGER NOT NULL DEFAULT 120,
        start_hour INTEGER NOT NULL DEFAULT 8,
        end_hour INTEGER NOT NULL DEFAULT 22,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_water_logs_user_date ON water_logs(user_id, date)');
    await db.execute(
        'CREATE INDEX idx_water_logs_synced ON water_logs(is_synced)');
    await db.execute(
        'CREATE INDEX idx_user_goals_user ON user_goals(user_id)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle migrations here in the future
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
