import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class UploadCandidateCv {
  UploadCandidateCv(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, String>> call(String filePath) {
    return repository.uploadCandidateCv(filePath);
  }

  Future<Either<Failure, String>> callWeb(Uint8List bytes, String fileName, String mimeType) {
    return repository.uploadCandidateCvWeb(bytes, fileName, mimeType);
  }
}