class JobEntity {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final String companyName;
  final String location;
  final String workMode; // 'remote', 'hybrid', 'onsite'
  final String jobType; // 'full_time', 'part_time', 'contract', 'internship'
  final int? salaryMin;
  final int? salaryMax;
  final String currency;
  final List<String> skills;
  final String? requirements;
  final String? benefits;
  final String status; // 'active', 'pending', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalApplications;
  final int? newApplications;

  const JobEntity({
    required this.id,
    required this.companyId,
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
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.totalApplications,
    this.newApplications,
  });

  JobEntity copyWith({
    String? id,
    String? companyId,
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
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalApplications,
    int? newApplications,
  }) {
    return JobEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalApplications: totalApplications ?? this.totalApplications,
      newApplications: newApplications ?? this.newApplications,
    );
  }

  String get salaryRange {
    if (salaryMin == null && salaryMax == null) return '';
    if (salaryMin == null) return 'Hasta $salaryMax $currency';
    if (salaryMax == null) return 'Desde $salaryMin $currency';
    return '$salaryMin - $salaryMax $currency';
  }

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Salario a convenir';
    if (salaryMin == null) return 'Hasta $salaryMax $currency';
    if (salaryMax == null) return 'Desde $salaryMin $currency';
    return '$salaryMin - $salaryMax $currency';
  }

  String get workModeDisplay {
    switch (workMode) {
      case 'remote':
        return 'Remoto';
      case 'hybrid':
        return 'Híbrido';
      case 'onsite':
        return 'Presencial';
      default:
        return workMode;
    }
  }

  String get jobTypeDisplay {
    switch (jobType) {
      case 'full_time':
        return 'Tiempo completo';
      case 'part_time':
        return 'Tiempo parcial';
      case 'contract':
        return 'Contrato';
      case 'internship':
        return 'Prácticas';
      default:
        return jobType;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'pending':
        return 'Pendiente';
      case 'closed':
        return 'Cerrado';
      default:
        return status;
    }
  }

  String get createdAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Hace un momento';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'JobEntity(id: $id, title: $title, companyName: $companyName, status: $status)';
  }
}