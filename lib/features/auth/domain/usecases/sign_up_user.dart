import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String? name;
  SignUpParams({required this.email, required this.password, this.name});
}

class SignUpUser implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUpUser(this.repository);

  @override
  Future<UserEntity> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
