import 'package:equatable/equatable.dart';

class CompanyProfile extends Equatable {
  final String? companyName;
  final String? sector;
  final String? location;
  final String? logoUrl;
  final String? website;
  final CompanySize? size;
  final int? foundedYear;
  final String? description;
  final String? culture;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final List<String>? benefits;
  final String? workSchedule;
  final RemoteWorkPolicy? remotePolicy;
  final String? linkedinUrl;
  final String? twitterHandle;

  const CompanyProfile({
    this.companyName,
    this.sector,
    this.location,
    this.logoUrl,
    this.website,
    this.size,
    this.foundedYear,
    this.description,
    this.culture,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.benefits,
    this.workSchedule,
    this.remotePolicy,
    this.linkedinUrl,
    this.twitterHandle,
  });

  CompanyProfile copyWith({
    String? companyName,
    String? sector,
    String? location,
    String? logoUrl,
    String? website,
    CompanySize? size,
    int? foundedYear,
    String? description,
    String? culture,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? address,
    List<String>? benefits,
    String? workSchedule,
    RemoteWorkPolicy? remotePolicy,
    String? linkedinUrl,
    String? twitterHandle,
  }) {
    return CompanyProfile(
      companyName: companyName ?? this.companyName,
      sector: sector ?? this.sector,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      size: size ?? this.size,
      foundedYear: foundedYear ?? this.foundedYear,
      description: description ?? this.description,
      culture: culture ?? this.culture,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      benefits: benefits ?? this.benefits,
      workSchedule: workSchedule ?? this.workSchedule,
      remotePolicy: remotePolicy ?? this.remotePolicy,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_name': companyName,
      'sector': sector,
      'location': location,
      'logo_url': logoUrl,
      'website': website,
      'size': size?.name,
      'founded_year': foundedYear,
      'description': description,
      'culture': culture,
      'contact_person': contactPerson,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'address': address,
      'benefits': benefits,
      'work_schedule': workSchedule,
      'remote_policy': remotePolicy?.name,
      'linkedin_url': linkedinUrl,
      'twitter_handle': twitterHandle,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      companyName: map['company_name'] as String?,
      sector: map['sector'] as String?,
      location: map['location'] as String?,
      logoUrl: map['logo_url'] as String?,
      website: map['website'] as String?,
      size: map['size'] != null ? CompanySize.values.firstWhere(
        (e) => e.name == map['size'],
        orElse: () => CompanySize.small,
      ) : null,
      foundedYear: map['founded_year'] as int?,
      description: map['description'] as String?,
      culture: map['culture'] as String?,
      contactPerson: map['contact_person'] as String?,
      contactEmail: map['contact_email'] as String?,
      contactPhone: map['contact_phone'] as String?,
      address: map['address'] as String?,
      benefits: map['benefits'] != null ? List<String>.from(map['benefits']) : null,
      workSchedule: map['work_schedule'] as String?,
      remotePolicy: map['remote_policy'] != null ? RemoteWorkPolicy.values.firstWhere(
        (e) => e.name == map['remote_policy'],
        orElse: () => RemoteWorkPolicy.hybrid,
      ) : null,
      linkedinUrl: map['linkedin_url'] as String?,
      twitterHandle: map['twitter_handle'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        companyName,
        sector,
        location,
        logoUrl,
        website,
        size,
        foundedYear,
        description,
        culture,
        contactPerson,
        contactEmail,
        contactPhone,
        address,
        benefits,
        workSchedule,
        remotePolicy,
        linkedinUrl,
        twitterHandle,
      ];
}

enum CompanySize {
  startup('Startup (1-10 employees)'),
  small('Small (11-50 employees)'),
  medium('Medium (51-200 employees)'),
  large('Large (201-1000 employees)'),
  enterprise('Enterprise (1000+ employees)');

  const CompanySize(this.description);
  final String description;
}

enum RemoteWorkPolicy {
  fullyRemote('Fully Remote'),
  hybrid('Hybrid'),
  officeOnly('Office Only'),
  flexible('Flexible');

  const RemoteWorkPolicy(this.description);
  final String description;
}