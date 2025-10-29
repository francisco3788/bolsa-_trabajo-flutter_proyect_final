import '../../domain/entities/kpis_entity.dart';

class KpisModel extends KpisEntity {
  const KpisModel({
    required super.totalJobs,
    required super.totalApplications,
    required super.totalInterviews,
    super.activeJobs,
    super.pendingJobs,
    super.closedJobs,
    super.savedJobs,
  });

  factory KpisModel.fromJson(Map<String, dynamic> json) {
    return KpisModel(
      totalJobs: json['total_jobs'] as int? ?? 0,
      totalApplications: json['total_applications'] as int? ?? 0,
      totalInterviews: json['total_interviews'] as int? ?? 0,
      activeJobs: json['active_jobs'] as int?,
      pendingJobs: json['pending_jobs'] as int?,
      closedJobs: json['closed_jobs'] as int?,
      savedJobs: json['saved_jobs'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_jobs': totalJobs,
      'total_applications': totalApplications,
      'total_interviews': totalInterviews,
      if (activeJobs != null) 'active_jobs': activeJobs,
      if (pendingJobs != null) 'pending_jobs': pendingJobs,
      if (closedJobs != null) 'closed_jobs': closedJobs,
      if (savedJobs != null) 'saved_jobs': savedJobs,
    };
  }

  factory KpisModel.fromEntity(KpisEntity entity) {
    return KpisModel(
      totalJobs: entity.totalJobs,
      totalApplications: entity.totalApplications,
      totalInterviews: entity.totalInterviews,
      activeJobs: entity.activeJobs,
      pendingJobs: entity.pendingJobs,
      closedJobs: entity.closedJobs,
      savedJobs: entity.savedJobs,
    );
  }
}