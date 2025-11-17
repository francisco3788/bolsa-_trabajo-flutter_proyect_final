import '../constants/core_texts.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = CoreTexts.httpErrorDefault]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = CoreTexts.noInternetConnection]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = CoreTexts.authenticationError]);
}
