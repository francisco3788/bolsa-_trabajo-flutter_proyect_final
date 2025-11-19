import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/job_application_repository.dart';

class GetApplicationStats {
  final JobApplicationRepository repository;

  GetApplicationStats(this.repository);

  Future<Either<Exception, Map<String, int>>> call(GetApplicationStatsParams params) async {
    return repository.getApplicationStats(companyId: params.companyId, jobId: params.jobId);
  }
}

class GetApplicationStatsParams extends Equatable {
  final String companyId;
  final String? jobId;

  const GetApplicationStatsParams({required this.companyId, this.jobId});

  @override
  List<Object?> get props => [companyId, jobId];
}