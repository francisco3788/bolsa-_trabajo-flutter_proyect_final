import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetCurrentRole implements UseCase<String?, NoParams> {
  GetCurrentRole(this.repository);

  final ProfileRepository repository;

  @override
  Future<String?> call(NoParams params) {
    return repository.getCurrentRole();
  }
}
