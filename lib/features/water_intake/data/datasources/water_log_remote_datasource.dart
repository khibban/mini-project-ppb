import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';

class WaterLogRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _logsCollection(String userId) {
    return _firestore
        .collection('water_logs')
        .doc(userId)
        .collection('logs');
  }

  // ── CREATE / UPDATE ──
  Future<void> upsertWaterLog(WaterLog log) async {
    final docId = log.id.toString();
    await _logsCollection(log.userId).doc(docId).set({
      'amount': log.amount,
      'drinkType': log.drinkType,
      'timestamp': Timestamp.fromDate(log.timestamp),
      'date': log.date,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── READ ──
  Future<List<Map<String, dynamic>>> getLogsByDate(
      String userId, String date) async {
    final snapshot = await _logsCollection(userId)
        .where('date', isEqualTo: date)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        ...data,
        'id': doc.id,
        'timestamp': (data['timestamp'] as Timestamp).toDate().toIso8601String(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllLogs(String userId) async {
    final snapshot = await _logsCollection(userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        ...data,
        'id': doc.id,
        'timestamp': (data['timestamp'] as Timestamp).toDate().toIso8601String(),
      };
    }).toList();
  }

  // ── DELETE ──
  Future<void> deleteWaterLog(String userId, int logId) async {
    await _logsCollection(userId).doc(logId.toString()).delete();
  }

  // ── BATCH UPLOAD ──
  Future<void> batchUploadLogs(List<WaterLog> logs) async {
    if (logs.isEmpty) return;

    final batch = _firestore.batch();
    for (final log in logs) {
      final docRef = _logsCollection(log.userId).doc(log.id.toString());
      batch.set(docRef, {
        'amount': log.amount,
        'drinkType': log.drinkType,
        'timestamp': Timestamp.fromDate(log.timestamp),
        'date': log.date,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
