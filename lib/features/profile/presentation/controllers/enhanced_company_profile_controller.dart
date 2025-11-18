import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/company_profile.dart';
import '../../domain/usecases/get_enhanced_company_profile.dart';
import '../../domain/usecases/save_enhanced_company_profile.dart';
import '../../domain/usecases/upload_company_logo.dart';
import '../../constants/profile_messages.dart';

class EnhancedCompanyProfileController extends GetxController {
  EnhancedCompanyProfileController({
    required this.getEnhancedCompanyProfile,
    required this.saveEnhancedCompanyProfile,
    required this.uploadCompanyLogo,
  });

  final GetEnhancedCompanyProfile getEnhancedCompanyProfile;
  final SaveEnhancedCompanyProfile saveEnhancedCompanyProfile;
  final UploadCompanyLogo uploadCompanyLogo;

  // Form keys
  final companyFormKey = GlobalKey<FormState>();

  // Controllers
  final companyNameController = TextEditingController();
  final companySectorController = TextEditingController();
  final companyLocationController = TextEditingController();
  final companyWebsiteController = TextEditingController();
  final companyFoundedController = TextEditingController();
  final companyDescriptionController = TextEditingController();
  final companyCultureController = TextEditingController();
  final companyContactPersonController = TextEditingController();
  final companyContactEmailController = TextEditingController();
  final companyContactPhoneController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyWorkScheduleController = TextEditingController();
  final companyLinkedinController = TextEditingController();
  final companyTwitterController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingLogo = false.obs;
  final logoUrl = ''.obs;
  final companySize = Rx<CompanySize?>(null);
  final remotePolicy = Rx<RemoteWorkPolicy?>(null);
  final benefits = <String>[].obs;
  final benefitController = TextEditingController();

  // Messages
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompanyProfile();
  }

  @override
  void onClose() {
    // Dispose all controllers
    companyNameController.dispose();
    companySectorController.dispose();
    companyLocationController.dispose();
    companyWebsiteController.dispose();
    companyFoundedController.dispose();
    companyDescriptionController.dispose();
    companyCultureController.dispose();
    companyContactPersonController.dispose();
    companyContactEmailController.dispose();
    companyContactPhoneController.dispose();
    companyAddressController.dispose();
    companyWorkScheduleController.dispose();
    companyLinkedinController.dispose();
    companyTwitterController.dispose();
    benefitController.dispose();
    super.onClose();
  }

  Future<void> loadCompanyProfile() async {
    isLoading(true);
    errorMessage('');
    
    final result = await getEnhancedCompanyProfile();
    result.fold(
      (failure) {
        errorMessage(failure.message);
        isLoading(false);
      },
      (profile) {
        _populateFormFields(profile);
        isLoading(false);
      },
    );
  }

  void _populateFormFields(CompanyProfile profile) {
    companyNameController.text = profile.companyName ?? '';
    companySectorController.text = profile.sector ?? '';
    companyLocationController.text = profile.location ?? '';
    companyWebsiteController.text = profile.website ?? '';
    companyFoundedController.text = profile.foundedYear?.toString() ?? '';
    companyDescriptionController.text = profile.description ?? '';
    companyCultureController.text = profile.culture ?? '';
    companyContactPersonController.text = profile.contactPerson ?? '';
    companyContactEmailController.text = profile.contactEmail ?? '';
    companyContactPhoneController.text = profile.contactPhone ?? '';
    companyAddressController.text = profile.address ?? '';
    companyWorkScheduleController.text = profile.workSchedule ?? '';
    companyLinkedinController.text = profile.linkedinUrl ?? '';
    companyTwitterController.text = profile.twitterHandle ?? '';
    
    logoUrl(profile.logoUrl ?? '');
    companySize(profile.size);
    remotePolicy(profile.remotePolicy);
    
    if (profile.benefits != null) {
      benefits.assignAll(profile.benefits!);
    }
  }

  Future<void> saveProfile() async {
    if (!companyFormKey.currentState!.validate()) {
      return;
    }

    isSaving(true);
    errorMessage('');
    successMessage('');

    final profile = CompanyProfile(
      companyName: companyNameController.text.trim(),
      sector: companySectorController.text.trim(),
      location: companyLocationController.text.trim(),
      logoUrl: logoUrl.value,
      website: companyWebsiteController.text.trim(),
      size: companySize.value,
      foundedYear: int.tryParse(companyFoundedController.text.trim()),
      description: companyDescriptionController.text.trim(),
      culture: companyCultureController.text.trim(),
      contactPerson: companyContactPersonController.text.trim(),
      contactEmail: companyContactEmailController.text.trim(),
      contactPhone: companyContactPhoneController.text.trim(),
      address: companyAddressController.text.trim(),
      benefits: benefits.toList(),
      workSchedule: companyWorkScheduleController.text.trim(),
      remotePolicy: remotePolicy.value,
      linkedinUrl: companyLinkedinController.text.trim(),
      twitterHandle: companyTwitterController.text.trim(),
    );

    final result = await saveEnhancedCompanyProfile(profile);
    result.fold(
      (failure) {
        errorMessage(failure.message);
        isSaving(false);
      },
      (_) {
        successMessage(ProfileMessages.profileSaved);
        isSaving(false);
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      },
    );
  }

  Future<void> uploadLogoImage(File imageFile) async {
    isUploadingLogo(true);
    errorMessage('');

    final result = await uploadCompanyLogo(imageFile.path);
    result.fold(
      (failure) {
        errorMessage(failure.message);
        isUploadingLogo(false);
      },
      (url) {
        logoUrl(url);
        successMessage(ProfileMessages.companyLogoUploaded);
        isUploadingLogo(false);
      },
    );
  }

  Future<void> uploadLogoImageWeb(Uint8List bytes, String fileName, String mimeType) async {
    isUploadingLogo(true);
    errorMessage('');

    final result = await uploadCompanyLogo.callWeb(bytes, fileName, mimeType);
    result.fold(
      (failure) {
        errorMessage(failure.message);
        isUploadingLogo(false);
      },
      (url) {
        logoUrl(url);
        successMessage(ProfileMessages.companyLogoUploaded);
        isUploadingLogo(false);
      },
    );
  }

  void addBenefit() {
    final benefit = benefitController.text.trim();
    if (benefit.isNotEmpty && !benefits.contains(benefit)) {
      benefits.add(benefit);
      benefitController.clear();
    }
  }

  void removeBenefit(String benefit) {
    benefits.remove(benefit);
  }

  void setCompanySize(CompanySize? size) {
    companySize(size);
  }

  void setRemotePolicy(RemoteWorkPolicy? policy) {
    remotePolicy(policy);
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return ProfileMessages.emailInvalid;
    }
    return null;
  }

  String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final urlRegex = RegExp(r'^https?:\/\/.+');
    if (!urlRegex.hasMatch(value.trim())) {
      return ProfileMessages.websiteInvalid;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return ProfileMessages.phoneInvalid;
    }
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final year = int.tryParse(value.trim());
    if (year == null || year < 1800 || year > DateTime.now().year) {
      return ProfileMessages.yearInvalid;
    }
    return null;
  }
}