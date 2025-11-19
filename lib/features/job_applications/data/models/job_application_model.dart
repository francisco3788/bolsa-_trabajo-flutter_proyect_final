import '../../domain/entities/job_application.dart';

class JobApplicationModel extends JobApplication {
  JobApplicationModel({
    required String id,
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
    String? resumeUrl,
    String? coverLetter,
    required ApplicationStatus status,
    required ApplicationSource source,
    String? notes,
    required DateTime appliedAt,
    DateTime? statusUpdatedAt,
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          jobId: jobId,
          candidateId: candidateId,
          candidateName: candidateName,
          candidateEmail: candidateEmail,
          candidatePhone: candidatePhone,
          resumeUrl: resumeUrl,
          coverLetter: coverLetter,
          status: status,
          source: source,
          notes: notes,
          appliedAt: appliedAt,
          statusUpdatedAt: statusUpdatedAt,
          metadata: metadata,
        );

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      id: map['id'] ?? '',
      jobId: map['job_id'] ?? '',
      candidateId: map['candidate_id'] ?? '',
      candidateName: map['candidate_name'] ?? '',
      candidateEmail: map['candidate_email'] ?? '',
      candidatePhone: map['candidate_phone'],
      resumeUrl: map['resume_url'],
      coverLetter: map['cover_letter'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      source: ApplicationSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => ApplicationSource.aiGenerated,
      ),
      notes: map['notes'],
      appliedAt: DateTime.parse(map['applied_at'] ?? DateTime.now().toIso8601String()),
      statusUpdatedAt: map['status_updated_at'] != null
          ? DateTime.parse(map['status_updated_at'])
          : null,
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return super.toMap();
  }
}