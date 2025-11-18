import 'package:get/get.dart';
import 'package:bolsa_de_trabajo/core/services/auth_session_service.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    // The ProfilePage will determine which specific page to show
    // based on the user role. Each individual page will handle its own binding.
    // We just need to ensure the auth service is available for role checking
    Get.find<AuthSessionService>();
  }
}