import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams(this.email, this.password);
}

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUser(this.repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
