import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/company_profile.dart';
import '../repositories/profile_repository.dart';

class SaveEnhancedCompanyProfile {
  const SaveEnhancedCompanyProfile(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, void>> call(CompanyProfile profile) async {
    return await repository.saveEnhancedCompanyProfile(profile);
  }
}