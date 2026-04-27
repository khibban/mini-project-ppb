import 'package:isar/isar.dart';

part 'goal_isar_model.g.dart';

@collection
class GoalIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late int dailyTargetMl;
  late DateTime startDate;
  DateTime? endDate;
  late bool isSynced;
  DateTime? syncedAt;
}
