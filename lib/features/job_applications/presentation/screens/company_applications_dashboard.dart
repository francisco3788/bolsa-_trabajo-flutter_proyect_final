import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/auth_session_service.dart';
import '../../constants/job_application_texts.dart';
import '../../domain/entities/job_application.dart';
import '../controllers/job_application_controller.dart';
import '../widgets/application_card.dart';
import '../widgets/application_stats_card.dart';

class CompanyApplicationsDashboard extends GetView<JobApplicationController> {
  const CompanyApplicationsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshApplications();
    });
    const brandBlue = Color(0xFF3A5A92);
    const brandBlueLight = Color(0xFF5676B3);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        title: const Text(JobApplicationTexts.companyDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshApplications(),
          ),
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () => _generateAIInsights(),
            tooltip: JobApplicationTexts.aiGenerateInsights,
          ),
          Obx(() {
            final count = controller.unreadNotificationCount.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () async {
                    final companyId = Get.find<AuthSessionService>().user?.id ?? '';
                    await controller.loadUnreadNotificationCount(companyId);
                  },
                  tooltip: JobApplicationTexts.notificationsTooltip,
                ),
                if (count > 0)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              brandBlue.withOpacity(0.08),
              brandBlueLight.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildHeroHeader(context),
                ),
                _buildStatsSection(),
                _buildAISummary(),
                const SizedBox(height: 8),
                _buildSearchSection(),
                _buildFilterSection(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _buildApplicationsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    const brandBlue = Color(0xFF3A5A92);
    const brandBlueLight = Color(0xFF5676B3);
    final name = Get.find<AuthSessionService>().user?.name ?? 'Company';
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [brandBlue, brandBlueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $name',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Company Dashboard',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _pillStat('Jobs', controller.companyApplications.map((e) => e.jobId).toSet().length),
                const SizedBox(width: 8),
                _pillStat('Applications', controller.companyApplications.length),
                const SizedBox(width: 8),
                _pillStat('Accepted', controller.getApplicationsByStatus(ApplicationStatus.accepted).length),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillStat(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
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
            child: ApplicationStatsCard(
              title: JobApplicationTexts.totalApplications,
              count: controller.companyApplications.length,
              color: const Color(0xFF3A5A92),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ApplicationStatsCard(
              title: JobApplicationTexts.pendingApplications,
              count: controller.pendingApplicationsCount,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ApplicationStatsCard(
              title: JobApplicationTexts.acceptedApplications,
              count: controller.getApplicationsByStatus(ApplicationStatus.accepted).length,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: JobApplicationTexts.searchApplications,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (query) {
          // Implement search functionality
          _searchApplications(query);
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(JobApplicationTexts.allStatus, null),
            const SizedBox(width: 8),
            _buildFilterChip(JobApplicationTexts.pendingStatus, ApplicationStatus.pending),
            const SizedBox(width: 8),
            _buildFilterChip(JobApplicationTexts.underReviewStatus, ApplicationStatus.underReview),
            const SizedBox(width: 8),
            _buildFilterChip(JobApplicationTexts.acceptedStatus, ApplicationStatus.accepted),
            const SizedBox(width: 8),
            _buildFilterChip(JobApplicationTexts.rejectedStatus, ApplicationStatus.rejected),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text(JobApplicationTexts.aiBatchSuggest),
              onPressed: () => _generateBatchSuggestions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A5A92),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status) {
    return Obx(() {
      final isSelected = controller.getApplicationsByStatus(status ?? ApplicationStatus.pending).isNotEmpty;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF3A5A92).withOpacity(0.15),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF3A5A92) : Colors.black87),
        onSelected: (selected) {
          if (selected) {
            _filterByStatus(status);
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

        if (controller.companyApplications.isEmpty) {
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
                  JobApplicationTexts.noApplications,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.companyApplications.length,
          itemBuilder: (context, index) {
            final application = controller.companyApplications[index];
            return ApplicationCard(
              application: application,
              onStatusUpdate: (newStatus, notes) {
                _updateApplicationStatus(application.id, newStatus, notes);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildAISummary() {
    return Obx(() {
      final insights = controller.aiSuggestions['insights'];
      if (insights == null) return const SizedBox.shrink();

      final overall = insights['overall_assessment'] ?? '';
      final quality = insights['quality_score'] ?? 0.0;
      final keyInsights = List<String>.from(insights['key_insights'] ?? []);
      final recommendations = List<String>.from(insights['recommendations'] ?? []);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF3A5A92)),
                    const SizedBox(width: 8),
                    const Text(
                      JobApplicationTexts.aiInsightsTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A5A92).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${JobApplicationTexts.qualityLabel} ${(quality * 100).round()}%'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${JobApplicationTexts.aiInsightsOverall}: $overall',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (keyInsights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: keyInsights.map((k) => Chip(label: Text(k))).toList(),
                  ),
                ],
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    JobApplicationTexts.aiInsightsRecommendations,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...recommendations.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [const Icon(Icons.circle, size: 6), const SizedBox(width: 6), Expanded(child: Text(r))]),
                      )),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _generateAIInsights() async {
    await controller.getApplicationInsights(jobTitle: '');
  }

  Future<void> _generateBatchSuggestions() async {
    await controller.getBatchAISuggestions(
      applications: controller.companyApplications,
      jobTitle: '',
      jobDescription: '',
      companyRequirements: '',
    );
  }

  Future<void> _refreshApplications() async {
    // Get company ID from auth or job
    final companyId = Get.find<AuthSessionService>().user?.id ?? '';
    await controller.getCompanyApplications(companyId: companyId);
    await controller.getApplicationStats(companyId);
    await controller.loadUnreadNotificationCount(companyId);
  }

  Future<void> _searchApplications(String query) async {
    final companyId = Get.find<AuthSessionService>().user?.id ?? '';
    await controller.getCompanyApplications(
      companyId: companyId,
      searchQuery: query.isNotEmpty ? query : null,
    );
  }

  Future<void> _filterByStatus(ApplicationStatus? status) async {
    final companyId = Get.find<AuthSessionService>().user?.id ?? '';
    await controller.getCompanyApplications(
      companyId: companyId,
      statusFilter: status,
    );
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    ApplicationStatus newStatus,
    String? notes,
  ) async {
    await controller.updateApplicationStatus(
      applicationId: applicationId,
      newStatus: newStatus,
      reviewNotes: notes,
    );
  }
}