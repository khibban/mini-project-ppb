import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_reminder_app/features/water_intake/data/models/water_log_isar_model.dart';
import 'package:water_reminder_app/features/goals/data/models/goal_isar_model.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    _instance = await _openDb();
    return _instance!;
  }

  static Future<Isar> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [WaterLogIsarSchema, GoalIsarSchema],
      directory: dir.path,
    );
  }

  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }
}
