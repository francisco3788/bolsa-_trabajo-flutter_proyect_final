import '../../domain/entities/application_entity.dart';

class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.jobId,
    required super.candidateId,
    super.coverLetter,
    required super.status,
    required super.appliedAt,
    required super.updatedAt,
    super.jobTitle,
    super.companyName,
    super.jobLocation,
    super.candidateName,
    super.candidateEmail,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      candidateId: json['candidate_id'] as String,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      jobTitle: json['job_title'] as String?,
      companyName: json['company_name'] as String?,
      jobLocation: json['job_location'] as String?,
      candidateName: json['candidate_name'] as String?,
      candidateEmail: json['candidate_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'candidate_id': candidateId,
      'cover_letter': coverLetter,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'job_id': jobId,
      'candidate_id': candidateId,
      'cover_letter': coverLetter,
      'status': status,
    };
  }

  factory ApplicationModel.fromEntity(ApplicationEntity entity) {
    return ApplicationModel(
      id: entity.id,
      jobId: entity.jobId,
      candidateId: entity.candidateId,
      coverLetter: entity.coverLetter,
      status: entity.status,
      appliedAt: entity.appliedAt,
      updatedAt: entity.updatedAt,
      jobTitle: entity.jobTitle,
      companyName: entity.companyName,
      jobLocation: entity.jobLocation,
      candidateName: entity.candidateName,
      candidateEmail: entity.candidateEmail,
    );
  }
}