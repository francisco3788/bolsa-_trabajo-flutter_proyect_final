import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bolsa_de_trabajo/core/config/ai_config.dart';
import 'package:bolsa_de_trabajo/features/job_applications/data/repositories/job_application_repository_impl.dart';
import 'package:bolsa_de_trabajo/features/job_applications/data/services/application_ai_service.dart';
import 'package:bolsa_de_trabajo/features/job_applications/data/services/job_application_notification_service.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/repositories/job_application_repository.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/apply_to_job.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/get_candidate_applications.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/get_company_applications.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/get_application_stats.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/update_application_status.dart';
import 'package:bolsa_de_trabajo/features/job_applications/domain/usecases/get_applications_for_job.dart';
import 'package:bolsa_de_trabajo/features/job_applications/presentation/controllers/job_application_controller.dart';

class JobApplicationBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<JobApplicationRepository>(
      () => JobApplicationRepositoryImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );

    // AI Service
    Get.lazyPut<ApplicationAIService>(
      () => ApplicationAIService(
        apiKey: AiConfig.geminiApiKey,
      ),
    );

    // Notification Service
    Get.lazyPut<JobApplicationNotificationService>(
      () => JobApplicationNotificationService(
        supabaseClient: Supabase.instance.client,
      ),
    );

    // Use Cases
    Get.lazyPut(() => ApplyToJob(Get.find<JobApplicationRepository>()));
    Get.lazyPut(() => GetCandidateApplications(Get.find<JobApplicationRepository>()));
    Get.lazyPut(() => GetCompanyApplications(Get.find<JobApplicationRepository>()));
    Get.lazyPut(() => GetApplicationStats(Get.find<JobApplicationRepository>()));
    Get.lazyPut(() => UpdateApplicationStatus(Get.find<JobApplicationRepository>()));
    Get.lazyPut(() => GetApplicationsForJob(Get.find<JobApplicationRepository>()));

    // Controller
    Get.lazyPut<JobApplicationController>(
      () => JobApplicationController(
        applyToJobUseCase: Get.find<ApplyToJob>(),
        getCandidateApplicationsUseCase: Get.find<GetCandidateApplications>(),
        getCompanyApplicationsUseCase: Get.find<GetCompanyApplications>(),
        updateApplicationStatusUseCase: Get.find<UpdateApplicationStatus>(),
        getApplicationStatsUseCase: Get.find<GetApplicationStats>(),
        aiService: Get.find<ApplicationAIService>(),
        notificationService: Get.find<JobApplicationNotificationService>(),
      ),
    );
  }
}