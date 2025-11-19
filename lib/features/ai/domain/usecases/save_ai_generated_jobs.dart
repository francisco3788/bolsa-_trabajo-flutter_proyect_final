import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/ai_repository.dart';
import '../entities/ai_generated_job.dart';

class SaveAiGeneratedJobs {
  final AiRepository repository;

  SaveAiGeneratedJobs(this.repository);

  Future<Either<Exception, void>> call(SaveAiGeneratedJobsParams params) async {
    return await repository.saveGeneratedJobs(params.jobs);
  }
}

class SaveAiGeneratedJobsParams extends Equatable {
  final List<AiGeneratedJob> jobs;

  const SaveAiGeneratedJobsParams(this.jobs);

  @override
  List<Object?> get props => [jobs];
}