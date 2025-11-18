class CandidateLanguage {
  CandidateLanguage({required this.name, required this.level});
  final String name;
  final String level;

  Map<String, dynamic> toMap() => {
        'name': name,
        'level': level,
      };

  static CandidateLanguage fromMap(Map<String, dynamic> map) => CandidateLanguage(
        name: map['name'] ?? '',
        level: map['level'] ?? '',
      );
}

class CandidateProfileExtended {
  CandidateProfileExtended({
    this.name,
    this.location,
    this.photoUrl,
    this.bio,
    this.yearsExperience,
    this.educationLevel,
    this.employmentStatus,
    this.skills,
    this.languages,
    this.cvUrl,
    this.portfolioUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.salaryExpectation,
    this.workType,
    this.availability,
    this.interests,
    this.preferredLocations,
  });

  final String? name;
  final String? location;
  final String? photoUrl;
  final String? bio;
  final int? yearsExperience;
  final String? educationLevel;
  final String? employmentStatus;
  final List<String>? skills;
  final List<CandidateLanguage>? languages;
  final String? cvUrl;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? salaryExpectation;
  final String? workType;
  final String? availability;
  final List<String>? interests;
  final List<String>? preferredLocations;

  Map<String, dynamic> toMap() => {
        'name': name,
        'location': location,
        'photo_url': photoUrl,
        'bio': bio,
        'years_experience': yearsExperience,
        'education_level': educationLevel,
        'employment_status': employmentStatus,
        'skills': skills,
        'languages': languages?.map((e) => e.toMap()).toList(),
        'cv_url': cvUrl,
        'portfolio_url': portfolioUrl,
        'linkedin_url': linkedinUrl,
        'github_url': githubUrl,
        'salary_expectation': salaryExpectation,
        'work_type': workType,
        'availability': availability,
        'interests': interests,
        'preferred_locations': preferredLocations,
      };

  static CandidateProfileExtended fromMap(Map<String, dynamic> map) => CandidateProfileExtended(
        name: map['name'] as String?,
        location: map['location'] as String?,
        photoUrl: map['photo_url'] as String?,
        bio: map['bio'] as String?,
        yearsExperience: map['years_experience'] as int?,
        educationLevel: map['education_level'] as String?,
        employmentStatus: map['employment_status'] as String?,
        skills: (map['skills'] as List?)?.map((e) => e.toString()).toList(),
        languages: (map['languages'] as List?)
            ?.map((e) => CandidateLanguage.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        cvUrl: map['cv_url'] as String?,
        portfolioUrl: map['portfolio_url'] as String?,
        linkedinUrl: map['linkedin_url'] as String?,
        githubUrl: map['github_url'] as String?,
        salaryExpectation: map['salary_expectation'] as String?,
        workType: map['work_type'] as String?,
        availability: map['availability'] as String?,
        interests: (map['interests'] as List?)?.map((e) => e.toString()).toList(),
        preferredLocations:
            (map['preferred_locations'] as List?)?.map((e) => e.toString()).toList(),
      );
}