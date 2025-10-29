import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class SaveCandidateProfileParams {
  SaveCandidateProfileParams({
    required this.name,
    required this.location,
  });

  final String name;
  final String location;
}

class SaveCandidateProfile
    implements UseCase<void, SaveCandidateProfileParams> {
  SaveCandidateProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<void> call(SaveCandidateProfileParams params) {
    return repository.saveCandidateProfile(
      name: params.name,
      location: params.location,
    );
  }
}
