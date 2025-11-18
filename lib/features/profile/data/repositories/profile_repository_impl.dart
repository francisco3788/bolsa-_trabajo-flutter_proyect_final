import 'package:bolsa_de_trabajo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:bolsa_de_trabajo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remote);

  final ProfileRemoteDataSource remote;

  @override
  Future<String?> getCurrentRole() {
    return remote.getCurrentRole();
  }

  @override
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  }) {
    return remote.saveCandidateProfile(name: name, location: location);
  }

  @override
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  }) {
    return remote.saveCompanyProfile(
      companyName: companyName,
      sector: sector,
      location: location,
    );
  }

  @override
  Future<void> setUserRole(String role) {
    return remote.setUserRole(role);
  }

  @override
  Future<CandidateProfile> getCandidateProfile() async {
    final data = await remote.getCandidateProfile();
    return CandidateProfile(
      name: data['name'] ?? '',
      location: data['location'] ?? '',
    );
  }

  @override
  Future<CompanyProfile> getCompanyProfile() async {
    final data = await remote.getCompanyProfile();
    return CompanyProfile(
      companyName: data['company_name'] ?? '',
      sector: data['sector'] ?? '',
      location: data['location'] ?? '',
    );
  }
}
