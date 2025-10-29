import 'package:supabase_flutter/supabase_flutter.dart';

import 'failures.dart';

/// Utility to translate low-level authentication errors into friendly,
/// localized messages for the UI.
class AuthErrorMapper {
  static const _unexpectedError =
      'Ocurrió un error inesperado al procesar tu solicitud. Intenta nuevamente.';

  /// Returns a localized message describing [error].
  static String map(dynamic error) {
    if (error is AuthException) {
      return _fromAuthException(error);
    }

    if (error is Failure) {
      return _fromFailure(error);
    }

    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    return _unexpectedError;
  }

  static String _fromFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.';
    }

    if (failure is ServerFailure) {
      return 'Tenemos problemas para contactar el servidor. Por favor, inténtalo más tarde.';
    }

    if (failure is AuthFailure) {
      return _normalizeMessage(failure.message);
    }

    return failure.message.isEmpty ? _unexpectedError : failure.message;
  }

  static String _fromAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    final statusCode = exception.statusCode?.toString();

    if (statusCode == '429' ||
        message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Hiciste demasiados intentos. Espera unos segundos antes de volver a intentarlo.';
    }

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password') ||
        message.contains('wrong email or password') ||
        message.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos.';
    }

    if (message.contains('email not confirmed') ||
        message.contains('email not verified')) {
      return 'Tu correo aún no está verificado. Revisa tu bandeja de entrada para confirmar tu cuenta.';
    }

    if (message.contains('otp') && message.contains('expired')) {
      return 'El código ha expirado. Solicita uno nuevo.';
    }

    if (message.contains('password') &&
        (message.contains('weak') || message.contains('short'))) {
      return 'La contraseña es demasiado débil. Asegúrate de cumplir con los requisitos mínimos.';
    }

    return _normalizeMessage(exception.message);
  }

  static String _normalizeMessage(String message) {
    final normalized = message.toLowerCase();

    if (normalized.isEmpty || normalized.contains('unknown')) {
      return _unexpectedError;
    }

    if (normalized.contains('invalid login credentials') ||
        normalized.contains('invalid email or password') ||
        normalized.contains('invalid credentials') ||
        normalized.contains('wrong email or password')) {
      return 'Correo o contraseña incorrectos.';
    }

    if (normalized.contains('email not confirmed') ||
        normalized.contains('email not verified')) {
      return 'Tu correo aún no está verificado. Revisa tu bandeja de entrada.';
    }

    if (normalized.contains('too many requests') ||
        normalized.contains('rate limit') ||
        normalized.contains('demasiadas solicitudes')) {
      return 'Hiciste demasiados intentos. Espera unos segundos antes de intentar de nuevo.';
    }

    if (normalized.contains('not found') ||
        normalized.contains('no user') ||
        normalized.contains('no existe')) {
      return 'No encontramos una cuenta con esos datos.';
    }

    return message;
  }

  static bool isEmailNotVerified(String message) {
    if (message.isEmpty) return false;

    final normalized = message.toLowerCase();
    final plain = normalized
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    return normalized.contains('no está verificado') ||
        plain.contains('no esta verificado') ||
        normalized.contains('email not verified') ||
        normalized.contains('email not confirmed');
  }
}
