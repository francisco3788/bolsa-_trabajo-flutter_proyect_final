import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(Get.find<AuthSessionService>()),
    );
  }
}
