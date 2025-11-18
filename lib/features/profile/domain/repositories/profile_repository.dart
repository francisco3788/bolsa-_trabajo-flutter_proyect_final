abstract class ProfileRepository {
  Future<String?> getCurrentRole();
  Future<void> setUserRole(String role);
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  });
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  });
  Future<CandidateProfile> getCandidateProfile();
  Future<CompanyProfile> getCompanyProfile();
}

class CandidateProfile {
  CandidateProfile({required this.name, required this.location});
  final String name;
  final String location;
}

class CompanyProfile {
  CompanyProfile({required this.companyName, required this.sector, required this.location});
  final String companyName;
  final String sector;
  final String location;
}
