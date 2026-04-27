import 'package:water_reminder_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:water_reminder_app/features/auth/domain/entities/app_user.dart';
import 'package:water_reminder_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<AppUser?> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<AppUser?> get currentUser async => _datasource.currentUser;

  @override
  Future<AppUser> signInWithEmail(String email, String password) {
    return _datasource.signInWithEmail(email, password);
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) {
    return _datasource.registerWithEmail(email, password);
  }

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }

  @override
  Future<void> saveUserProfile(AppUser user) {
    return _datasource.saveUserProfile(user);
  }
}
