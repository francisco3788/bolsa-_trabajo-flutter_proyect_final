import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

class GetCandidateApplications {
  final JobApplicationRepository repository;

  GetCandidateApplications(this.repository);

  Future<Either<Exception, List<JobApplication>>> call(GetCandidateApplicationsParams params) async {
    return repository.getApplicationsByCandidate(
      candidateId: params.candidateId,
      status: params.statusFilter,
    );
  }
}

class GetCandidateApplicationsParams extends Equatable {
  final String candidateId;
  final ApplicationStatus? statusFilter;

  const GetCandidateApplicationsParams({required this.candidateId, this.statusFilter});

  @override
  List<Object?> get props => [candidateId, statusFilter];
}