import 'package:get/get.dart';

import '../../../auth/domain/usecases/logout_user.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../controllers/jobs_home_controller.dart';

class JobsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<JobsHomeController>(
      JobsHomeController(
        jobsRepository: Get.find<JobsRepository>(),
        logoutUser: Get.find<LogoutUser>(),
      ),
    );
  }
}
