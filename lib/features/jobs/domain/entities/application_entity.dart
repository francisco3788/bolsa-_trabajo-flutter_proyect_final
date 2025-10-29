class ApplicationEntity {
  final String id;
  final String jobId;
  final String candidateId;
  final String? coverLetter;
  final String status; // 'submitted', 'seen', 'interview', 'rejected', 'hired'
  final DateTime appliedAt;
  final DateTime updatedAt;
  
  // Información adicional del job (para mostrar en listas)
  final String? jobTitle;
  final String? companyName;
  final String? jobLocation;
  
  // Información adicional del candidato (para empresas)
  final String? candidateName;
  final String? candidateEmail;

  const ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.candidateId,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.jobTitle,
    this.companyName,
    this.jobLocation,
    this.candidateName,
    this.candidateEmail,
  });

  ApplicationEntity copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? coverLetter,
    String? status,
    DateTime? appliedAt,
    DateTime? updatedAt,
    String? jobTitle,
    String? companyName,
    String? jobLocation,
    String? candidateName,
    String? candidateEmail,
  }) {
    return ApplicationEntity(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      jobLocation: jobLocation ?? this.jobLocation,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'submitted':
        return 'Enviada';
      case 'seen':
        return 'Vista';
      case 'interview':
        return 'Entrevista';
      case 'rejected':
        return 'Rechazada';
      case 'hired':
        return 'Contratado';
      default:
        return status;
    }
  }

  String get appliedAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(appliedAt);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  bool get isActive => status == 'submitted' || status == 'seen' || status == 'interview';
  bool get isFinalized => status == 'rejected' || status == 'hired';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApplicationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ApplicationEntity(id: $id, jobId: $jobId, status: $status)';
  }
}