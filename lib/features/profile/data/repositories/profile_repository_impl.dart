import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../domain/entities/candidate_profile_extended.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remote);

  final ProfileRemoteDataSource remote;

  @override
  Future<String?> getCurrentRole() {
    return remote.getCurrentRole();
  }

  @override
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  }) {
    return remote.saveCandidateProfile(name: name, location: location);
  }

  @override
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  }) {
    return remote.saveCompanyProfile(
      companyName: companyName,
      sector: sector,
      location: location,
    );
  }

  @override
  Future<void> setUserRole(String role) {
    return remote.setUserRole(role);
  }

  @override
  Future<Either<Failure, CandidateProfile>> getCandidateProfile() async {
    try {
      final data = await remote.getCandidateProfile();
      return Right(CandidateProfile(
        name: data['name'] ?? '',
        location: data['location'] ?? '',
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyProfile>> getCompanyProfile() async {
    try {
      final data = await remote.getCompanyProfile();
      return Right(CompanyProfile(
        companyName: data['company_name'] ?? '',
        sector: data['sector'] ?? '',
        location: data['location'] ?? '',
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyProfile>> getEnhancedCompanyProfile() async {
    try {
      final data = await remote.getEnhancedCompanyProfile();
      return Right(CompanyProfile.fromMap(data));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileExtended>> getEnhancedCandidateProfile() async {
    try {
      final data = await remote.getEnhancedCandidateProfile();
      return Right(CandidateProfileExtended.fromMap(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveEnhancedCompanyProfile(CompanyProfile profile) async {
    try {
      await remote.saveEnhancedCompanyProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveEnhancedCandidateProfile(CandidateProfileExtended profile) async {
    try {
      await remote.saveEnhancedCandidateProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCompanyLogo(String filePath) async {
    try {
      final url = await remote.uploadCompanyLogo(filePath);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload company logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCompanyLogoWeb(Uint8List bytes, String fileName, String mimeType) async {
    try {
      // Delegate to the remote datasource which has the proper implementation
      final url = await remote.uploadCompanyLogoWeb(bytes, fileName, mimeType);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload company logo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCandidatePhoto(String filePath) async {
    try {
      final url = await remote.uploadCandidatePhoto(filePath);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload candidate photo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCandidatePhotoWeb(Uint8List bytes, String fileName, String mimeType) async {
    try {
      final url = await remote.uploadCandidatePhotoWeb(bytes, fileName, mimeType);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload candidate photo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCandidateCv(String filePath) async {
    try {
      final url = await remote.uploadCandidateCv(filePath);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload candidate CV: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCandidateCvWeb(Uint8List bytes, String fileName, String mimeType) async {
    try {
      final url = await remote.uploadCandidateCvWeb(bytes, fileName, mimeType);
      return Right(url);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to upload candidate CV: ${e.toString()}'));
    }
  }
}
