import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetCompanyProfile implements UseCase<CompanyProfile, NoParams> {
  GetCompanyProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<CompanyProfile> call(NoParams params) {
    return repository.getCompanyProfile();
  }
}