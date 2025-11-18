import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../domain/usecases/get_candidate_profile.dart';
import '../../domain/usecases/save_candidate_profile.dart';
import '../../domain/usecases/get_enhanced_candidate_profile.dart';
import '../../domain/usecases/save_enhanced_candidate_profile.dart';
import '../../domain/usecases/upload_candidate_photo.dart';
import '../../domain/usecases/upload_candidate_cv.dart';
import '../../domain/entities/candidate_profile_extended.dart';
import '../../constants/profile_messages.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:bolsa_de_trabajo/routes/app_routes.dart';

class CandidateProfileController extends GetxController {
  CandidateProfileController({
    required this.getCandidateProfile,
    required this.saveCandidateProfile,
    required this.getEnhancedCandidateProfile,
    required this.saveEnhancedCandidateProfile,
    required this.uploadCandidatePhoto,
    required this.uploadCandidateCv,
  });

  final GetCandidateProfile getCandidateProfile;
  final SaveCandidateProfile saveCandidateProfile;
  final GetEnhancedCandidateProfile getEnhancedCandidateProfile;
  final SaveEnhancedCandidateProfile saveEnhancedCandidateProfile;
  final UploadCandidatePhoto uploadCandidatePhoto;
  final UploadCandidateCv uploadCandidateCv;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final skillController = TextEditingController();
  final bioController = TextEditingController();
  final yearsExperienceController = TextEditingController();
  final cvLinkController = TextEditingController();
  final portfolioController = TextEditingController();
  final linkedinController = TextEditingController();
  final githubController = TextEditingController();
  final salaryController = TextEditingController();
  final preferredLocationController = TextEditingController();
  final languageNameController = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingPhoto = false.obs;
  final isUploadingCv = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final photoUrl = ''.obs;
  final educationLevel = RxString('');
  final employmentStatus = RxString('');
  final workType = RxString('');
  final availability = RxString('');
  final languageLevel = RxString('');
  final skills = <String>[].obs;
  final languages = <CandidateLanguage>[].obs;
  final interests = <String>{}.obs;
  final preferredLocations = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadEnhancedProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    skillController.dispose();
    bioController.dispose();
    yearsExperienceController.dispose();
    cvLinkController.dispose();
    portfolioController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    salaryController.dispose();
    preferredLocationController.dispose();
    languageNameController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading(true);
    errorMessage('');

    final result = await getCandidateProfile(const NoParams());
    result.fold(
      (failure) {
        errorMessage(failure.message);
        isLoading(false);
      },
      (profile) {
        nameController.text = profile.name;
        locationController.text = profile.location;
        isLoading(false);
      },
    );
  }

  Future<void> loadEnhancedProfile() async {
    isLoading(true);
    errorMessage('');

    final result = await getEnhancedCandidateProfile(const NoParams());
    result.fold(
      (failure) {
        isLoading(false);
      },
      (profile) {
        photoUrl(profile.photoUrl ?? '');
        bioController.text = profile.bio ?? '';
        yearsExperienceController.text = profile.yearsExperience?.toString() ?? '';
        educationLevel(profile.educationLevel ?? '');
        employmentStatus(profile.employmentStatus ?? '');
        skills.assignAll(profile.skills ?? []);
        languages.assignAll(profile.languages ?? []);
        cvLinkController.text = profile.cvUrl ?? '';
        portfolioController.text = profile.portfolioUrl ?? '';
        linkedinController.text = profile.linkedinUrl ?? '';
        githubController.text = profile.githubUrl ?? '';
        salaryController.text = profile.salaryExpectation ?? '';
        workType(profile.workType ?? '');
        availability(profile.availability ?? '');
        interests.assignAll((profile.interests ?? []).toSet());
        preferredLocations.assignAll(profile.preferredLocations ?? []);
        isLoading(false);
      },
    );
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSaving(true);
    errorMessage('');
    successMessage('');

    final params = SaveCandidateProfileParams(
      name: nameController.text.trim(),
      location: locationController.text.trim(),
    );

    try {
      await saveCandidateProfile(params);
      final extended = CandidateProfileExtended(
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        photoUrl: photoUrl.value,
        bio: bioController.text.trim(),
        yearsExperience: int.tryParse(yearsExperienceController.text.trim()),
        educationLevel: educationLevel.value.isEmpty ? null : educationLevel.value,
        employmentStatus: employmentStatus.value.isEmpty ? null : employmentStatus.value,
        skills: skills.toList(),
        languages: languages.toList(),
        cvUrl: cvLinkController.text.trim().isEmpty ? null : cvLinkController.text.trim(),
        portfolioUrl: portfolioController.text.trim().isEmpty ? null : portfolioController.text.trim(),
        linkedinUrl: linkedinController.text.trim().isEmpty ? null : linkedinController.text.trim(),
        githubUrl: githubController.text.trim().isEmpty ? null : githubController.text.trim(),
        salaryExpectation: salaryController.text.trim().isEmpty ? null : salaryController.text.trim(),
        workType: workType.value.isEmpty ? null : workType.value,
        availability: availability.value.isEmpty ? null : availability.value,
        interests: interests.toList(),
        preferredLocations: preferredLocations.toList(),
      );
      final enhancedResult = await saveEnhancedCandidateProfile.call(extended);
      enhancedResult.fold(
        (failure) {
          errorMessage(failure.message);
        },
        (_) {
          successMessage(ProfileMessages.profileSaved);
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAllNamed(AppRoutes.dashboardCandidate);
          });
        },
      );
    } catch (e) {
      errorMessage(ProfileMessages.errorFallback);
    } finally {
      isSaving(false);
    }
  }

  Future<void> pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    isUploadingPhoto(true);
    errorMessage('');
    try {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final result = await uploadCandidatePhoto.callWeb(bytes, image.name, image.mimeType ?? 'image/jpeg');
        result.fold(
          (failure) => errorMessage(failure.message),
          (url) => photoUrl(url),
        );
      } else {
        if (image.path.isNotEmpty) {
          final result = await uploadCandidatePhoto(image.path);
          result.fold(
            (failure) => errorMessage(failure.message),
            (url) => photoUrl(url),
          );
        }
      }
    } finally {
      isUploadingPhoto(false);
    }
  }

  Future<void> pickAndUploadCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result == null) return;
    isUploadingCv(true);
    errorMessage('');
    try {
      if (kIsWeb) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final upload = await uploadCandidateCv.callWeb(bytes, file.name, 'application/pdf');
          upload.fold(
            (failure) => errorMessage(failure.message),
            (url) => cvLinkController.text = url,
          );
        }
      } else {
        final path = result.files.first.path;
        if (path != null && path.isNotEmpty) {
          final upload = await uploadCandidateCv.call(path);
          upload.fold(
            (failure) => errorMessage(failure.message),
            (url) => cvLinkController.text = url,
          );
        }
      }
    } finally {
      isUploadingCv(false);
    }
  }

  void addSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !skills.contains(s)) {
      skills.add(s);
    }
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  void addLanguage() {
    final name = languageNameController.text.trim();
    final level = languageLevel.value.trim();
    if (name.isNotEmpty && level.isNotEmpty) {
      languages.add(CandidateLanguage(name: name, level: level));
      languageNameController.clear();
      languageLevel('');
    }
  }

  void removeLanguage(CandidateLanguage lang) {
    languages.removeWhere((l) => l.name == lang.name && l.level == lang.level);
  }

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  void addPreferredLocation() {
    final loc = preferredLocationController.text.trim();
    if (loc.isNotEmpty) {
      preferredLocations.add(loc);
      preferredLocationController.clear();
    }
  }

  void removePreferredLocation(String loc) {
    preferredLocations.remove(loc);
  }
}