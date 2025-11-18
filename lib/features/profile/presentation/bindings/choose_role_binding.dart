import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../domain/usecases/save_candidate_profile.dart';
import '../../domain/usecases/save_company_profile.dart';
import '../../domain/usecases/set_user_role.dart';
import '../../domain/usecases/get_candidate_profile.dart';
import '../../domain/usecases/get_company_profile.dart';
import '../controllers/choose_role_controller.dart';

class ChooseRoleBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure profile use cases are registered for AuthSessionService display name
    if (!Get.isRegistered<GetCandidateProfile>()) {
      Get.put<GetCandidateProfile>(GetCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<GetCompanyProfile>()) {
      Get.put<GetCompanyProfile>(GetCompanyProfile(Get.find()));
    }
    Get.put<ChooseRoleController>(
      ChooseRoleController(
        setUserRole: Get.find<SetUserRole>(),
        saveCandidateProfile: Get.find<SaveCandidateProfile>(),
        saveCompanyProfile: Get.find<SaveCompanyProfile>(),
        sessionService: Get.find<AuthSessionService>(),
      ),
    );
  }
}
