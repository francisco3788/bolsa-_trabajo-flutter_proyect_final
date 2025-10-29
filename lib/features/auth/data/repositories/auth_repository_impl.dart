import 'package:bolsa_de_trabajo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/entities/user_entity.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remote);

  final AuthRemoteDataSource remote;

  @override
  Future<UserEntity?> currentUser() => remote.currentUser();

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return remote.login(email, password);
  }

  @override
  Future<void> logout() => remote.logout();

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  }) {
    return remote.signUp(email, password, name: name);
  }

  @override
  Future<void> resendEmailVerification({
    required String email,
    String? redirectTo,
  }) {
    return remote.resendEmailVerification(email, redirectTo: redirectTo);
  }

  @override
  Future<void> sendRecoveryCode({required String email, String? redirectTo}) {
    return remote.sendRecoveryCode(email, redirectTo: redirectTo);
  }

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String token,
  }) {
    return remote.verifyRecoveryCode(email, token);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return remote.updatePassword(newPassword);
  }
}
