import 'package:water_reminder_app/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> registerWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> saveUserProfile(AppUser user);
}
