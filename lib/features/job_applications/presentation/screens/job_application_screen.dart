import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../constants/job_application_texts.dart';
import '../../domain/entities/job_application.dart';
import '../controllers/job_application_controller.dart';

class JobApplicationScreen extends GetView<JobApplicationController> {
  final String jobId;
  final String jobTitle;
  final String companyName;

  const JobApplicationScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(JobApplicationTexts.jobApplicationTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobInfo(),
              const SizedBox(height: 24),
              _buildApplicationForm(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                JobApplicationTexts.applyingFor,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              jobTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              companyName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          JobApplicationTexts.coverLetterLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: JobApplicationTexts.coverLetterHint,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => controller.coverLetter.value = value,
        ),
        const SizedBox(height: 16),
        Text(
          JobApplicationTexts.additionalInfo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildAdditionalFields(),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: JobApplicationTexts.phoneNumber, border: const OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            controller.additionalData['phone'] = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(labelText: JobApplicationTexts.linkedInProfile, border: const OutlineInputBorder()),
          keyboardType: TextInputType.url,
          onChanged: (value) {
            controller.additionalData['linkedin'] = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(labelText: JobApplicationTexts.yearsExperience, border: const OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            controller.additionalData['experience_years'] = int.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitApplication,
              child: const Text(JobApplicationTexts.submitApplication),
            ),
          ));
  }

  Future<void> _submitApplication() async {
    final user = Get.find<AuthSessionService>().user;
    if (user == null) {
      Get.snackbar(JobApplicationTexts.errorTitle, JobApplicationTexts.mustBeLoggedIn);
      return;
    }

    if (controller.coverLetter.value.isEmpty || controller.coverLetter.value.length < 50) {
      Get.snackbar(JobApplicationTexts.errorTitle, JobApplicationTexts.pleaseCompleteForm);
      return;
    }

    await controller.applyToJob(
      jobId: jobId,
      candidateId: user.id,
      candidateName: user.name ?? user.email,
      candidateEmail: user.email,
    );

    if (controller.errorMessage.value.isEmpty) {
      Get.back();
      Get.snackbar(JobApplicationTexts.successTitle, JobApplicationTexts.applicationSubmitted);
    }
  }
}