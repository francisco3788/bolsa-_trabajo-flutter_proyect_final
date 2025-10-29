import 'package:get/get.dart';

import '../../domain/repositories/jobs_repository.dart';
import '../controllers/company_applications_controller.dart';

class CompanyApplicationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CompanyApplicationsController>(
      CompanyApplicationsController(jobsRepository: Get.find<JobsRepository>()),
    );
  }
}