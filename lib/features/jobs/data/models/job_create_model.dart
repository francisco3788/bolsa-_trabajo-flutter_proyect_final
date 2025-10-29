class JobCreateModel {
  final String title;
  final String description;
  final String companyName;
  final String location;
  final String workMode;
  final String jobType;
  final int? salaryMin;
  final int? salaryMax;
  final String currency;
  final List<String> skills;
  final String? requirements;
  final String? benefits;

  const JobCreateModel({
    required this.title,
    required this.description,
    required this.companyName,
    required this.location,
    required this.workMode,
    required this.jobType,
    this.salaryMin,
    this.salaryMax,
    this.currency = 'USD',
    this.skills = const [],
    this.requirements,
    this.benefits,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'company_name': companyName,
      'location': location,
      'work_mode': workMode,
      'job_type': jobType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'skills': skills,
      'requirements': requirements,
      'benefits': benefits,
      'status': 'active', // Por defecto activo
    };
  }

  JobCreateModel copyWith({
    String? title,
    String? description,
    String? companyName,
    String? location,
    String? workMode,
    String? jobType,
    int? salaryMin,
    int? salaryMax,
    String? currency,
    List<String>? skills,
    String? requirements,
    String? benefits,
  }) {
    return JobCreateModel(
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      jobType: jobType ?? this.jobType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      currency: currency ?? this.currency,
      skills: skills ?? this.skills,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
    );
  }

  @override
  String toString() {
    return 'JobCreateModel(title: $title, companyName: $companyName, workMode: $workMode)';
  }
}