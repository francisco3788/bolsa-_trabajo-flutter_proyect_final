import 'package:dartz/dartz.dart';
import '../entities/job_application.dart';

abstract class JobApplicationRepository {
  /// Apply to a job
  Future<Either<Exception, JobApplication>> applyToJob({
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
    String? resumeUrl,
    String? coverLetter,
    ApplicationSource source,
  });

  /// Get applications for a specific job
  Future<Either<Exception, List<JobApplication>>> getApplicationsByJob({
    required String jobId,
    ApplicationStatus? status,
  });

  /// Get applications for a specific candidate
  Future<Either<Exception, List<JobApplication>>> getApplicationsByCandidate({
    required String candidateId,
    ApplicationStatus? status,
  });

  /// Get applications for a company (all jobs)
  Future<Either<Exception, List<JobApplication>>> getApplicationsByCompany({
    required String companyId,
    ApplicationStatus? status,
    String? searchQuery,
  });

  /// Update application status
  Future<Either<Exception, JobApplication>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
    String? updatedBy,
    String? notes,
  });

  /// Get single application
  Future<Either<Exception, JobApplication>> getApplicationById({
    required String applicationId,
  });

  /// Search applications
  Future<Either<Exception, List<JobApplication>>> searchApplications({
    required String query,
    String? companyId,
    String? candidateId,
    ApplicationStatus? status,
  });

  /// Get application statistics
  Future<Either<Exception, Map<String, int>>> getApplicationStats({
    String? companyId,
    String? jobId,
  });

  /// Withdraw application
  Future<Either<Exception, void>> withdrawApplication({
    required String applicationId,
    required String candidateId,
  });
}