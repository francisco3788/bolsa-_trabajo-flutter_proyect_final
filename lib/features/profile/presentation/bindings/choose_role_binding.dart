import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../domain/usecases/save_candidate_profile.dart';
import '../../domain/usecases/save_company_profile.dart';
import '../../domain/usecases/set_user_role.dart';
import '../controllers/choose_role_controller.dart';

class ChooseRoleBinding extends Bindings {
  @override
  void dependencies() {
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
