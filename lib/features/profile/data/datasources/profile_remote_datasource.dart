import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';

abstract class ProfileRemoteDataSource {
  Future<String?> getCurrentRole();
  Future<void> setUserRole(String role);
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  });
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  });
}

class ProfileRemoteDataSourceSupabase implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceSupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> getCurrentRole() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final data = await _client
          .from('user_roles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final role = data?['role'] as String?;
      if (role == null) {
        return null;
      }

      if (role == 'candidate' || role == 'company') {
        return role;
      }

      return null;
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'No se pudo obtener el rol actual.',
      );
    } catch (_) {
      throw const ServerFailure('No se pudo obtener el rol actual.');
    }
  }

  @override
  Future<void> setUserRole(String role) async {
    final userId = _requireUserId();

    if (role != 'candidate' && role != 'company') {
      throw const ServerFailure('Rol seleccionado no es valido.');
    }

    try {
      await _client.from('user_roles').upsert(
        {
          'id': userId,
          'role': role,
          'chosen_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'No se pudo guardar tu seleccion de rol.',
      );
    } catch (_) {
      throw const ServerFailure('No se pudo guardar tu seleccion de rol.');
    }
  }

  @override
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  }) async {
    final userId = _requireUserId();

    try {
      await _client.from('candidate_profiles').upsert(
        {
          'id': userId,
          'name': name,
          'location': location,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'No se pudo guardar tu perfil de candidato.',
      );
    } catch (_) {
      throw const ServerFailure('No se pudo guardar tu perfil de candidato.');
    }
  }

  @override
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  }) async {
    final userId = _requireUserId();

    try {
      await _client.from('company_profiles').upsert(
        {
          'id': userId,
          'company_name': companyName,
          'sector': sector,
          'location': location,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'No se pudo guardar el perfil de la empresa.',
      );
    } catch (_) {
      throw const ServerFailure('No se pudo guardar el perfil de la empresa.');
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthFailure('Tu sesion ha expirado. Inicia sesion nuevamente.');
    }
    return userId;
  }
}
