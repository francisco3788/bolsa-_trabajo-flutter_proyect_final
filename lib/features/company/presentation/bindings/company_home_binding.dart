import 'package:get/get.dart';

import '../../../auth/domain/usecases/logout_user.dart';
import '../controllers/company_home_controller.dart';

class CompanyHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CompanyHomeController>(
      CompanyHomeController(Get.find<LogoutUser>()),
    );
  }
}
