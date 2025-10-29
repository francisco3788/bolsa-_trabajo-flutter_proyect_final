import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<void> logout();
  Future<UserEntity?> currentUser();
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  });
  Future<void> resendEmailVerification({
    required String email,
    String? redirectTo,
  });
  Future<void> sendRecoveryCode({required String email, String? redirectTo});
  Future<void> verifyRecoveryCode({
    required String email,
    required String token,
  });
  Future<void> updatePassword({required String newPassword});
}
