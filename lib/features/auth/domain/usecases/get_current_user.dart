import 'package:bolsa_de_trabajo/core/usecases/usecase.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/entities/user_entity.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  GetCurrentUser({required this.repository});
  final AuthRepository repository;

  @override
  Future<UserEntity?> call(NoParams params) {
    return repository.currentUser();
  }
}
