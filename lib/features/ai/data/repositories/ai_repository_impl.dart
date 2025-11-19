import 'package:dartz/dartz.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ai_generated_job.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AiRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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
        return Left(Exception('Failed to generate jobs: $e'));
      }
    } else {
      return Left(Exception('No internet connection'));
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
        return Left(Exception('Failed to get generated jobs: $e'));
      }
    } else {
      return Left(Exception('No internet connection'));
    }
  }

  @override
  Future<Either<Exception, void>> saveGeneratedJobs(List<AiGeneratedJob> jobs) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveGeneratedJobs(jobs);
        return const Right(null);
      } catch (e) {
        return Left(Exception('Failed to save generated jobs: $e'));
      }
    } else {
      return Left(Exception('No internet connection'));
    }
  }

  @override
  Future<Either<Exception, void>> deactivateJob(String jobId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deactivateJob(jobId);
        return const Right(null);
      } catch (e) {
        return Left(Exception('Failed to deactivate job: $e'));
      }
    } else {
      return Left(Exception('No internet connection'));
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
        return Left(Exception('Failed to search jobs: $e'));
      }
    } else {
      return Left(Exception('No internet connection'));
    }
  }
}