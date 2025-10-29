import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyRecoveryCodeParams {
  const VerifyRecoveryCodeParams({required this.email, required this.code});

  final String email;
  final String code;
}

class VerifyRecoveryCode implements UseCase<void, VerifyRecoveryCodeParams> {
  VerifyRecoveryCode(this.repository);

  final AuthRepository repository;

  @override
  Future<void> call(VerifyRecoveryCodeParams params) {
    return repository.verifyRecoveryCode(
      email: params.email,
      token: params.code,
    );
  }
}
