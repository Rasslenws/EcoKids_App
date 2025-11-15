import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
}
