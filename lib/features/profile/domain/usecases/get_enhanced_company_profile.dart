import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/company_profile.dart';
import '../repositories/profile_repository.dart';

class GetEnhancedCompanyProfile {
  const GetEnhancedCompanyProfile(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, CompanyProfile>> call() async {
    return await repository.getEnhancedCompanyProfile();
  }
}