import 'package:dartz/dartz.dart';
import 'dart:typed_data';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class UploadCompanyLogo {
  const UploadCompanyLogo(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, String>> call(String filePath) async {
    return await repository.uploadCompanyLogo(filePath);
  }

  Future<Either<Failure, String>> callWeb(Uint8List bytes, String fileName, String mimeType) async {
    return await repository.uploadCompanyLogoWeb(bytes, fileName, mimeType);
  }
}