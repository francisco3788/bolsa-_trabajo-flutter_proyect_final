import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bolsa_de_trabajo/core/constants/roles.dart';
import 'package:bolsa_de_trabajo/core/services/auth_session_service.dart';
import 'package:bolsa_de_trabajo/features/profile/presentation/bindings/enhanced_company_profile_binding.dart';
import 'package:bolsa_de_trabajo/features/profile/presentation/bindings/candidate_profile_binding.dart';
import 'candidate_profile_page.dart';
import 'enhanced_company_profile_page.dart';
import '../../constants/profile_messages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthSessionService>();
    
    return Obx(() {
      final userRole = authService.role;
      
      if (userRole == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(ProfileMessages.profileTitle),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text(ProfileMessages.loginRequiredPrompt),
          ),
        );
      }
      
      // Show different profile pages based on user role
      if (userRole == Roles.company) {
        // Load company profile dependencies
        if (!Get.isRegistered<EnhancedCompanyProfileBinding>()) {
          EnhancedCompanyProfileBinding().dependencies();
        }
        return const EnhancedCompanyProfilePage();
      } else if (userRole == Roles.candidate) {
        if (!Get.isRegistered<CandidateProfileBinding>()) {
          CandidateProfileBinding().dependencies();
        }
        return const CandidateProfilePage();
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text(ProfileMessages.profileTitle),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text(ProfileMessages.unknownRoleMessage),
          ),
        );
      }
    });
  }
}