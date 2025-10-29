import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class SaveCompanyProfileParams {
  SaveCompanyProfileParams({
    required this.companyName,
    required this.sector,
    required this.location,
  });

  final String companyName;
  final String sector;
  final String location;
}

class SaveCompanyProfile
    implements UseCase<void, SaveCompanyProfileParams> {
  SaveCompanyProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<void> call(SaveCompanyProfileParams params) {
    return repository.saveCompanyProfile(
      companyName: params.companyName,
      sector: params.sector,
      location: params.location,
    );
  }
}
