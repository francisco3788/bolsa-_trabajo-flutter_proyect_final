import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/candidate_profile_controller.dart';
import '../../constants/profile_messages.dart';

class CandidateProfilePage extends GetView<CandidateProfileController> {
  const CandidateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ProfileMessages.candidateProfileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: controller.isSaving.value ? null : controller.saveProfile,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save, size: 18),
                  label: Text(controller.isSaving.value ? ProfileTexts.savingLabel : ProfileTexts.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.02),
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(context),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileMessages.personalInformation, Icons.person, [
                    _buildStyledTextField(
                      context,
                      controller.nameController,
                      ProfileTexts.candidateNameLabel,
                      ProfileTexts.candidateNameHint,
                      Icons.person,
                      (value) => controller.validateRequired(value, ProfileTexts.candidateNameLabel),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.locationController,
                      ProfileTexts.candidateLocationLabel,
                      ProfileTexts.candidateLocationHint,
                      Icons.location_on,
                      (value) => controller.validateRequired(value, ProfileTexts.candidateLocationLabel),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.bioController,
                      ProfileTexts.candidateBioLabel,
                      ProfileTexts.candidateBioHint,
                      Icons.description,
                      null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.yearsExperienceController,
                      ProfileTexts.candidateYearsExperienceLabel,
                      ProfileTexts.candidateYearsExperienceHint,
                      Icons.timeline,
                      null,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => _buildDropdown<String>(
                          context,
                          controller.educationLevel.value.isEmpty ? null : controller.educationLevel.value,
                          ProfileTexts.candidateEducationLevelLabel,
                          ProfileTexts.candidateEducationLevelHint,
                          [
                            ProfileTexts.educationSecondary,
                            ProfileTexts.educationTechnical,
                            ProfileTexts.educationUniversity,
                            ProfileTexts.educationMasters,
                            ProfileTexts.educationDoctorate,
                          ],
                          (value) => value ?? '',
                          (v) => controller.educationLevel(v ?? ''),
                          Icons.school,
                          null,
                        )),
                    const SizedBox(height: 16),
                    Obx(() => _buildDropdown<String>(
                          context,
                          controller.employmentStatus.value.isEmpty ? null : controller.employmentStatus.value,
                          ProfileTexts.candidateEmploymentStatusLabel,
                          ProfileTexts.candidateEmploymentStatusHint,
                          [
                            ProfileTexts.statusSeeking,
                            ProfileTexts.statusEmployed,
                            ProfileTexts.statusFreelance,
                            ProfileTexts.statusStudent,
                          ],
                          (value) => value ?? '',
                          (v) => controller.employmentStatus(v ?? ''),
                          Icons.work,
                          null,
                        )),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileMessages.professionalInformation, Icons.work, [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            context,
                            controller.skillController,
                            ProfileTexts.candidateSkillsLabel,
                            ProfileTexts.candidateSkillsHint,
                            Icons.code,
                            null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            controller.addSkill(controller.skillController.text);
                            controller.skillController.clear();
                          },
                          child: const Text(ProfileTexts.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.skills
                              .map((s) => Chip(
                                    label: Text(s),
                                    onDeleted: () => controller.removeSkill(s),
                                  ))
                              .toList(),
                        )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            context,
                            controller.languageNameController,
                            ProfileTexts.candidateLanguageNameHint,
                            ProfileTexts.candidateLanguageNameHint,
                            Icons.translate,
                            null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => _buildDropdown<String>(
                                context,
                                controller.languageLevel.value.isEmpty ? null : controller.languageLevel.value,
                                ProfileTexts.candidateLanguageLevelHint,
                                ProfileTexts.candidateLanguageLevelHint,
                                [
                                  ProfileTexts.levelBasic,
                                  ProfileTexts.levelIntermediate,
                                  ProfileTexts.levelAdvanced,
                                  ProfileTexts.levelNative,
                                ],
                                (v) => v ?? '',
                                (v) => controller.languageLevel(v ?? ''),
                                Icons.stacked_line_chart,
                                null,
                              )),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: controller.addLanguage,
                          child: const Text(ProfileTexts.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.languages
                              .map((l) => Chip(
                                    label: Text('${l.name} - ${l.level}'),
                                    onDeleted: () => controller.removeLanguage(l),
                                  ))
                              .toList(),
                        )),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.cvLinkController,
                      ProfileTexts.candidateCvLabel,
                      ProfileTexts.candidateCvHint,
                      Icons.description,
                      null,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: controller.isUploadingCv.value ? null : controller.pickAndUploadCv,
                              icon: const Icon(Icons.upload_file),
                              label: const Text(ProfileTexts.uploadPdf),
                            ),
                            const SizedBox(width: 12),
                            if (controller.isUploadingCv.value)
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: controller.cvLinkController.text.isEmpty
                                  ? null
                                  : () => _openCv(controller.cvLinkController.text),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text(ProfileTexts.openCv),
                            ),
                          ],
                        )),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.portfolioController,
                      ProfileTexts.candidatePortfolioLabel,
                      ProfileTexts.candidatePortfolioHint,
                      Icons.link,
                      null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.linkedinController,
                      ProfileTexts.candidateLinkedinLabel,
                      ProfileTexts.candidateLinkedinHint,
                      Icons.link,
                      null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.githubController,
                      ProfileTexts.candidateGithubLabel,
                      ProfileTexts.candidateGithubHint,
                      Icons.code,
                      null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      context,
                      controller.salaryController,
                      ProfileTexts.candidateSalaryExpectationLabel,
                      ProfileTexts.candidateSalaryExpectationHint,
                      Icons.attach_money,
                      null,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.preferencesSection, Icons.tune, [
                    Obx(() => _buildDropdown<String>(
                          context,
                          controller.workType.value.isEmpty ? null : controller.workType.value,
                          ProfileTexts.candidateWorkTypeLabel,
                          ProfileTexts.candidateWorkTypeHint,
                          [
                            ProfileTexts.workOnsite,
                            ProfileTexts.workRemote,
                            ProfileTexts.workHybrid,
                          ],
                          (v) => v ?? '',
                          (v) => controller.workType(v ?? ''),
                          Icons.work_outline,
                          null,
                        )),
                    const SizedBox(height: 16),
                    Obx(() => _buildDropdown<String>(
                          context,
                          controller.availability.value.isEmpty ? null : controller.availability.value,
                          ProfileTexts.candidateAvailabilityLabel,
                          ProfileTexts.candidateAvailabilityHint,
                          [
                            ProfileTexts.availabilityImmediate,
                            ProfileTexts.availability15,
                            ProfileTexts.availability30,
                            ProfileTexts.availabilityNegotiable,
                          ],
                          (v) => v ?? '',
                          (v) => controller.availability(v ?? ''),
                          Icons.schedule,
                          null,
                        )),
                    const SizedBox(height: 16),
                    Text(ProfileTexts.candidateInterestsLabel, style: Get.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _interestChip(context, ProfileTexts.interestsIt),
                        _interestChip(context, ProfileTexts.interestsMarketing),
                        _interestChip(context, ProfileTexts.interestsSales),
                        _interestChip(context, ProfileTexts.interestsDesign),
                        _interestChip(context, ProfileTexts.interestsOperations),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(ProfileTexts.candidatePreferredLocationsLabel, style: Get.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            context,
                            controller.preferredLocationController,
                            ProfileTexts.candidatePreferredLocationsLabel,
                            ProfileTexts.candidatePreferredLocationsHint,
                            Icons.place,
                            null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: controller.addPreferredLocation, child: const Text(ProfileTexts.add)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.preferredLocations
                              .map((loc) => Chip(
                                    label: Text(loc),
                                    onDeleted: () => controller.removePreferredLocation(loc),
                                  ))
                              .toList(),
                        )),
                  ]),
                  const SizedBox(height: 24),
                  if (controller.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (controller.successMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.successMessage.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Obx(() {
            final url = controller.photoUrl.value;
            return CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
              child: url.isEmpty
                  ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary)
                  : null,
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: controller.pickAndUploadPhoto,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: Obx(() => Text(
                  controller.photoUrl.value.isEmpty
                      ? ProfileTexts.candidateProfilePhotoUpload
                      : ProfileTexts.candidateProfilePhotoChange,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          if (controller.isUploadingPhoto.value)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField(
    BuildContext context,
    TextEditingController controller,
    String labelText,
    String hintText,
    IconData icon,
    String? Function(String?)? validator,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context,
    T? currentValue,
    String labelText,
    String hintText,
    List<T> items,
    String Function(T?) itemLabel,
    void Function(T?) onChanged,
    IconData icon,
    String? Function(T?)? validator,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _interestChip(BuildContext context, String label) {
    return Obx(() {
      final selected = controller.interests.contains(label);
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => controller.toggleInterest(label),
      );
    });
  }

  Future<void> _openCv(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}