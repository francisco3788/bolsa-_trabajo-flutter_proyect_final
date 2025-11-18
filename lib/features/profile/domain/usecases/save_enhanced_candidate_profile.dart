import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/candidate_profile_extended.dart';
import '../repositories/profile_repository.dart';

class SaveEnhancedCandidateProfile {
  SaveEnhancedCandidateProfile(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, void>> call(CandidateProfileExtended params) async {
    return await repository.saveEnhancedCandidateProfile(params);
  }
}