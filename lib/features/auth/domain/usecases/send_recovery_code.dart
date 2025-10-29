import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendRecoveryCodeParams {
  const SendRecoveryCodeParams(this.email, {this.redirectTo});

  final String email;
  final String? redirectTo;
}

class SendRecoveryCode implements UseCase<void, SendRecoveryCodeParams> {
  SendRecoveryCode(this.repository);

  final AuthRepository repository;

  @override
  Future<void> call(SendRecoveryCodeParams params) {
    return repository.sendRecoveryCode(
      email: params.email,
      redirectTo: params.redirectTo,
    );
  }
}
