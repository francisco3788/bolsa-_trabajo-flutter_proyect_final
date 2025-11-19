import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

class UpdateApplicationStatus {
  final JobApplicationRepository repository;

  UpdateApplicationStatus(this.repository);

  Future<Either<Exception, JobApplication>> call(UpdateApplicationStatusParams params) async {
    return repository.updateApplicationStatus(
      applicationId: params.applicationId,
      newStatus: params.newStatus,
      updatedBy: params.updatedBy,
      notes: params.reviewNotes,
    );
  }
}

class UpdateApplicationStatusParams extends Equatable {
  final String applicationId;
  final ApplicationStatus newStatus;
  final String? reviewNotes;
  final String? updatedBy;

  const UpdateApplicationStatusParams({
    required this.applicationId,
    required this.newStatus,
    this.reviewNotes,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [applicationId, newStatus, reviewNotes, updatedBy];
}