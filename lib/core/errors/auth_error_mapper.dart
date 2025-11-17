import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/constants/auth_messages.dart';
import 'failures.dart';
import '../constants/core_texts.dart';

/// Utility to translate low-level authentication errors into friendly,
/// localized messages for the UI.
class AuthErrorMapper {
  static const _unexpectedError = AuthMessages.unexpectedError;

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
      return AuthMessages.noInternet;
    }

    if (failure is ServerFailure) {
      return AuthMessages.serverUnavailable;
    }

    if (failure is AuthFailure) {
      return _normalizeMessage(failure.message);
    }

    return failure.message.isEmpty ? _unexpectedError : failure.message;
  }

  static String _fromAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    final statusCode = exception.statusCode?.toString();

    if (statusCode == CoreCodes.httpTooManyRequests ||
        message.contains(CorePatterns.tooManyRequests) ||
        message.contains(CorePatterns.rateLimit)) {
      return AuthMessages.tooManyAttempts;
    }

    if (message.contains(CorePatterns.invalidLoginCredentials) ||
        message.contains(CorePatterns.invalidEmailOrPassword) ||
        message.contains(CorePatterns.wrongEmailOrPassword) ||
        message.contains(CorePatterns.invalidCredentials)) {
      return AuthMessages.incorrectCredentials;
    }

    if (message.contains(CorePatterns.emailNotConfirmed) ||
        message.contains(CorePatterns.emailNotVerified)) {
      return AuthMessages.emailNotVerifiedConfirmInbox;
    }

    if (message.contains(CorePatterns.otp) && message.contains(CorePatterns.expired)) {
      return AuthMessages.otpExpired;
    }

    if (message.contains(CorePatterns.password) &&
        (message.contains(CorePatterns.weak) || message.contains(CorePatterns.short))) {
      return AuthMessages.weakPassword;
    }

    return _normalizeMessage(exception.message);
  }

  static String _normalizeMessage(String message) {
    final normalized = message.toLowerCase();

    if (normalized.isEmpty || normalized.contains(CorePatterns.unknown)) {
      return _unexpectedError;
    }

    if (normalized.contains(CorePatterns.invalidLoginCredentials) ||
        normalized.contains(CorePatterns.invalidEmailOrPassword) ||
        normalized.contains(CorePatterns.invalidCredentials) ||
        normalized.contains(CorePatterns.wrongEmailOrPassword)) {
      return AuthMessages.incorrectCredentials;
    }

    if (normalized.contains(CorePatterns.emailNotConfirmed) ||
        normalized.contains(CorePatterns.emailNotVerified)) {
      return AuthMessages.emailNotVerifiedGeneric;
    }

    if (normalized.contains(CorePatterns.tooManyRequests) ||
        normalized.contains(CorePatterns.rateLimit) ||
        normalized.contains(CorePatterns.demasiadasSolicitudes)) {
      return AuthMessages.tooManyAttempts;
    }

    if (normalized.contains(CorePatterns.notFound) ||
        normalized.contains(CorePatterns.noUser) ||
        normalized.contains(CorePatterns.noExiste)) {
      return AuthMessages.userNotFound;
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

    return normalized.contains(CorePatterns.itIsNotVerified.toLowerCase()) ||
        plain.contains(CorePatterns.itIsNotVerified.toLowerCase()) ||
        normalized.contains(CorePatterns.emailNotVerified) ||
        normalized.contains(CorePatterns.emailNotConfirmed);
  }
}
