import 'package:isar/isar.dart';

part 'water_log_isar_model.g.dart';

@collection
class WaterLogIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late int amount;
  late DateTime timestamp;

  @Index()
  late String date; // YYYY-MM-DD format for daily queries

  late String drinkType;
  late bool isSynced;
  DateTime? syncedAt;
}
