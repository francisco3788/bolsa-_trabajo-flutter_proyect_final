import 'package:dartz/dartz.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ai_generated_job.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../../constants/ai_texts.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AiRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Exception, List<AiGeneratedJob>>> generateJobs({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.generateJobs(
          searchQuery: searchQuery,
          limit: limit,
          location: location,
          workMode: workMode,
          jobType: jobType,
        );
        return Right(jobs);
      } catch (e) {
        return Left(Exception('${AiTexts.failedToGenerateJobs}: $e'));
      }
    } else {
      return Left(Exception(AiTexts.noInternetConnection));
    }
  }

  @override
  Future<Either<Exception, List<AiGeneratedJob>>> getGeneratedJobs({
    int? limit,
    bool? isActive,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.getGeneratedJobs(
          limit: limit,
          isActive: isActive,
        );
        return Right(jobs);
      } catch (e) {
        return Left(Exception('${AiTexts.failedToGetGeneratedJobs}: $e'));
      }
    } else {
      return Left(Exception(AiTexts.noInternetConnection));
    }
  }

  @override
  Future<Either<Exception, void>> saveGeneratedJobs(
    List<AiGeneratedJob> jobs,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveGeneratedJobs(jobs);
        return const Right(null);
      } catch (e) {
        return Left(Exception('${AiTexts.failedToSaveGeneratedJobs}: $e'));
      }
    } else {
      return Left(Exception(AiTexts.noInternetConnection));
    }
  }

  @override
  Future<Either<Exception, void>> deactivateJob(String jobId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deactivateJob(jobId);
        return const Right(null);
      } catch (e) {
        return Left(Exception('${AiTexts.failedToDeactivateJob}: $e'));
      }
    } else {
      return Left(Exception(AiTexts.noInternetConnection));
    }
  }

  @override
  Future<Either<Exception, List<AiGeneratedJob>>> searchJobs({
    required String query,
    int? limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final jobs = await remoteDataSource.searchJobs(
          query: query,
          limit: limit,
        );
        return Right(jobs);
      } catch (e) {
        return Left(Exception('${AiTexts.failedToSearchJobs}: $e'));
      }
    } else {
      return Left(Exception(AiTexts.noInternetConnection));
    }
  }
}
