class WaterLog {
  final int? id;
  final String userId;
  final int amount;
  final String drinkType;
  final DateTime timestamp;
  final String date;
  final bool isSynced;
  final DateTime? syncedAt;

  const WaterLog({
    this.id,
    required this.userId,
    required this.amount,
    this.drinkType = 'Water',
    required this.timestamp,
    required this.date,
    this.isSynced = false,
    this.syncedAt,
  });

  WaterLog copyWith({
    int? id,
    String? userId,
    int? amount,
    String? drinkType,
    DateTime? timestamp,
    String? date,
    bool? isSynced,
    DateTime? syncedAt,
  }) {
    return WaterLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      drinkType: drinkType ?? this.drinkType,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'amount': amount,
      'drinkType': drinkType,
      'timestamp': timestamp.toIso8601String(),
      'date': date,
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      drinkType: (map['drinkType'] ?? 'Water') as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      date: map['date'] as String,
      isSynced: map['isSynced'] == true || map['isSynced'] == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.parse(map['syncedAt'] as String)
          : null,
    );
  }
}
