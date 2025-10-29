import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUser(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.logout();
  }
}
