import '../../domain/entities/job_application.dart';

class JobApplicationModel extends JobApplication {
  JobApplicationModel({
    required String id,
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
    required String coverLetter,
    required ApplicationStatus status,
    required DateTime appliedAt,
    DateTime? reviewedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? reviewNotes,
    required Map<String, dynamic> additionalData,
    required ApplicationSource source,
  }) : super(
          id: id,
          jobId: jobId,
          candidateId: candidateId,
          candidateName: candidateName,
          candidateEmail: candidateEmail,
          coverLetter: coverLetter,
          status: status,
          appliedAt: appliedAt,
          reviewedAt: reviewedAt,
          acceptedAt: acceptedAt,
          rejectedAt: rejectedAt,
          reviewNotes: reviewNotes,
          additionalData: additionalData,
          source: source,
        );

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      id: map['id'] ?? '',
      jobId: map['job_id'] ?? '',
      candidateId: map['candidate_id'] ?? '',
      candidateName: map['candidate_name'] ?? '',
      candidateEmail: map['candidate_email'] ?? '',
      coverLetter: map['cover_letter'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: DateTime.parse(map['applied_at'] ?? DateTime.now().toIso8601String()),
      reviewedAt: map['reviewed_at'] != null ? DateTime.parse(map['reviewed_at']) : null,
      acceptedAt: map['accepted_at'] != null ? DateTime.parse(map['accepted_at']) : null,
      rejectedAt: map['rejected_at'] != null ? DateTime.parse(map['rejected_at']) : null,
      reviewNotes: map['review_notes'],
      additionalData: map['additional_data'] != null 
          ? Map<String, dynamic>.from(map['additional_data'])
          : {},
      source: ApplicationSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => ApplicationSource.candidate,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'candidate_id': candidateId,
      'candidate_name': candidateName,
      'candidate_email': candidateEmail,
      'cover_letter': coverLetter,
      'status': status.name,
      'applied_at': appliedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'review_notes': reviewNotes,
      'additional_data': additionalData,
      'source': source.name,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}