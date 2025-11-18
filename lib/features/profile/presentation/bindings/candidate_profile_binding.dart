import 'package:get/get.dart';

import '../../domain/usecases/get_candidate_profile.dart';
import '../../domain/usecases/save_candidate_profile.dart';
import '../../domain/usecases/get_enhanced_candidate_profile.dart';
import '../../domain/usecases/save_enhanced_candidate_profile.dart';
import '../../domain/usecases/upload_candidate_photo.dart';
import '../../domain/usecases/upload_candidate_cv.dart';
import '../controllers/candidate_profile_controller.dart';

class CandidateProfileBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetCandidateProfile>()) {
      Get.put<GetCandidateProfile>(GetCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<SaveCandidateProfile>()) {
      Get.put<SaveCandidateProfile>(SaveCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<GetEnhancedCandidateProfile>()) {
      Get.put<GetEnhancedCandidateProfile>(GetEnhancedCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<SaveEnhancedCandidateProfile>()) {
      Get.put<SaveEnhancedCandidateProfile>(SaveEnhancedCandidateProfile(Get.find()));
    }
    if (!Get.isRegistered<UploadCandidatePhoto>()) {
      Get.put<UploadCandidatePhoto>(UploadCandidatePhoto(Get.find()));
    }
    if (!Get.isRegistered<UploadCandidateCv>()) {
      Get.put<UploadCandidateCv>(UploadCandidateCv(Get.find()));
    }

    Get.lazyPut<CandidateProfileController>(() => CandidateProfileController(
          getCandidateProfile: Get.find<GetCandidateProfile>(),
          saveCandidateProfile: Get.find<SaveCandidateProfile>(),
          getEnhancedCandidateProfile: Get.find<GetEnhancedCandidateProfile>(),
          saveEnhancedCandidateProfile: Get.find<SaveEnhancedCandidateProfile>(),
          uploadCandidatePhoto: Get.find<UploadCandidatePhoto>(),
          uploadCandidateCv: Get.find<UploadCandidateCv>(),
        ));
  }
}