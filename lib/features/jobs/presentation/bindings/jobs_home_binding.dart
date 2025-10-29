import 'package:get/get.dart';

import '../../../auth/domain/usecases/logout_user.dart';
import '../controllers/jobs_home_controller.dart';

class JobsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<JobsHomeController>(JobsHomeController(Get.find<LogoutUser>()));
  }
}
