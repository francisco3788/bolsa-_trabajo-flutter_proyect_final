import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.companyId,
    required super.title,
    required super.description,
    required super.companyName,
    required super.location,
    required super.workMode,
    required super.jobType,
    super.salaryMin,
    super.salaryMax,
    super.currency = 'USD',
    super.skills = const [],
    super.requirements,
    super.benefits,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.totalApplications,
    super.newApplications,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      companyName: json['company_name'] as String,
      location: json['location'] as String,
      workMode: json['work_mode'] as String,
      jobType: json['job_type'] as String,
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      currency: json['currency'] as String? ?? 'USD',
      skills: _parseSkills(json['skills']),
      requirements: json['requirements'] as String?,
      benefits: json['benefits'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalApplications: json['total_applications'] as int?,
      newApplications: json['new_applications'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
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
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'company_id': companyId,
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
      'status': status,
    };
  }

  static List<String> _parseSkills(dynamic skillsData) {
    if (skillsData == null) return [];
    if (skillsData is List) {
      return skillsData.map((e) => e.toString()).toList();
    }
    if (skillsData is String) {
      // Handle PostgreSQL array format: {skill1,skill2,skill3}
      if (skillsData.startsWith('{') && skillsData.endsWith('}')) {
        final content = skillsData.substring(1, skillsData.length - 1);
        if (content.isEmpty) return [];
        return content.split(',').map((e) => e.trim()).toList();
      }
      return [skillsData];
    }
    return [];
  }

  factory JobModel.fromEntity(JobEntity entity) {
    return JobModel(
      id: entity.id,
      companyId: entity.companyId,
      title: entity.title,
      description: entity.description,
      companyName: entity.companyName,
      location: entity.location,
      workMode: entity.workMode,
      jobType: entity.jobType,
      salaryMin: entity.salaryMin,
      salaryMax: entity.salaryMax,
      currency: entity.currency,
      skills: entity.skills,
      requirements: entity.requirements,
      benefits: entity.benefits,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      totalApplications: entity.totalApplications,
      newApplications: entity.newApplications,
    );
  }
}