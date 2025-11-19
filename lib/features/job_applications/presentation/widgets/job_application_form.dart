import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/job_application_texts.dart';
import '../../domain/entities/job_application.dart';
import '../controllers/job_application_controller.dart';

// Este archivo contiene los widgets de la pantalla de aplicación actualizados con los textos correctos

class JobApplicationForm extends StatelessWidget {
  final JobApplicationController controller;
  
  const JobApplicationForm({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Obx(() => TextFormField(
          maxLines: 8,
          decoration: InputDecoration(
            labelText: JobApplicationTexts.coverLetterHint,
            border: OutlineInputBorder(),
            errorText: _validateCoverLetter(controller.coverLetter.value),
          ),
          onChanged: (value) => controller.coverLetter.value = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return JobApplicationTexts.coverLetterRequired;
            }
            if (value.length < 50) {
              return JobApplicationTexts.coverLetterTooShort;
            }
            return null;
          },
        )),
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
          decoration: InputDecoration(
            labelText: JobApplicationTexts.phoneNumber,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            controller.additionalData['phone'] = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: JobApplicationTexts.linkedInProfile,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) {
            controller.additionalData['linkedin'] = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: JobApplicationTexts.yearsExperience,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            controller.additionalData['experience_years'] = int.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  String? _validateCoverLetter(String value) {
    if (value.isEmpty) {
      return JobApplicationTexts.coverLetterRequired;
    }
    if (value.length < 50) {
      return JobApplicationTexts.coverLetterTooShort;
    }
    return null;
  }
}

class JobApplicationSubmitButton extends StatelessWidget {
  final JobApplicationController controller;
  final VoidCallback onSubmit;
  
  const JobApplicationSubmitButton({
    Key? key, 
    required this.controller, 
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                JobApplicationTexts.submitApplication,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
    );
  }
}