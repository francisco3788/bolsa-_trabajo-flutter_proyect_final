import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending,
  underReview,
  accepted,
  rejected,
  cancelled,
}

enum ApplicationSource {
  aiGenerated,
  companyPosted,
}

class JobApplication extends Equatable {
  final String id;
  final String jobId;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String? candidatePhone;
  final String? resumeUrl;
  final String? coverLetter;
  final ApplicationStatus status;
  final ApplicationSource source;
  final String? notes;
  final DateTime appliedAt;
  final DateTime? statusUpdatedAt;
  final String? statusUpdatedBy;
  final double? aiMatchScore;
  final Map<String, dynamic>? metadata;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    this.candidatePhone,
    this.resumeUrl,
    this.coverLetter,
    required this.status,
    required this.source,
    this.notes,
    required this.appliedAt,
    this.statusUpdatedAt,
    this.statusUpdatedBy,
    this.aiMatchScore,
    this.metadata,
  });

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? candidateName,
    String? candidateEmail,
    String? candidatePhone,
    String? resumeUrl,
    String? coverLetter,
    ApplicationStatus? status,
    ApplicationSource? source,
    String? notes,
    DateTime? appliedAt,
    DateTime? statusUpdatedAt,
    String? statusUpdatedBy,
    double? aiMatchScore,
    Map<String, dynamic>? metadata,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
      candidatePhone: candidatePhone ?? this.candidatePhone,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      appliedAt: appliedAt ?? this.appliedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusUpdatedBy: statusUpdatedBy ?? this.statusUpdatedBy,
      aiMatchScore: aiMatchScore ?? this.aiMatchScore,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'candidate_id': candidateId,
      'candidate_name': candidateName,
      'candidate_email': candidateEmail,
      'candidate_phone': candidatePhone,
      'resume_url': resumeUrl,
      'cover_letter': coverLetter,
      'status': status.name,
      'source': source.name,
      'notes': notes,
      'applied_at': appliedAt.toIso8601String(),
      'status_updated_at': statusUpdatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'],
      jobId: map['job_id'],
      candidateId: map['candidate_id'],
      candidateName: map['candidate_name'],
      candidateEmail: map['candidate_email'],
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
      appliedAt: DateTime.parse(map['applied_at']),
      statusUpdatedAt: map['status_updated_at'] != null 
          ? DateTime.parse(map['status_updated_at']) 
          : null,
      statusUpdatedBy: map['status_updated_by'],
      aiMatchScore: map['ai_match_score']?.toDouble(),
      metadata: map['metadata'],
    );
  }

  String get statusDisplayName {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusColor {
    switch (status) {
      case ApplicationStatus.pending:
        return '#FFA500'; // Orange
      case ApplicationStatus.underReview:
        return '#007BFF'; // Blue
      case ApplicationStatus.accepted:
        return '#28A745'; // Green
      case ApplicationStatus.rejected:
        return '#DC3545'; // Red
      case ApplicationStatus.cancelled:
        return '#6C757D'; // Gray
    }
  }

  bool get isEditable {
    return status == ApplicationStatus.pending || 
           status == ApplicationStatus.underReview;
  }

  bool get isFinalized {
    return status == ApplicationStatus.accepted || 
           status == ApplicationStatus.rejected ||
           status == ApplicationStatus.cancelled;
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        candidateId,
        candidateName,
        candidateEmail,
        candidatePhone,
        resumeUrl,
        coverLetter,
        status,
        source,
        notes,
        appliedAt,
        statusUpdatedAt,
        statusUpdatedBy,
        aiMatchScore,
        metadata,
      ];
}