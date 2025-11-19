import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

class GetCompanyApplications {
  final JobApplicationRepository repository;

  GetCompanyApplications(this.repository);

  Future<Either<Exception, List<JobApplication>>> call(GetCompanyApplicationsParams params) async {
    return repository.getApplicationsByCompany(
      companyId: params.companyId,
      status: params.statusFilter,
      searchQuery: params.searchQuery,
    );
  }
}

class GetCompanyApplicationsParams extends Equatable {
  final String companyId;
  final ApplicationStatus? statusFilter;
  final String? searchQuery;

  const GetCompanyApplicationsParams({
    required this.companyId,
    this.statusFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [companyId, statusFilter, searchQuery];
}