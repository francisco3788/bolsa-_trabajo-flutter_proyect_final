import '../../domain/entities/ai_generated_job.dart';

abstract class AiRemoteDataSource {
  Future<List<AiGeneratedJob>> generateJobs({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  });

  Future<List<AiGeneratedJob>> getGeneratedJobs({
    int? limit,
    bool? isActive,
  });

  Future<void> saveGeneratedJobs(List<AiGeneratedJob> jobs);

  Future<void> deactivateJob(String jobId);

  Future<List<AiGeneratedJob>> searchJobs({
    required String query,
    int? limit,
  });
}




