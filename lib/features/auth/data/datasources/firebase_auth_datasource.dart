import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_reminder_app/features/auth/domain/entities/app_user.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    });
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  Future<AppUser> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    final appUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: DateTime.now(),
    );

    // Save user profile to Firestore
    await saveUserProfile(appUser);

    return appUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
