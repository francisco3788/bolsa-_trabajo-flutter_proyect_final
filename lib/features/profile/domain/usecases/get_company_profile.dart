import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/company_profile.dart';
import '../repositories/profile_repository.dart';

class GetCompanyProfile implements UseCase<Either<Failure, CompanyProfile>, NoParams> {
  GetCompanyProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, CompanyProfile>> call(NoParams params) {
    return repository.getCompanyProfile();
  }
}