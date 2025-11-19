import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

// Using Exception-based error handling for Either Left values
import '../../data/services/application_ai_service.dart';
import '../../data/services/job_application_notification_service.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/usecases/apply_to_job.dart';
import '../../domain/usecases/get_candidate_applications.dart';
import '../../domain/usecases/get_company_applications.dart';
import '../../domain/usecases/update_application_status.dart';
import '../../domain/usecases/get_application_stats.dart';
import '../../constants/job_application_texts.dart';

class JobApplicationController extends GetxController {
  final ApplyToJob applyToJobUseCase;
  final GetCandidateApplications getCandidateApplicationsUseCase;
  final GetCompanyApplications getCompanyApplicationsUseCase;
  final UpdateApplicationStatus updateApplicationStatusUseCase;
  final GetApplicationStats getApplicationStatsUseCase;
  final ApplicationAIService? aiService;
  final JobApplicationNotificationService? notificationService;

  JobApplicationController({
    required this.applyToJobUseCase,
    required this.getCandidateApplicationsUseCase,
    required this.getCompanyApplicationsUseCase,
    required this.updateApplicationStatusUseCase,
    required this.getApplicationStatsUseCase,
    this.aiService,
    this.notificationService,
  });

  // Observable states
  final RxList<JobApplication> candidateApplications = <JobApplication>[].obs;
  final RxList<JobApplication> companyApplications = <JobApplication>[].obs;
  final RxMap<String, dynamic> applicationStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> aiSuggestions = <String, dynamic>{}.obs;
  final RxBool isAISuggesting = false.obs;
  final RxInt unreadNotificationCount = 0.obs;

  // Application form state
  final RxString coverLetter = ''.obs;
  final RxMap<String, dynamic> additionalData = <String, dynamic>{}.obs;

  Future<void> applyToJob({
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await applyToJobUseCase(ApplyToJobParams(
        jobId: jobId,
        candidateId: candidateId,
        candidateName: candidateName,
        candidateEmail: candidateEmail,
        candidatePhone: additionalData['phone'] as String?,
        resumeUrl: additionalData['resume_url'] as String?,
        coverLetter: coverLetter.value,
      ));

      result.fold(
        (error) {
          errorMessage.value = _mapErrorToMessage(error);
          Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
        },
        (application) {
          candidateApplications.add(application);
          coverLetter.value = '';
          additionalData.clear();
          
          // Send notification to company
          if (notificationService != null) {
            notificationService!.notifyNewApplication(application: application);
          }
          
          Get.snackbar(JobApplicationTexts.successTitle, JobApplicationTexts.applicationSubmitted);
        },
      );
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.failedToApplyPrefix} $e';
      Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCandidateApplications(String candidateId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await getCandidateApplicationsUseCase(
        GetCandidateApplicationsParams(candidateId: candidateId),
      );

      result.fold(
        (error) {
          errorMessage.value = _mapErrorToMessage(error);
          Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
        },
        (applications) {
          candidateApplications.assignAll(applications);
        },
      );
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.failedToLoadApplicationsPrefix} $e';
      Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCompanyApplications({
    required String companyId,
    ApplicationStatus? statusFilter,
    String? searchQuery,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await getCompanyApplicationsUseCase(
        GetCompanyApplicationsParams(
          companyId: companyId,
          statusFilter: statusFilter,
          searchQuery: searchQuery,
        ),
      );

      result.fold(
        (error) {
          errorMessage.value = _mapErrorToMessage(error);
          Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
        },
        (applications) {
          companyApplications.assignAll(applications);
        },
      );
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.failedToLoadCompanyApplicationsPrefix} $e';
      Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
    String? reviewNotes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await updateApplicationStatusUseCase(
        UpdateApplicationStatusParams(
          applicationId: applicationId,
          newStatus: newStatus,
          reviewNotes: reviewNotes,
        ),
      );

      result.fold(
        (error) {
          errorMessage.value = _mapErrorToMessage(error);
          Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
        },
        (updatedApplication) {
          // Find the old application to get the previous status
          final oldApplication = [...candidateApplications, ...companyApplications]
              .firstWhere((app) => app.id == applicationId, orElse: () => updatedApplication);
          
          // Update in both lists
          final candidateIndex = candidateApplications.indexWhere((app) => app.id == applicationId);
          if (candidateIndex != -1) {
            candidateApplications[candidateIndex] = updatedApplication;
          }

          final companyIndex = companyApplications.indexWhere((app) => app.id == applicationId);
          if (companyIndex != -1) {
            companyApplications[companyIndex] = updatedApplication;
          }

          // Send notification about status change
          if (notificationService != null && oldApplication.status != newStatus) {
            notificationService!.notifyApplicationStatusChanged(
              application: updatedApplication,
              oldStatus: oldApplication.status,
              newStatus: newStatus,
            );
          }

          Get.snackbar(JobApplicationTexts.successTitle, JobApplicationTexts.statusUpdated);
        },
      );
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.failedToUpdateStatusPrefix} $e';
      Get.snackbar(JobApplicationTexts.errorTitle, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getApplicationStats(String companyId) async {
    try {
      final result = await getApplicationStatsUseCase(
        GetApplicationStatsParams(companyId: companyId),
      );

      result.fold(
        (error) {
          errorMessage.value = _mapErrorToMessage(error);
        },
        (stats) {
          applicationStats.assignAll(stats);
        },
      );
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.failedToLoadStatsPrefix} $e';
    }
  }

  // Filter applications by status
  List<JobApplication> getApplicationsByStatus(ApplicationStatus status) {
    return companyApplications.where((app) => app.status == status).toList();
  }

  // Get applications for a specific job
  List<JobApplication> getApplicationsForJob(String jobId) {
    return companyApplications.where((app) => app.jobId == jobId).toList();
  }

  // Get pending applications count
  int get pendingApplicationsCount {
    return companyApplications.where((app) => app.status == ApplicationStatus.pending).length;
  }

  // Clear form data
  void clearForm() {
    coverLetter.value = '';
    additionalData.clear();
  }

  // Filter functionality for candidate applications
  final Rx<ApplicationStatus?> selectedFilter = Rx<ApplicationStatus?>(null);

  List<JobApplication> get filteredApplications {
    if (selectedFilter.value == null) {
      return candidateApplications;
    }
    return candidateApplications.where((app) => app.status == selectedFilter.value).toList();
  }

  void filterByStatus(ApplicationStatus? status) {
    selectedFilter.value = status;
  }

  String _mapErrorToMessage(Object error) {
    return error.toString();
  }

  // AI-powered features
  Future<void> getAISuggestionForApplication({
    required JobApplication application,
    required String jobTitle,
    required String jobDescription,
    required String companyRequirements,
  }) async {
    if (aiService == null) {
      errorMessage.value = JobApplicationTexts.aiServiceNotAvailable;
      return;
    }

    try {
      isAISuggesting.value = true;
      errorMessage.value = '';

      final result = await aiService!.suggestApplicationStatus(
        application: application,
        jobTitle: jobTitle,
        jobDescription: jobDescription,
        companyRequirements: companyRequirements,
      );

      if (result['success'] == true) {
        aiSuggestions[application.id] = result['suggestion'];
        Get.snackbar(JobApplicationTexts.aiSuggestionTitle, JobApplicationTexts.aiSuggestionGenerated);
      } else {
        errorMessage.value = result['error'] ?? JobApplicationTexts.failedToGenerateAiSuggestion;
      }
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.aiSuggestionErrorPrefix} $e';
    } finally {
      isAISuggesting.value = false;
    }
  }

  Future<void> getBatchAISuggestions({
    required List<JobApplication> applications,
    required String jobTitle,
    required String jobDescription,
    required String companyRequirements,
  }) async {
    if (aiService == null) {
      errorMessage.value = JobApplicationTexts.aiServiceNotAvailable;
      return;
    }

    try {
      isAISuggesting.value = true;
      errorMessage.value = '';

      final results = await aiService!.batchSuggestApplications(
        applications: applications,
        jobTitle: jobTitle,
        jobDescription: jobDescription,
        companyRequirements: companyRequirements,
      );

      int successCount = 0;
      for (final result in results) {
        if (result['success'] == true && result['application_id'] != null) {
          aiSuggestions[result['application_id']] = result['suggestion'];
          successCount++;
        }
      }

      Get.snackbar(JobApplicationTexts.aiSuggestionTitle, 'Generated $successCount recommendations');
    } catch (e) {
      errorMessage.value = 'Batch AI suggestion error: $e';
    } finally {
      isAISuggesting.value = false;
    }
  }

  Future<void> getApplicationInsights({
    required String jobTitle,
  }) async {
    if (aiService == null) {
      errorMessage.value = JobApplicationTexts.aiServiceNotAvailable;
      return;
    }

    try {
      isAISuggesting.value = true;
      errorMessage.value = '';

      final result = await aiService!.generateApplicationInsights(
        applications: companyApplications,
        jobTitle: jobTitle,
      );

      if (result['success'] == true) {
        aiSuggestions['insights'] = result['insights'];
        Get.snackbar(JobApplicationTexts.aiInsightsTitle, JobApplicationTexts.aiInsightsGenerated);
      } else {
        errorMessage.value = result['error'] ?? JobApplicationTexts.failedToGenerateInsights;
      }
    } catch (e) {
      errorMessage.value = '${JobApplicationTexts.aiInsightsErrorPrefix} $e';
    } finally {
      isAISuggesting.value = false;
    }
  }

  Map<String, dynamic>? getAISuggestionForApp(String applicationId) {
    return aiSuggestions[applicationId];
  }

  void clearAISuggestions() {
    aiSuggestions.clear();
  }

  Future<void> loadUnreadNotificationCount(String userId) async {
    if (notificationService == null) return;
    try {
      final count = await notificationService!.getUnreadNotificationCount(userId);
      unreadNotificationCount.value = count;
    } catch (_) {}
  }
}