import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/company_profile.dart';
import '../entities/candidate_profile_extended.dart';

abstract class ProfileRepository {
  Future<String?> getCurrentRole();
  Future<void> setUserRole(String role);
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  });
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  });
  Future<Either<Failure, CandidateProfile>> getCandidateProfile();
  Future<Either<Failure, CompanyProfile>> getCompanyProfile();
  Future<Either<Failure, CandidateProfileExtended>> getEnhancedCandidateProfile();
  
  // Enhanced company profile methods
  Future<Either<Failure, CompanyProfile>> getEnhancedCompanyProfile();
  Future<Either<Failure, void>> saveEnhancedCompanyProfile(CompanyProfile profile);
  Future<Either<Failure, String>> uploadCompanyLogo(String filePath);
  Future<Either<Failure, String>> uploadCompanyLogoWeb(Uint8List bytes, String fileName, String mimeType);
  Future<Either<Failure, void>> saveEnhancedCandidateProfile(CandidateProfileExtended profile);
  Future<Either<Failure, String>> uploadCandidatePhoto(String filePath);
  Future<Either<Failure, String>> uploadCandidatePhotoWeb(Uint8List bytes, String fileName, String mimeType);
  Future<Either<Failure, String>> uploadCandidateCv(String filePath);
  Future<Either<Failure, String>> uploadCandidateCvWeb(Uint8List bytes, String fileName, String mimeType);
}

class CandidateProfile {
  CandidateProfile({required this.name, required this.location});
  final String name;
  final String location;
}
