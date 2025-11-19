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
            title: const Text('AI-Powered Job Search'),
            backgroundColor: Colors.blue[800],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'AI Module Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to initialize: $e',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    print('AiJobsPage: Retrying initialization...');
                    AiModule.ensureInitialized();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Powered Job Search'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshJobs,
            tooltip: 'Refresh AI Jobs',
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
                    : const Text('Generate', style: TextStyle(color: Colors.white)),
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
                labelText: 'Location',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedLocation.value.isEmpty ? null : controller.selectedLocation.value,
              items: ['', 'Remote', 'New York', 'San Francisco', 'London', 'Berlin'].map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location.isEmpty ? 'All Locations' : location),
                );
              }).toList(),
              onChanged: (value) => controller.updateLocation(value ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Work Mode',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedWorkMode.value.isEmpty ? null : controller.selectedWorkMode.value,
              items: ['', 'remote', 'hybrid', 'onsite'].map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.isEmpty ? 'All Modes' : _getWorkModeDisplay(mode)),
                );
              }).toList(),
              onChanged: (value) => controller.updateWorkMode(value ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Job Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedJobType.value.isEmpty ? null : controller.selectedJobType.value,
              items: ['', 'full_time', 'part_time', 'contract', 'internship'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.isEmpty ? 'All Types' : _getJobTypeDisplay(type)),
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
                'Try searching for "Flutter Developer" or "Data Scientist"',
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
              Text('Company: ${job.companyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Location: ${job.location}'),
              Text('Work Mode: ${_getWorkModeDisplay(job.workMode)}'),
              Text('Job Type: ${_getJobTypeDisplay(job.jobType)}'),
              if (job.salaryMin != null || job.salaryMax != null) ...[
                const SizedBox(height: 8),
                Text('Salary: ${_getSalaryRange(job)}'),
              ],
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(job.description),
              if (job.requirements != null) ...[
                const SizedBox(height: 16),
                const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(job.requirements!),
              ],
              if (job.benefits != null) ...[
                const SizedBox(height: 16),
                const Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(job.benefits!),
              ],
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    '${AiTexts.generatedByAi} - Confidence: ${(job.aiConfidenceScore * 100).toStringAsFixed(0)}%',
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getWorkModeDisplay(String workMode) {
    switch (workMode) {
      case 'remote':
        return 'Remote';
      case 'hybrid':
        return 'Hybrid';
      case 'onsite':
        return 'On-site';
      default:
        return workMode;
    }
  }

  String _getJobTypeDisplay(String jobType) {
    switch (jobType) {
      case 'full_time':
        return 'Full-time';
      case 'part_time':
        return 'Part-time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return jobType;
    }
  }

  String _getSalaryRange(AiGeneratedJob job) {
    if (job.salaryMin == null && job.salaryMax == null) return 'Salary not specified';
    if (job.salaryMin == null) return 'Up to \$${job.salaryMax}';
    if (job.salaryMax == null) return 'From \$${job.salaryMin}';
    return '\$${job.salaryMin} - \$${job.salaryMax}';
  }
}