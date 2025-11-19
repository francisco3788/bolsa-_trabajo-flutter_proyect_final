import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/ai_generated_job.dart';
import '../repositories/ai_repository.dart';

class GetAiGeneratedJobs {
  final AiRepository repository;

  GetAiGeneratedJobs(this.repository);

  Future<Either<Exception, List<AiGeneratedJob>>> call(GetAiGeneratedJobsParams params) async {
    return await repository.getGeneratedJobs(
      limit: params.limit,
      isActive: params.isActive,
    );
  }
}

class GetAiGeneratedJobsParams extends Equatable {
  final int? limit;
  final bool? isActive;

  const GetAiGeneratedJobsParams({
    this.limit,
    this.isActive,
  });

  @override
  List<Object?> get props => [limit, isActive];
}