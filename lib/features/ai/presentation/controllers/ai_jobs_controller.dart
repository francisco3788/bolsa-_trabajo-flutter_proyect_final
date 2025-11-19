import 'package:get/get.dart';
import '../../domain/entities/ai_generated_job.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/generate_ai_jobs.dart';
import '../../domain/usecases/get_ai_generated_jobs.dart';
import '../../domain/usecases/save_ai_generated_jobs.dart';
import '../../constants/ai_texts.dart';

class AiJobsController extends GetxController {
  final GenerateAiJobs generateAiJobsUseCase;
  final GetAiGeneratedJobs getAiGeneratedJobsUseCase;
  final SaveAiGeneratedJobs saveAiGeneratedJobsUseCase;

  AiJobsController({
    required GenerateAiJobs generateAiJobs,
    required GetAiGeneratedJobs getAiGeneratedJobs,
    required SaveAiGeneratedJobs saveAiGeneratedJobs,
  }) : generateAiJobsUseCase = generateAiJobs,
       getAiGeneratedJobsUseCase = getAiGeneratedJobs,
       saveAiGeneratedJobsUseCase = saveAiGeneratedJobs;

  // Observable states
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final searchQuery = ''.obs;
  final selectedLocation = ''.obs;
  final selectedWorkMode = ''.obs;
  final selectedJobType = ''.obs;
  final aiJobs = <AiGeneratedJob>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateLocation(String location) {
    selectedLocation.value = location;
  }

  void updateWorkMode(String workMode) {
    selectedWorkMode.value = workMode;
  }

  void updateJobType(String jobType) {
    selectedJobType.value = jobType;
  }

  // Generate jobs with AI
  Future<void> generateAiJobs() async {
    if (searchQuery.value.isEmpty) {
      errorMessage.value = AiTexts.pleaseEnterSearchQuery;
      return;
    }

    isGenerating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final result = await generateAiJobsUseCase(
        GenerateAiJobsParams(
          searchQuery: searchQuery.value,
          limit: 10,
          location: selectedLocation.value.isEmpty
              ? null
              : selectedLocation.value,
          workMode: selectedWorkMode.value.isEmpty
              ? null
              : selectedWorkMode.value,
          jobType: selectedJobType.value.isEmpty ? null : selectedJobType.value,
        ),
      );

      result.fold(
        (failure) {
          final errorMsg = failure.toString();
          if (errorMsg.contains('rate limit')) {
            errorMessage.value = AiTexts.aiServiceBusyDemoFallback;
          } else if (errorMsg.contains('API key')) {
            errorMessage.value = AiTexts.aiServiceConfigErrorContactSupport;
          } else {
            errorMessage.value = AiTexts.failedToGenerateJobsTryAgain;
          }
          print('AI Error: $errorMsg');
        },
        (jobs) {
          aiJobs.assignAll(jobs);
          // Check if these are demo jobs
          final hasDemoJobs = jobs.any((job) => job.id.startsWith('demo_'));
          if (hasDemoJobs) {
            successMessage.value =
                '${AiTexts.showingDemoJobsWhileBusyPrefix} ${jobs.length} ${AiTexts.showingDemoJobsWhileBusySuffix}';
          } else {
            successMessage.value =
                '${AiTexts.generatedJobsWithAiPrefix} ${jobs.length} ${AiTexts.generatedJobsWithAiSuffix}';
          }
        },
      );
    } catch (e) {
      errorMessage.value = '${AiTexts.errorGeneratingJobsPrefix} $e';
    } finally {
      isGenerating.value = false;
    }
  }

  // Load existing AI generated jobs
  Future<void> loadAiGeneratedJobs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await getAiGeneratedJobsUseCase(
        const GetAiGeneratedJobsParams(limit: 20, isActive: true),
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.toString();
        },
        (jobs) {
          aiJobs.assignAll(jobs);
        },
      );
    } catch (e) {
      errorMessage.value = '${AiTexts.errorLoadingAiJobsPrefix} $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Clear filters
  void clearFilters() {
    searchQuery.value = '';
    selectedLocation.value = '';
    selectedWorkMode.value = '';
    selectedJobType.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    await loadAiGeneratedJobs();
  }

  @override
  void onInit() {
    super.onInit();
    print('AiJobsController: onInit called');
    print(
      'AiJobsController: GenerateAiJobs available: ${Get.isRegistered<GenerateAiJobs>()}',
    );
    print(
      'AiJobsController: GetAiGeneratedJobs available: ${Get.isRegistered<GetAiGeneratedJobs>()}',
    );
    print(
      'AiJobsController: SaveAiGeneratedJobs available: ${Get.isRegistered<SaveAiGeneratedJobs>()}',
    );
    print(
      'AiJobsController: AiRepository available: ${Get.isRegistered<AiRepository>()}',
    );
    loadAiGeneratedJobs();
  }
}
