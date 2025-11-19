import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../job_applications/presentation/screens/job_application_screen.dart';
import '../../../job_applications/job_application_binding.dart';
import '../../constants/ai_texts.dart';
import '../../domain/entities/ai_generated_job.dart';

class JobCardWithApplication extends StatelessWidget {
  final AiGeneratedJob job;
  final VoidCallback? onApply;

  const JobCardWithApplication({
    Key? key,
    required this.job,
    this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showJobDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildJobDetails(),
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSkills(),
              ],
              if (job.salaryMin != null || job.salaryMax != null) ...[
                const SizedBox(height: 12),
                _buildSalary(),
              ],
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.companyName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: Colors.blue[800],
              ),
              const SizedBox(width: 4),
              Text(
                '${(job.aiConfidenceScore * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(job.location, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(width: 16),
        Icon(Icons.work, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(_getWorkModeDisplay(job.workMode), style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: job.skills.take(5).map((skill) {
        return Chip(
          label: Text(skill),
          backgroundColor: Colors.grey[100],
          labelStyle: const TextStyle(fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildSalary() {
    return Row(
      children: [
        Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
        const SizedBox(width: 4),
        Text(
          _getSalaryRange(),
          style: TextStyle(
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showJobDetails(Get.context!),
            child: const Text('View Details'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Apply Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            onPressed: _navigateToApplication,
          ),
        ),
      ],
    );
  }

  void _showJobDetails(BuildContext context) {
    showDialog(
      context: context,
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
                Text('Salary: ${_getSalaryRange()}'),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Apply Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToApplication();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToApplication() {
    // Initialize the job application module
    JobApplicationBinding().dependencies();
    
    Get.to(
      () => JobApplicationScreen(
        jobId: job.id,
        jobTitle: job.title,
        companyName: job.companyName,
      ),
      binding: JobApplicationBinding(),
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

  String _getSalaryRange() {
    if (job.salaryMin == null && job.salaryMax == null) return 'Salary not specified';
    if (job.salaryMin == null) return 'Up to \$${job.salaryMax}';
    if (job.salaryMax == null) return 'From \$${job.salaryMin}';
    return '\$${job.salaryMin} - \$${job.salaryMax}';
  }
}