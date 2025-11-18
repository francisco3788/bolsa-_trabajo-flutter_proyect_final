import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/roles.dart';
import '../../constants/profile_messages.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/usecases/save_candidate_profile.dart';
import '../../domain/usecases/save_company_profile.dart';
import '../../domain/usecases/set_user_role.dart';

class ChooseRoleController extends GetxController {
  ChooseRoleController({
    required SetUserRole setUserRole,
    required SaveCandidateProfile saveCandidateProfile,
    required SaveCompanyProfile saveCompanyProfile,
    required AuthSessionService sessionService,
  })  : _setUserRole = setUserRole,
        _saveCandidateProfile = saveCandidateProfile,
        _saveCompanyProfile = saveCompanyProfile,
        _sessionService = sessionService;

  final SetUserRole _setUserRole;
  final SaveCandidateProfile _saveCandidateProfile;
  final SaveCompanyProfile _saveCompanyProfile;
  final AuthSessionService _sessionService;

  final selectedRole = RxnString();
  final pendingRole = RxnString();
  final selectingRole = false.obs;
  final savingProfile = false.obs;

  final candidateFormKey = GlobalKey<FormState>();
  final companyFormKey = GlobalKey<FormState>();

  final candidateNameController = TextEditingController();
  final candidateLocationController = TextEditingController();

  final companyNameController = TextEditingController();
  final companySectorController = TextEditingController();
  final companyLocationController = TextEditingController();

  bool get isCandidateSelected => selectedRole.value == Roles.candidate;
  bool get isCompanySelected => selectedRole.value == Roles.company;

  Future<void> selectRole(String role) async {
    if (selectingRole.value) return;

    selectingRole.value = true;
    pendingRole.value = role;
    try {
      await _setUserRole(SetUserRoleParams(role));
      if (role == Roles.candidate) {
        companyNameController.clear();
        companySectorController.clear();
        companyLocationController.clear();
      } else {
        candidateNameController.clear();
        candidateLocationController.clear();
      }
      selectedRole.value = role;
      Get.focusScope?.unfocus();
    } catch (err) {
      _showErrorSnack(_mapError(err));
    } finally {
      selectingRole.value = false;
      pendingRole.value = null;
    }
  }

  Future<void> submitCandidateProfile() async {
    if (savingProfile.value) return;

    final formState = candidateFormKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      return;
    }

    savingProfile.value = true;
    try {
      Get.focusScope?.unfocus();
      await _saveCandidateProfile(
        SaveCandidateProfileParams(
          name: candidateNameController.text.trim(),
          location: candidateLocationController.text.trim(),
        ),
      );
      _sessionService.setRole(Roles.candidate);
      await _sessionService.refreshProfileName();
      _showSuccessSnack(ProfileMessages.profileSaved, ProfileMessages.profileSavedRedirect);
      Get.offAllNamed(AppRoutes.dashboardCandidate);
    } catch (err) {
      _showErrorSnack(_mapError(err));
    } finally {
      savingProfile.value = false;
    }
  }

  Future<void> submitCompanyProfile() async {
    if (savingProfile.value) return;

    final formState = companyFormKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      return;
    }

    savingProfile.value = true;
    try {
      Get.focusScope?.unfocus();
      await _saveCompanyProfile(
        SaveCompanyProfileParams(
          companyName: companyNameController.text.trim(),
          sector: companySectorController.text.trim(),
          location: companyLocationController.text.trim(),
        ),
      );
      _sessionService.setRole(Roles.company);
      await _sessionService.refreshProfileName();
      _showSuccessSnack(
        ProfileMessages.profileSaved,
        ProfileMessages.companyProfileSavedRedirect,
      );
      Get.offAllNamed(AppRoutes.dashboardCompany);
    } catch (err) {
      _showErrorSnack(_mapError(err));
    } finally {
      savingProfile.value = false;
    }
  }

  String? validateRequired(String? value, String fieldLabel) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldLabel es obligatorio.';
    }
    return null;
  }

  void cancelSelection() {
    selectedRole.value = null;
    pendingRole.value = null;
    candidateNameController.clear();
    candidateLocationController.clear();
    companyNameController.clear();
    companySectorController.clear();
    companyLocationController.clear();
  }

  @override
  void onClose() {
    candidateNameController.dispose();
    candidateLocationController.dispose();
    companyNameController.dispose();
    companySectorController.dispose();
    companyLocationController.dispose();
    super.onClose();
  }

  void _showErrorSnack(String message) {
    Get.snackbar(
      ProfileMessages.errorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showSuccessSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _mapError(Object error) {
    if (error is Failure && error.message.isNotEmpty) {
      return error.message;
    }
    return ProfileMessages.errorFallback;
  }
}
