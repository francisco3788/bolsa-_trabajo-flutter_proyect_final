import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bolsa_de_trabajo/core/errors/failures.dart';
import 'package:bolsa_de_trabajo/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> currentUser();
  Future<UserModel> signUp(String email, String password, {String? name});
  Future<void> resendEmailVerification(String email, {String? redirectTo});
  Future<void> sendRecoveryCode(String email, {String? redirectTo});
  Future<void> verifyRecoveryCode(String email, String token);
  Future<void> updatePassword(String newPassword);
}

class AuthRemoteDataSourceSupabase implements AuthRemoteDataSource {
  AuthRemoteDataSourceSupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<UserModel?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabase(user);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión.');
      }
      return UserModel.fromSupabase(user);
    } on AuthApiException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('Error desconocido al autenticarse.');
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {if (name != null) 'name': name},
      );

      if (res.user != null) {
        return UserModel.fromSupabase(res.user!);
      }

      throw const AuthFailure('No se pudo completar el registro.');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('Error desconocido al registrar usuario.');
    }
  }

  @override
  Future<void> resendEmailVerification(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure(
        'No se pudo reenviar la verificación de correo.',
      );
    }
  }

  @override
  Future<void> sendRecoveryCode(String email, {String? redirectTo}) async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('No se pudo enviar el código de recuperación.');
    }
  }

  @override
  Future<void> verifyRecoveryCode(String email, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );
      if (response.session == null) {
        throw const AuthFailure('Código inválido o expirado.');
      }
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('No se pudo validar el código.');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('No se pudo actualizar la contraseña.');
    }
  }
}
