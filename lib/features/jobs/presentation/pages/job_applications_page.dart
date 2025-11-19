import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/company_applications_controller.dart';
import '../../constants/job_status.dart';
import '../../domain/entities/application_entity.dart';
import '../../constants/jobs_texts.dart';

class JobApplicationsPage extends StatelessWidget {
  const JobApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String jobId = Get.parameters['jobId'] ?? '';
    final controller = Get.put(
      CompanyApplicationsController(jobsRepository: Get.find()),
    );

    // Initialize controller with job ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeWithJobId(jobId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(JobsTexts.applications),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshApplications(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshApplications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobInfo(controller),
                const SizedBox(height: 20),
                _buildApplicationsStats(controller),
                const SizedBox(height: 20),
                _buildStatusFilter(controller),
                const SizedBox(height: 16),
                _buildApplicationsList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobInfo(CompanyApplicationsController controller) {
    return Obx(() {
      final job = controller.currentJob.value;
      if (job == null) {
        return const SizedBox.shrink();
      }

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                job.location,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getJobStatusColor(
                        job.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getJobStatusDisplayName(job.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getJobStatusColor(job.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${JobsTexts.postedPrefix}${job.createdAtFormatted}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildApplicationsStats(CompanyApplicationsController controller) {
    return Obx(() {
      final applications = controller.filteredApplications;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                JobsTexts.applicationStatistics,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    'Total',
                    applications.length.toString(),
                    Colors.blue,
                  ),
                  _buildStatChip(
                    JobStatus.filterLabel[JobStatus.submitted]!,
                    applications
                        .where((app) => app.status == JobStatus.submitted)
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                  _buildStatChip(
                    JobStatus.filterLabel[JobStatus.interview]!,
                    applications
                        .where((app) => app.status == JobStatus.interview)
                        .length
                        .toString(),
                    Colors.purple,
                  ),
                  _buildStatChip(
                    JobStatus.filterLabel[JobStatus.hired]!,
                    applications
                        .where((app) => app.status == JobStatus.hired)
                        .length
                        .toString(),
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(CompanyApplicationsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          JobsTexts.filterByStatus,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                controller,
                JobStatus.all,
                JobStatus.filterLabel[JobStatus.all]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                controller,
                JobStatus.submitted,
                JobStatus.filterLabel[JobStatus.submitted]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                controller,
                JobStatus.seen,
                JobStatus.filterLabel[JobStatus.seen]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                controller,
                JobStatus.interview,
                JobStatus.filterLabel[JobStatus.interview]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                controller,
                JobStatus.rejected,
                JobStatus.filterLabel[JobStatus.rejected]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                controller,
                JobStatus.hired,
                JobStatus.filterLabel[JobStatus.hired]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    CompanyApplicationsController controller,
    String status,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedStatusFilter == status;
      return GestureDetector(
        onTap: () => controller.filterApplicationsByStatus(status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildApplicationsList(CompanyApplicationsController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final applications = controller.filteredApplications;

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (applications.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  JobsTexts.noApplicationsTitle,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  JobsTexts.noApplicationsSubtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${JobsTexts.applicationsCountPrefix}${applications.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: applications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final application = applications[index];
              return _buildCompanyApplicationCard(application, controller);
            },
          ),
        ],
      );
    });
  }

  Widget _buildCompanyApplicationCard(
    ApplicationEntity application,
    CompanyApplicationsController controller,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showApplicationDetails(application, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: Text(
                      application.candidateName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'C',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.candidateName ?? 'Candidate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${JobsTexts.appliedPrefix}${application.appliedAtFormatted}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        application.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(application.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(application.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (application.coverLetter != null &&
                  application.coverLetter!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    application.coverLetter!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),
  Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () =>
                controller.showStatusChangeDialog(application),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              JobsTexts.changeStatus,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => _showCandidateProfile(application),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              JobsTexts.viewProfile,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: () =>
                _showApplicationDetails(application, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(JobsTexts.viewDetails),
          ),
        ),
      ),
    ],
  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicationDetails(
    ApplicationEntity application,
    CompanyApplicationsController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    application.candidateName?.substring(0, 1).toUpperCase() ??
                        'C',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.candidateName ?? 'Candidate',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${JobsTexts.appliedPrefix}${application.appliedAtFormatted}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      application.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayName(application.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(application.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (application.coverLetter != null &&
                application.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                JobsTexts.coverLetter,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.coverLetter!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      controller.showStatusChangeDialog(application);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Change Status',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(JobsTexts.close),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _showCandidateProfile(ApplicationEntity application) async {
    Map<String, dynamic>? profile;
    try {
      final data = await Supabase.instance.client
          .from('candidate_profiles')
          .select(
            'name, location, photo_url, bio, years_experience, skills, languages, cv_url, portfolio_url, linkedin_url, github_url',
          )
          .eq('id', application.candidateId)
          .maybeSingle();
      profile = data != null ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      profile = null;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    backgroundImage:
                        (profile?['photo_url'] != null &&
                            (profile?['photo_url'] as String).isNotEmpty)
                        ? NetworkImage(profile!['photo_url'])
                        : null,
                    child:
                        (profile?['photo_url'] == null ||
                            (profile?['photo_url'] as String).isEmpty)
                        ? Text(
                            (application.candidateName ?? 'C')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.candidateName ?? 'Candidate',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (application.candidateEmail != null)
                          Text(
                            application.candidateEmail!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (profile != null && (profile['cv_url'] ?? '') != '') ...[
                        SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: profile!['cv_url'] as String),
                              );
                              Get.snackbar(JobsTexts.success, JobsTexts.copyLink);
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text(JobsTexts.cv),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final url = profile!['cv_url'] as String;
                              if (url.isEmpty) {
                                Get.snackbar(JobsTexts.error, JobsTexts.cvNotAvailable);
                                return;
                              }
                              final uri = Uri.tryParse(url);
                              if (uri == null) {
                                Get.snackbar(JobsTexts.error, JobsTexts.invalidUrl);
                                return;
                              }
                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text(JobsTexts.viewCv),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              JobsTexts.personalInformation,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              JobsTexts.name,
                              profile?['name'] ??
                                  application.candidateName ??
                                  '',
                            ),
                            _infoRow(
                              JobsTexts.location,
                              profile?['location'] ?? '',
                            ),
                            _infoRow(
                              JobsTexts.linkedin,
                              profile?['linkedin_url'] ?? '',
                            ),
                            _infoRow(
                              JobsTexts.github,
                              profile?['github_url'] ?? '',
                            ),
                            _infoRow(
                              JobsTexts.portfolio,
                              profile?['portfolio_url'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              JobsTexts.workInformation,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              JobsTexts.experienceYears,
                              (profile?['years_experience'] ?? '').toString(),
                            ),
                            if (profile?['skills'] is List &&
                                (profile?['skills'] as List).isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: (profile!['skills'] as List)
                                    .map((s) => Chip(label: Text(s.toString())))
                                    .toList(),
                              ),
                            if (profile?['bio'] != null &&
                                (profile?['bio'] as String).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                profile!['bio'] as String,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(JobsTexts.close),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Color _getJobStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getJobStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return JobsTexts.active;
      case 'pending':
        return JobsTexts.pending;
      case 'closed':
        return JobsTexts.closed;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case JobStatus.submitted:
        return Colors.blue;
      case JobStatus.seen:
        return Colors.orange;
      case JobStatus.interview:
        return Colors.purple;
      case JobStatus.rejected:
        return Colors.red;
      case JobStatus.hired:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    return JobStatus.displayName[status] ?? status;
  }
}
