import 'package:get/get.dart';

import '../../../../core/errors/auth_error_mapper.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/logout_user.dart';

class JobsHomeController extends GetxController {
  JobsHomeController(this._logoutUser);

  final LogoutUser _logoutUser;

  final loading = false.obs;
  final error = RxnString();

  Future<void> doLogout() async {
    loading.value = true;
    error.value = null;
    try {
      await _logoutUser(const NoParams());
    } catch (err) {
      error.value = AuthErrorMapper.map(err);
    } finally {
      loading.value = false;
    }
  }
}
