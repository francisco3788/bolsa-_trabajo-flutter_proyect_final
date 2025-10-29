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
}
