import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordParams {
  const UpdatePasswordParams(this.newPassword);

  final String newPassword;
}

class UpdatePassword implements UseCase<void, UpdatePasswordParams> {
  UpdatePassword(this.repository);

  final AuthRepository repository;

  @override
  Future<void> call(UpdatePasswordParams params) {
    return repository.updatePassword(newPassword: params.newPassword);
  }
}
