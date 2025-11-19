import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../constants/job_application_texts.dart';
import '../../domain/entities/job_application.dart';
import '../controllers/job_application_controller.dart';
import '../widgets/candidate_application_card.dart';

class CandidateApplicationsScreen extends GetView<JobApplicationController> {
  const CandidateApplicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(JobApplicationTexts.myApplicationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshApplications(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsSection(),
          _buildFilterSection(),
          _buildApplicationsList(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              controller.candidateApplications.length.toString(),
              Colors.blue,
              Icons.assignment,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Pending',
              controller.candidateApplications.where((app) => app.status == ApplicationStatus.pending).length.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Accepted',
              controller.candidateApplications.where((app) => app.status == ApplicationStatus.accepted).length.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', ApplicationStatus.pending),
            const SizedBox(width: 8),
            _buildFilterChip('Under Review', ApplicationStatus.underReview),
            const SizedBox(width: 8),
            _buildFilterChip('Accepted', ApplicationStatus.accepted),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', ApplicationStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == status;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.filterByStatus(status);
          }
        },
      );
    });
  }

  Widget _buildApplicationsList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = controller.filteredApplications;

        if (applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No applications found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start applying to jobs to see them here',
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
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return CandidateApplicationCard(
              application: application,
              onTap: () => _showApplicationDetails(application),
            );
          },
        );
      }),
    );
  }

  Future<void> _refreshApplications() async {
    final candidateId = Get.find<AuthSessionService>().user?.id ?? '';
    if (candidateId.isNotEmpty) {
      await controller.getCandidateApplications(candidateId);
    }
  }

  void _showApplicationDetails(JobApplication application) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Application Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (application.metadata != null) ...[
                if (application.metadata!['job_title'] != null)
                  Text('Position: ${application.metadata!['job_title']}'),
                if (application.metadata!['company_name'] != null)
                  Text('Company: ${application.metadata!['company_name']}'),
              ],
              const SizedBox(height: 8),
              Text('Applied: ${_formatDate(application.appliedAt)}'),
              Text('Status: ${_formatStatus(application.status)}'),
              if (application.statusUpdatedAt != null) ...[
                const SizedBox(height: 8),
                Text('Updated: ${_formatDate(application.statusUpdatedAt!)}'),
              ],
              if (application.notes != null) ...[
                const SizedBox(height: 16),
                const Text('Review Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(application.notes!),
              ],
              const SizedBox(height: 16),
              const Text('Your Cover Letter:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(application.coverLetter ?? ''),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.cancelled:
        return 'Cancelled';
    }
  }
}