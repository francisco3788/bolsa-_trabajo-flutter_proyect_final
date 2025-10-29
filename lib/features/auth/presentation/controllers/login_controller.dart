import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/auth_error_mapper.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/resend_email_verification.dart';

class LoginController extends GetxController {
  LoginController(this._loginUser, this._resendEmailVerification);

  static const _loginCooldownDuration = Duration(seconds: 5);
  static const _verificationCooldownDuration = Duration(seconds: 60);

  final LoginUser _loginUser;
  final ResendEmailVerification _resendEmailVerification;

  final formKey = GlobalKey<FormState>();

  final loading = false.obs;
  final resendLoading = false.obs;
  final error = RxnString();
  final info = RxnString();
  final showValidation = false.obs;
  final isPasswordObscured = true.obs;
  final cooldownSeconds = 0.obs;
  final resendCooldownSeconds = 0.obs;
  final requiresEmailVerification = false.obs;

  bool get isInCooldown => cooldownSeconds.value > 0;
  bool get isInResendCooldown => resendCooldownSeconds.value > 0;
  bool get canResendVerification =>
      requiresEmailVerification.value &&
      !resendLoading.value &&
      !isInResendCooldown;

  Timer? _cooldownTimer;
  Timer? _resendCooldownTimer;
  String _lastAttemptedEmail = '';

  String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'El formato del correo no es válido.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    if (trimmed.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    return null;
  }

  void togglePasswordVisibility() {
    isPasswordObscured.toggle();
  }

  Future<void> doLogin({
    required String email,
    required String password,
  }) async {
    if (loading.value || isInCooldown) {
      return;
    }

    final formState = formKey.currentState;
    if (formState == null) {
      return;
    }

    final isValid = formState.validate();
    showValidation.value = !isValid;

    if (!isValid) {
      return;
    }

    loading.value = true;
    error.value = null;
    info.value = null;
    requiresEmailVerification.value = false;

    final trimmedEmail = email.trim();
    _lastAttemptedEmail = trimmedEmail;

    try {
      await _loginUser(LoginParams(trimmedEmail, password.trim()));
      showValidation.value = false;
    } catch (err) {
      final message = AuthErrorMapper.map(err);
      error.value = message;

      if (AuthErrorMapper.isEmailNotVerified(message)) {
        requiresEmailVerification.value = true;
        info.value =
            'Tu cuenta aún no está verificada. Podemos reenviar el correo si lo necesitas.';
      }

      _startLoginCooldown();
    } finally {
      loading.value = false;
    }
  }

  Future<void> resendVerificationEmail({String? email}) async {
    if (!requiresEmailVerification.value ||
        resendLoading.value ||
        isInResendCooldown) {
      return;
    }

    final targetEmail = (email ?? _lastAttemptedEmail).trim();
    if (targetEmail.isEmpty) {
      error.value =
          'Ingresa tu correo electrónico para reenviar la verificación.';
      showValidation.value = true;
      return;
    }

    resendLoading.value = true;

    try {
      await _resendEmailVerification(
        ResendEmailVerificationParams(email: targetEmail),
      );
      info.value =
          'Te enviamos un nuevo correo de verificación. Revisa tu bandeja de entrada.';
      _startResendCooldown();
    } catch (err) {
      error.value = AuthErrorMapper.map(err);
    } finally {
      resendLoading.value = false;
    }
  }

  void _startLoginCooldown() {
    if (isInCooldown) return;

    cooldownSeconds.value = _loginCooldownDuration.inSeconds;
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = cooldownSeconds.value - 1;
      if (remaining <= 0) {
        cooldownSeconds.value = 0;
        timer.cancel();
      } else {
        cooldownSeconds.value = remaining;
      }
    });
  }

  void _startResendCooldown() {
    resendCooldownSeconds.value = _verificationCooldownDuration.inSeconds;
    _resendCooldownTimer?.cancel();

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = resendCooldownSeconds.value - 1;
      if (remaining <= 0) {
        resendCooldownSeconds.value = 0;
        timer.cancel();
      } else {
        resendCooldownSeconds.value = remaining;
      }
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.onClose();
  }
}
