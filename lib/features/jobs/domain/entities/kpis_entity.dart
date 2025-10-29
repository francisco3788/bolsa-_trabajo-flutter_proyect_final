class KpisEntity {
  final int totalJobs;
  final int totalApplications;
  final int totalInterviews;
  final int? activeJobs;
  final int? pendingJobs;
  final int? closedJobs;
  final int? savedJobs;

  const KpisEntity({
    required this.totalJobs,
    required this.totalApplications,
    required this.totalInterviews,
    this.activeJobs,
    this.pendingJobs,
    this.closedJobs,
    this.savedJobs,
  });

  KpisEntity copyWith({
    int? totalJobs,
    int? totalApplications,
    int? totalInterviews,
    int? activeJobs,
    int? pendingJobs,
    int? closedJobs,
    int? savedJobs,
  }) {
    return KpisEntity(
      totalJobs: totalJobs ?? this.totalJobs,
      totalApplications: totalApplications ?? this.totalApplications,
      totalInterviews: totalInterviews ?? this.totalInterviews,
      activeJobs: activeJobs ?? this.activeJobs,
      pendingJobs: pendingJobs ?? this.pendingJobs,
      closedJobs: closedJobs ?? this.closedJobs,
      savedJobs: savedJobs ?? this.savedJobs,
    );
  }

  // Factory para KPIs de candidato
  factory KpisEntity.candidate({
    required int availableJobs,
    required int myApplications,
    required int interviews,
    int? savedJobs,
  }) {
    return KpisEntity(
      totalJobs: availableJobs,
      totalApplications: myApplications,
      totalInterviews: interviews,
      savedJobs: savedJobs,
    );
  }

  // Factory para KPIs de empresa
  factory KpisEntity.company({
    required int myJobs,
    required int totalApplications,
    required int interviews,
    int? activeJobs,
    int? pendingJobs,
    int? closedJobs,
  }) {
    return KpisEntity(
      totalJobs: myJobs,
      totalApplications: totalApplications,
      totalInterviews: interviews,
      activeJobs: activeJobs,
      pendingJobs: pendingJobs,
      closedJobs: closedJobs,
    );
  }

  @override
  String toString() {
    return 'KpisEntity(totalJobs: $totalJobs, totalApplications: $totalApplications, totalInterviews: $totalInterviews)';
  }
}