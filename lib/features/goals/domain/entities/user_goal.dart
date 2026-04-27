class UserGoal {
  final int? id;
  final String userId;
  final int dailyTargetMl;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isSynced;
  final DateTime? syncedAt;

  const UserGoal({
    this.id,
    required this.userId,
    required this.dailyTargetMl,
    required this.startDate,
    this.endDate,
    this.isSynced = false,
    this.syncedAt,
  });

  UserGoal copyWith({
    int? id,
    String? userId,
    int? dailyTargetMl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSynced,
    DateTime? syncedAt,
  }) {
    return UserGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'dailyTargetMl': dailyTargetMl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}
