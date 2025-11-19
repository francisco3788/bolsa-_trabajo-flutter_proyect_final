import 'package:equatable/equatable.dart';

class AiGeneratedJob extends Equatable {
  final String id;
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
  final double aiConfidenceScore;
  final String aiSearchQuery;
  final DateTime generatedAt;
  final bool isActive;

  const AiGeneratedJob({
    required this.id,
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
    required this.aiConfidenceScore,
    required this.aiSearchQuery,
    required this.generatedAt,
    this.isActive = true,
  });

  AiGeneratedJob copyWith({
    String? id,
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
    double? aiConfidenceScore,
    String? aiSearchQuery,
    DateTime? generatedAt,
    bool? isActive,
  }) {
    return AiGeneratedJob(
      id: id ?? this.id,
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
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      aiSearchQuery: aiSearchQuery ?? this.aiSearchQuery,
      generatedAt: generatedAt ?? this.generatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'ai_confidence_score': aiConfidenceScore,
      'ai_search_query': aiSearchQuery,
      'generated_at': generatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory AiGeneratedJob.fromMap(Map<String, dynamic> map) {
    return AiGeneratedJob(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      companyName: map['company_name'] as String,
      location: map['location'] as String,
      workMode: map['work_mode'] as String,
      jobType: map['job_type'] as String,
      salaryMin: map['salary_min'] as int?,
      salaryMax: map['salary_max'] as int?,
      currency: map['currency'] as String? ?? 'USD',
      skills: List<String>.from(map['skills'] ?? []),
      requirements: map['requirements'] as String?,
      benefits: map['benefits'] as String?,
      aiConfidenceScore: map['ai_confidence_score'] as double,
      aiSearchQuery: map['ai_search_query'] as String,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        companyName,
        location,
        workMode,
        jobType,
        salaryMin,
        salaryMax,
        currency,
        skills,
        requirements,
        benefits,
        aiConfidenceScore,
        aiSearchQuery,
        generatedAt,
        isActive,
      ];
}