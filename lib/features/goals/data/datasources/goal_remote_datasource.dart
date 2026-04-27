import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_reminder_app/features/goals/domain/entities/user_goal.dart';

class GoalRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _goalsCollection(String userId) {
    return _firestore
        .collection('user_goals')
        .doc(userId)
        .collection('goals');
  }

  Future<void> upsertGoal(UserGoal goal) async {
    await _goalsCollection(goal.userId).doc(goal.id.toString()).set({
      'dailyTargetMl': goal.dailyTargetMl,
      'startDate': Timestamp.fromDate(goal.startDate),
      'endDate':
          goal.endDate != null ? Timestamp.fromDate(goal.endDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> batchUploadGoals(List<UserGoal> goals) async {
    if (goals.isEmpty) return;
    final batch = _firestore.batch();
    for (final goal in goals) {
      final docRef = _goalsCollection(goal.userId).doc(goal.id.toString());
      batch.set(docRef, {
        'dailyTargetMl': goal.dailyTargetMl,
        'startDate': Timestamp.fromDate(goal.startDate),
        'endDate':
            goal.endDate != null ? Timestamp.fromDate(goal.endDate!) : null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> deleteGoal(String userId, int goalId) async {
    await _goalsCollection(userId).doc(goalId.toString()).delete();
  }
}
