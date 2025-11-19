import 'package:dartz/dartz.dart';
import '../entities/ai_generated_job.dart';

abstract class AiRepository {
  Future<Either<Exception, List<AiGeneratedJob>>> generateJobs({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  });

  Future<Either<Exception, List<AiGeneratedJob>>> getGeneratedJobs({
    int? limit,
    bool? isActive,
  });

  Future<Either<Exception, void>> saveGeneratedJobs(List<AiGeneratedJob> jobs);

  Future<Either<Exception, void>> deactivateJob(String jobId);

  Future<Either<Exception, List<AiGeneratedJob>>> searchJobs({
    required String query,
    int? limit,
  });
}