import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../constants/profile_messages.dart';
import '../controllers/enhanced_company_profile_controller.dart';
import '../../domain/entities/company_profile.dart';

class EnhancedCompanyProfilePage extends GetView<EnhancedCompanyProfileController> {
  const EnhancedCompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ProfileMessages.companyProfileTitle,
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
              key: controller.companyFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoSection(context),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.basicInformationSection, Icons.info_outline, [
                    _buildStyledTextField(context, controller.companyNameController, 
                        ProfileTexts.companyNameLabel, ProfileTexts.companyNameHint, 
                        Icons.business, (value) => controller.validateRequired(value, 'Company name')),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companySectorController,
                        ProfileTexts.companySectorLabel, ProfileTexts.companySectorHint,
                        Icons.category, (value) => controller.validateRequired(value, 'Industry sector')),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyLocationController,
                        ProfileTexts.companyLocationLabel, ProfileTexts.companyLocationHint,
                        Icons.location_on, (value) => controller.validateRequired(value, 'Location')),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyWebsiteController,
                        ProfileTexts.companyWebsiteLabel, ProfileTexts.companyWebsiteHint,
                        Icons.link, controller.validateWebsite),
                    const SizedBox(height: 16),
                    Obx(() => _buildStyledDropdown(context, controller.companySize.value,
                        ProfileTexts.companySizeLabel, ProfileTexts.companySizeHint,
                        CompanySize.values, (size) => size.description, controller.setCompanySize,
                        Icons.people, (value) => value == null ? 'Please select company size' : null)),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyFoundedController,
                        ProfileTexts.companyFoundedLabel, ProfileTexts.companyFoundedHint,
                        Icons.calendar_today, controller.validateYear, TextInputType.number),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.contactInformationSection, Icons.contact_mail, [
                    _buildStyledTextField(context, controller.companyContactPersonController,
                        ProfileTexts.companyContactPersonLabel, ProfileTexts.companyContactPersonHint,
                        Icons.person, null),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyContactEmailController,
                        ProfileTexts.companyContactEmailLabel, ProfileTexts.companyContactEmailHint,
                        Icons.email, controller.validateEmail),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyContactPhoneController,
                        ProfileTexts.companyContactPhoneLabel, ProfileTexts.companyContactPhoneHint,
                        Icons.phone, controller.validatePhone),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyAddressController,
                        ProfileTexts.companyAddressLabel, ProfileTexts.companyAddressHint,
                        Icons.location_city, null, TextInputType.text, null, 2),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.companyDetailsSection, Icons.info, [
                    _buildStyledTextField(context, controller.companyDescriptionController,
                        ProfileTexts.companyDescriptionLabel, ProfileTexts.companyDescriptionHint,
                        Icons.description, null, TextInputType.multiline, null, 4),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyCultureController,
                        ProfileTexts.companyCultureLabel, ProfileTexts.companyCultureHint,
                        Icons.groups, null),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyWorkScheduleController,
                        ProfileTexts.companyWorkScheduleLabel, ProfileTexts.companyWorkScheduleHint,
                        Icons.schedule, null),
                    const SizedBox(height: 16),
                    Obx(() => _buildStyledDropdown(context, controller.remotePolicy.value,
                        ProfileTexts.companyRemotePolicyLabel, ProfileTexts.companyRemotePolicyHint,
                        RemoteWorkPolicy.values, (policy) => policy.description, controller.setRemotePolicy,
                        Icons.home_work, null)),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.companyBenefitsSection, Icons.card_giftcard, [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(context, controller.benefitController,
                              ProfileTexts.companyBenefitsLabel, ProfileTexts.companyBenefitsHint,
                              Icons.card_giftcard, null, TextInputType.text, (_) => controller.addBenefit()),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: controller.addBenefit,
                            icon: const Icon(Icons.add, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.benefits.map((benefit) {
                        return Chip(
                          label: Text(
                            benefit,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          deleteIconColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          onDeleted: () => controller.removeBenefit(benefit),
                        );
                      }).toList(),
                    )),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionCard(context, ProfileTexts.socialMediaSection, Icons.share, [
                    _buildStyledTextField(context, controller.companyLinkedinController,
                        ProfileTexts.companyLinkedinLabel, ProfileTexts.companyLinkedinHint,
                        Icons.link, controller.validateWebsite),
                    const SizedBox(height: 16),
                    _buildStyledTextField(context, controller.companyTwitterController,
                        ProfileTexts.companyTwitterLabel, ProfileTexts.companyTwitterHint,
                        Icons.alternate_email, null),
                  ]),
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

  Widget _buildLogoSection(BuildContext context) {
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
            final logoUrl = controller.logoUrl.value;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                    BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                child: logoUrl.isEmpty
                    ? Icon(
                        Icons.business_center,
                        size: 70,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      )
                    : null,
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickLogoImage,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: Obx(() => Text(
              controller.logoUrl.value.isEmpty 
                  ? ProfileTexts.uploadLogo 
                  : ProfileTexts.changeLogo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          if (controller.isUploadingLogo.value)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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

  Widget _buildStyledTextField(
    BuildContext context,
    TextEditingController controller,
    String labelText,
    String hintText,
    IconData icon,
    String? Function(String?)? validator,
    [TextInputType? keyboardType,
    void Function(String)? onSubmitted,
    int? maxLines]
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        onFieldSubmitted: onSubmitted,
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

  Widget _buildStyledDropdown<T>(
    BuildContext context,
    T? currentValue,
    String labelText,
    String hintText,
    List<T> items,
    String Function(T) itemLabel,
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
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Future<void> _pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // For web, we need to read the bytes instead of using File
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await controller.uploadLogoImageWeb(bytes, image.name, image.mimeType ?? 'image/jpeg');
      } else {
        // For mobile, check if path is valid
        if (image.path.isNotEmpty) {
          await controller.uploadLogoImage(File(image.path));
        } else {
          // Handle invalid path
        }
      }
    }
  }
}

