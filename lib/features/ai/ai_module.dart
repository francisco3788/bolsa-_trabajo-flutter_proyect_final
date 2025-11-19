import 'package:get/get.dart';
import '../../../../core/config/app_env.dart';
import '../../../../core/network/network_info.dart';
import 'data/datasources/ai_remote_datasource.dart';
import 'data/datasources/ai_remote_datasource_mock.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'domain/repositories/ai_repository.dart';
import 'domain/usecases/generate_ai_jobs.dart';
import 'domain/usecases/get_ai_generated_jobs.dart';
import 'domain/usecases/save_ai_generated_jobs.dart';
import 'presentation/controllers/ai_jobs_controller.dart';

class AiModule {
  static void init() {
    print('AiModule: Initializing AI module...');
    
    // Register all dependencies
    if (!Get.isRegistered<AiRemoteDataSource>()) {
      // Use mock implementation for immediate functionality
      Get.lazyPut<AiRemoteDataSource>(() => AiRemoteDataSourceMock(
        supabaseUrl: AppEnv.supabaseUrl,
        supabaseAnonKey: AppEnv.supabaseAnonKey,
      ));
      print('AiModule: AiRemoteDataSource (MOCK) registered');
    }

    if (!Get.isRegistered<NetworkInfo>()) {
      Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl());
      print('AiModule: NetworkInfo registered');
    }

    if (!Get.isRegistered<AiRepository>()) {
      Get.lazyPut<AiRepository>(() => AiRepositoryImpl(
        remoteDataSource: Get.find<AiRemoteDataSource>(),
        networkInfo: Get.find<NetworkInfo>(),
      ));
      print('AiModule: AiRepository registered');
    }

    if (!Get.isRegistered<GenerateAiJobs>()) {
      Get.lazyPut(() => GenerateAiJobs(Get.find<AiRepository>()));
      print('AiModule: GenerateAiJobs registered');
    }

    if (!Get.isRegistered<GetAiGeneratedJobs>()) {
      Get.lazyPut(() => GetAiGeneratedJobs(Get.find<AiRepository>()));
      print('AiModule: GetAiGeneratedJobs registered');
    }

    if (!Get.isRegistered<SaveAiGeneratedJobs>()) {
      Get.lazyPut(() => SaveAiGeneratedJobs(Get.find<AiRepository>()));
      print('AiModule: SaveAiGeneratedJobs registered');
    }

    if (!Get.isRegistered<AiJobsController>()) {
      Get.lazyPut(() => AiJobsController(
        generateAiJobs: Get.find<GenerateAiJobs>(),
        getAiGeneratedJobs: Get.find<GetAiGeneratedJobs>(),
        saveAiGeneratedJobs: Get.find<SaveAiGeneratedJobs>(),
      ));
      print('AiModule: AiJobsController registered');
    }
    
    print('AiModule: All AI dependencies registered successfully!');
  }
  
  static void ensureInitialized() {
    if (!Get.isRegistered<AiJobsController>()) {
      print('AiModule: Dependencies not found, forcing initialization...');
      init();
    }
  }
  
  static void dispose() {
    print('AiModule: Disposing AI module...');
    if (Get.isRegistered<AiJobsController>()) {
      Get.delete<AiJobsController>();
    }
    if (Get.isRegistered<SaveAiGeneratedJobs>()) {
      Get.delete<SaveAiGeneratedJobs>();
    }
    if (Get.isRegistered<GetAiGeneratedJobs>()) {
      Get.delete<GetAiGeneratedJobs>();
    }
    if (Get.isRegistered<GenerateAiJobs>()) {
      Get.delete<GenerateAiJobs>();
    }
    if (Get.isRegistered<AiRepository>()) {
      Get.delete<AiRepository>();
    }
    if (Get.isRegistered<NetworkInfo>()) {
      Get.delete<NetworkInfo>();
    }
    if (Get.isRegistered<AiRemoteDataSource>()) {
      Get.delete<AiRemoteDataSource>();
    }
    print('AiModule: AI module disposed');
  }
}