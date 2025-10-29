import 'package:get/get.dart';

import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/resend_email_verification.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        Get.find<LoginUser>(),
        Get.find<ResendEmailVerification>(),
      ),
    );
  }
}
