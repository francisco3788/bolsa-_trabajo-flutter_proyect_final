import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

class ApplyToJob {
  final JobApplicationRepository repository;

  ApplyToJob(this.repository);

  Future<Either<Exception, JobApplication>> call(ApplyToJobParams params) async {
    return await repository.applyToJob(
      jobId: params.jobId,
      candidateId: params.candidateId,
      candidateName: params.candidateName,
      candidateEmail: params.candidateEmail,
      candidatePhone: params.candidatePhone,
      resumeUrl: params.resumeUrl,
      coverLetter: params.coverLetter,
      source: params.source,
    );
  }
}

class ApplyToJobParams extends Equatable {
  final String jobId;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String? candidatePhone;
  final String? resumeUrl;
  final String? coverLetter;
  final ApplicationSource source;

  const ApplyToJobParams({
    required this.jobId,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    this.candidatePhone,
    this.resumeUrl,
    this.coverLetter,
    this.source = ApplicationSource.aiGenerated,
  });

  @override
  List<Object?> get props => [
        jobId,
        candidateId,
        candidateName,
        candidateEmail,
        candidatePhone,
        resumeUrl,
        coverLetter,
        source,
      ];
}