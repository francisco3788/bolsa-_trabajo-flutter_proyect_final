import 'package:bolsa_de_trabajo/core/usecases/usecase.dart';
import 'package:bolsa_de_trabajo/features/auth/domain/repositories/auth_repository.dart';

class ResendEmailVerification
    implements UseCase<void, ResendEmailVerificationParams> {
  ResendEmailVerification(this.repository);

  final AuthRepository repository;

  @override
  Future<void> call(ResendEmailVerificationParams params) {
    return repository.resendEmailVerification(
      email: params.email,
      redirectTo: params.redirectTo,
    );
  }
}

class ResendEmailVerificationParams {
  ResendEmailVerificationParams({required this.email, this.redirectTo});

  final String email;
  final String? redirectTo;
}
