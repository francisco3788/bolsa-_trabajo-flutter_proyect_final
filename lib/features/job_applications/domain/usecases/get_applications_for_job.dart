import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

class GetApplicationsForJob {
  final JobApplicationRepository repository;

  GetApplicationsForJob(this.repository);

  Future<Either<Exception, List<JobApplication>>> call(GetApplicationsForJobParams params) async {
    return repository.getApplicationsByJob(jobId: params.jobId, status: params.statusFilter);
  }
}

class GetApplicationsForJobParams extends Equatable {
  final String jobId;
  final ApplicationStatus? statusFilter;

  const GetApplicationsForJobParams({required this.jobId, this.statusFilter});

  @override
  List<Object?> get props => [jobId, statusFilter];
}