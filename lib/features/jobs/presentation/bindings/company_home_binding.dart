import 'package:get/get.dart';

import '../../domain/repositories/jobs_repository.dart';
import '../controllers/company_home_controller.dart';

class CompanyHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CompanyHomeController>(
      CompanyHomeController(
        jobsRepository: Get.find<JobsRepository>(),
      ),
    );
  }
}