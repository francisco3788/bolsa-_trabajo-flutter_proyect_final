import 'package:get/get.dart';

import '../../../../core/errors/auth_error_mapper.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/usecases/sign_up_user.dart';

class RegisterController extends GetxController {
  RegisterController(this._signUpUser);

  final SignUpUser _signUpUser;

  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final loading = false.obs;
  final error = RxnString();
  final info = RxnString(); // mensajes informativos (ej. "Revisa tu correo")

  Future<void> doRegister() async {
    error.value = null;
    info.value = null;
    loading.value = true;
    try {
      final user = await _signUpUser(
        SignUpParams(
          email: email.value.trim(),
          password: password.value.trim(),
          name: name.value.trim().isEmpty ? null : name.value.trim(),
        ),
      );

      final hasSession = user.email.isNotEmpty;

      if (hasSession) {
        Get.offAllNamed(AppRoutes.jobsHome);
      } else {
        info.value =
            'Cuenta creada. Revisa tu correo para confirmar y luego inicia sesión.';
        // Opcional: navegar a login
        // Get.offAllNamed(AppRoutes.login);
      }
    } catch (err) {
      error.value = AuthErrorMapper.map(err);
    } finally {
      loading.value = false;
    }
  }
}
