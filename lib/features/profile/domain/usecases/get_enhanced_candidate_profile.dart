import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/candidate_profile_extended.dart';
import '../repositories/profile_repository.dart';

class GetEnhancedCandidateProfile implements UseCase<Either<Failure, CandidateProfileExtended>, NoParams> {
  GetEnhancedCandidateProfile(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, CandidateProfileExtended>> call(NoParams params) {
    return repository.getEnhancedCandidateProfile();
  }
}