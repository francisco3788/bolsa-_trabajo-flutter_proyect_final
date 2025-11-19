import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/ai_generated_job.dart';
import '../repositories/ai_repository.dart';

class GenerateAiJobs {
  final AiRepository repository;

  GenerateAiJobs(this.repository);

  Future<Either<Exception, List<AiGeneratedJob>>> call(GenerateAiJobsParams params) async {
    return await repository.generateJobs(
      searchQuery: params.searchQuery,
      limit: params.limit,
      location: params.location,
      workMode: params.workMode,
      jobType: params.jobType,
    );
  }
}

class GenerateAiJobsParams extends Equatable {
  final String searchQuery;
  final int limit;
  final String? location;
  final String? workMode;
  final String? jobType;

  const GenerateAiJobsParams({
    required this.searchQuery,
    this.limit = 10,
    this.location,
    this.workMode,
    this.jobType,
  });

  @override
  List<Object?> get props => [searchQuery, limit, location, workMode, jobType];
}