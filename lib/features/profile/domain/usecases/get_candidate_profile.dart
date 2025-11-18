import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetCandidateProfile implements UseCase<CandidateProfile, NoParams> {
  GetCandidateProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<CandidateProfile> call(NoParams params) {
    return repository.getCandidateProfile();
  }
}