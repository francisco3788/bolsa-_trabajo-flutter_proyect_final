import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class SetUserRoleParams {
  SetUserRoleParams(this.role);
  final String role;
}

class SetUserRole implements UseCase<void, SetUserRoleParams> {
  SetUserRole(this.repository);

  final ProfileRepository repository;

  @override
  Future<void> call(SetUserRoleParams params) {
    return repository.setUserRole(params.role);
  }
}
