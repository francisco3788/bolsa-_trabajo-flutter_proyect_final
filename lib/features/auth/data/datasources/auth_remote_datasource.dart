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
        throw const AuthFailure('We were unable to log in.');
      }
      return UserModel.fromSupabase(user);
    } on AuthApiException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('Unknown error during authentication.');
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

      throw const AuthFailure('Registration could not be completed.');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('Unknown error registering user.');
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
        'The email verification could not be resent.',
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
      throw const ServerFailure('The recovery code could not be sent.');
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
        throw const AuthFailure('Invalid or expired code.');
      }
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('The code could not be validated.');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const ServerFailure('The password could not be updated.');
    }
  }
}
