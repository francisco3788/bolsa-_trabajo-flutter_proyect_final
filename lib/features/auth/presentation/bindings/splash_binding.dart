import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../../profile/domain/usecases/get_candidate_profile.dart';
import '../../../profile/domain/usecases/get_company_profile.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetCandidateProfile>()) {
      Get.put<GetCandidateProfile>(GetCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<GetCompanyProfile>()) {
      Get.put<GetCompanyProfile>(GetCompanyProfile(Get.find()));
    }
    Get.put<SplashController>(
      SplashController(Get.find<AuthSessionService>()),
    );
  }
}
