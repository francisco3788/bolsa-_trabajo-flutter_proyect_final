import 'package:get/get.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/utils/validators.dart';
import '../../domain/usecases/send_recovery_code.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/verify_recovery_code.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(
    this._sendRecoveryCode,
    this._verifyRecoveryCode,
    this._updatePassword,
  );

  final SendRecoveryCode _sendRecoveryCode;
  final VerifyRecoveryCode _verifyRecoveryCode;
  final UpdatePassword _updatePassword;

  final step = 0.obs;
  final email = ''.obs;
  final code = ''.obs;
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;

  final loading = false.obs;
  final error = RxnString();
  final info = RxnString();

  Future<void> submitEmail() async {
    error.value = null;
    info.value = null;

    final emailValue = email.value.trim();
    final emailValidation = Validators.email(emailValue);
    if (emailValidation != null) {
      error.value = emailValidation;
      return;
    }

    loading.value = true;
    try {
      await _sendRecoveryCode(SendRecoveryCodeParams(emailValue));
      info.value =
          'Te enviamos un código al correo. Revísalo e ingrésalo debajo.';
      step.value = 1;
    } catch (e) {
      if (e is Failure) {
        error.value = e.message;
      } else {
        error.value = e.toString();
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> submitNewPassword() async {
    error.value = null;
    info.value = null;

    final emailValue = email.value.trim();
    final codeValue = code.value.trim();
    final passwordValue = newPassword.value.trim();
    final confirmValue = confirmPassword.value.trim();

    if (codeValue.isEmpty) {
      error.value = 'Ingresa el código recibido.';
      return;
    }

    final passwordValidation = Validators.password(passwordValue);
    if (passwordValidation != null) {
      error.value = passwordValidation;
      return;
    }

    if (passwordValue != confirmValue) {
      error.value = 'Las contraseñas no coinciden.';
      return;
    }

    loading.value = true;
    try {
      await _verifyRecoveryCode(
        VerifyRecoveryCodeParams(email: emailValue, code: codeValue),
      );
      await _updatePassword(UpdatePasswordParams(passwordValue));
      info.value =
          'Contraseña actualizada correctamente. Inicia sesión con tu nueva clave.';
    } catch (e) {
      if (e is Failure) {
        error.value = e.message;
      } else {
        error.value = e.toString();
      }
    } finally {
      loading.value = false;
    }
  }

  void resetFlow() {
    step.value = 0;
    code.value = '';
    newPassword.value = '';
    confirmPassword.value = '';
    error.value = null;
    info.value = null;
  }
}
