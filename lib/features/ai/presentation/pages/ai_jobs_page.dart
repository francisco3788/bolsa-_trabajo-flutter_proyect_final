import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_jobs_controller.dart';
import '../widgets/job_card_with_application.dart';
import '../../constants/ai_texts.dart';
import '../../domain/entities/ai_generated_job.dart';
import '../../ai_module.dart';

class AiJobsPage extends GetView<AiJobsController> {
  const AiJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('AiJobsPage: Building page...');
    print('AiJobsPage: AiJobsController registered: ${Get.isRegistered<AiJobsController>()}');
    
    // Ensure controller is available
    if (!Get.isRegistered<AiJobsController>()) {
      print('AiJobsPage: AiJobsController not found, trying to initialize...');
      try {
        // Force initialization using the module
        AiModule.ensureInitialized();
        print('AiJobsPage: Module initialization called');
        
        // Small delay to allow initialization
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<AiJobsController>()) {
            print('AiJobsPage: Controller now available after delay');
          } else {
            print('AiJobsPage: Controller still not available after delay');
          }
        });
      } catch (e) {
        print('AiJobsPage: Error initializing module: $e');
        // If still not found, show error message
        return Scaffold(
          appBar: AppBar(
            title: const Text(AiTexts.appTitle),
            backgroundColor: Colors.blue[800],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  AiTexts.aiModuleErrorTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AiTexts.failedToInitialize} $e',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    print('AiJobsPage: Retrying initialization...');
                    AiModule.ensureInitialized();
                  },
                  child: const Text(AiTexts.retry),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AiTexts.appTitle),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshJobs,
            tooltip: AiTexts.refreshAiJobs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFilterSection(),
          _buildStatusSection(),
          Expanded(child: _buildJobsList()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AiTexts.aiSearchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: controller.updateSearchQuery,
                  onSubmitted: (_) => controller.generateAiJobs(),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => ElevatedButton(
                onPressed: controller.generateAiJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: controller.isGenerating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(AiTexts.generate, style: TextStyle(color: Colors.white)),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                AiTexts.aiPoweredBy,
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: AiTexts.labelLocation,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedLocation.value.isEmpty ? null : controller.selectedLocation.value,
              items: ['']
                  .followedBy(AiTexts.locationsPool)
                  .map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location.isEmpty ? AiTexts.allLocations : location),
                );
              }).toList(),
              onChanged: (value) => controller.updateLocation(value ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: AiTexts.labelWorkMode,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedWorkMode.value.isEmpty ? null : controller.selectedWorkMode.value,
              items: ['']
                  .followedBy(AiTexts.workModes)
                  .map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.isEmpty ? AiTexts.allModes : _getWorkModeDisplay(mode)),
                );
              }).toList(),
              onChanged: (value) => controller.updateWorkMode(value ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: AiTexts.labelJobType,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedJobType.value.isEmpty ? null : controller.selectedJobType.value,
              items: ['']
                  .followedBy(AiTexts.jobTypes)
                  .map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.isEmpty ? AiTexts.allTypes : _getJobTypeDisplay(type)),
                );
              }).toList(),
              onChanged: (value) => controller.updateJobType(value ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red[50],
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red[700]),
                onPressed: () => controller.errorMessage.value = '',
              ),
            ],
          ),
        );
      }

      if (controller.successMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.successMessage.value,
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.green[700]),
                onPressed: () => controller.successMessage.value = '',
              ),
            ],
          ),
        );
      }

      if (controller.isGenerating.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                AiTexts.generatingJobs,
                style: TextStyle(color: Colors.blue[800]),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildJobsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.aiJobs.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.aiJobs.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                AiTexts.noAiResults,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AiTexts.aiSearchExamples,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.aiJobs.length,
        itemBuilder: (context, index) {
          final job = controller.aiJobs[index];
          return _buildJobCard(job);
        },
      );
    });
  }

  Widget _buildJobCard(AiGeneratedJob job) {
    return JobCardWithApplication(
      job: job,
      onApply: () {
        // Optional: Add any additional logic when apply is pressed
        print('Apply button pressed for job: ${job.title}');
      },
    );
  }

  void _showJobDetails(AiGeneratedJob job) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${AiTexts.companyLabel} ${job.companyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${AiTexts.locationLabel} ${job.location}'),
              Text('${AiTexts.workModeLabel} ${_getWorkModeDisplay(job.workMode)}'),
              Text('${AiTexts.jobTypeLabel} ${_getJobTypeDisplay(job.jobType)}'),
              if (job.salaryMin != null || job.salaryMax != null) ...[
                const SizedBox(height: 8),
                Text('${AiTexts.salaryLabel} ${_getSalaryRange(job)}'),
              ],
              const SizedBox(height: 16),
              const Text(AiTexts.descriptionLabel, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(job.description),
              if (job.requirements != null) ...[
                const SizedBox(height: 16),
                const Text(AiTexts.requirementsLabel, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(job.requirements!),
              ],
              if (job.benefits != null) ...[
                const SizedBox(height: 16),
                const Text(AiTexts.benefitsLabel, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(job.benefits!),
              ],
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(AiTexts.skillsLabel, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.skills.map((skill) {
                    return Chip(label: Text(skill));
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue[800]),
                  const SizedBox(width: 8),
                  Text(
                    '${AiTexts.generatedByAi} - ${AiTexts.confidenceLabel}: ${(job.aiConfidenceScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.blue[800], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AiTexts.close),
          ),
        ],
      ),
    );
  }

  String _getWorkModeDisplay(String workMode) {
    return AiTexts.workModeDisplay(workMode);
  }

  String _getJobTypeDisplay(String jobType) {
    return AiTexts.jobTypeDisplay(jobType);
  }

  String _getSalaryRange(AiGeneratedJob job) {
    return AiTexts.formatSalaryRange(job.salaryMin, job.salaryMax, job.currency);
  }
}