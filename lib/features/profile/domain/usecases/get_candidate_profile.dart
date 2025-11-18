import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetCandidateProfile implements UseCase<Either<Failure, CandidateProfile>, NoParams> {
  GetCandidateProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, CandidateProfile>> call(NoParams params) {
    return repository.getCandidateProfile();
  }
}