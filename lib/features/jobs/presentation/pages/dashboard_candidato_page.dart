import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/jobs_texts.dart';
import '../controllers/jobs_home_controller.dart';
import '../widgets/job_card.dart';
import '../widgets/application_card.dart';
import '../widgets/kpi_chip.dart';
import '../widgets/apply_job_dialog.dart';
import '../../../../core/services/auth_session_service.dart';
import 'package:bolsa_de_trabajo/routes/app_routes.dart';
import 'package:bolsa_de_trabajo/features/profile/constants/profile_messages.dart';

class DashboardCandidatePage extends GetView<JobsHomeController> {
  const DashboardCandidatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
        title: const Text(JobsTexts.jobBoard),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (controller.currentTabIndex.value == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildWelcomeCard(context),
          _buildTabBar(context),
          Expanded(
            child: Obx(() => _buildTabContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  JobsTexts.candidate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text(JobsTexts.jobsMenu),
            onTap: () {
              Get.back();
              controller.changeTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text(JobsTexts.myApplicationsMenu),
            onTap: () {
              Get.back();
              controller.changeTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text(JobsTexts.savedMenu),
            onTap: () {
              Get.back();
              controller.changeTab(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(JobsTexts.aiJobSearch),
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.aiJobs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(ProfileMessages.profileTitle),
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.profile);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(JobsTexts.signOut),
            onTap: () {
              Get.back();
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final AuthSessionService session = Get.find();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                '${JobsTexts.welcomePrefix}${session.displayName ?? JobsTexts.candidate}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingKpis.value) {
              return const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(JobsTexts.loadingStatistics),
                  
                ],
              );
            }

            final kpis = controller.kpis.value;
            if (kpis == null) {
              return const Text(JobsTexts.failedToLoadStatistics);
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                KpiChip(
                  label: JobsTexts.availableJobs,
                  value: kpis.totalJobs.toString(),
                  color: Colors.blue,
                ),
                KpiChip(
                  label: JobsTexts.myApplicationsMenu,
                  value: kpis.totalApplications.toString(),
                  color: Colors.orange,
                ),
                KpiChip(
                  label: JobsTexts.interviews,
                  value: kpis.totalInterviews.toString(),
                  color: Colors.green,
                ),
                if (kpis.savedJobs != null)
                  KpiChip(
                    label: JobsTexts.savedMenu,
                    value: kpis.savedJobs.toString(),
                    color: Colors.purple,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabButton(
              JobsTexts.recommendedTab,
              0,
              controller.currentTabIndex.value == 0,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              JobsTexts.myApplicationsMenu,
              1,
              controller.currentTabIndex.value == 1,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              JobsTexts.savedMenu,
              2,
              controller.currentTabIndex.value == 2,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabButton(String title, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.currentTabIndex.value) {
      case 0:
        return _buildRecommendedTab();
      case 1:
        return _buildApplicationsTab();
      case 2:
        return _buildSavedTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildRecommendedTab() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.recommendedJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              JobsTexts.noJobsAvailable,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.recommendedJobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = controller.recommendedJobs[index];
          return JobCard(
            job: job,
            onApply: () => _showApplyDialog(job.id),
            onToggleSaved: () => controller.toggleSaved(job.id),
            isSaved: controller.isJobSaved(job.id),
            hasApplied: controller.hasAppliedToJob(job.id),
            isApplying: controller.isApplying.value,
            isTogglingSaved: controller.isTogglingSaved.value,
          );
        },
      ),
    );
  }

  Widget _buildApplicationsTab() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.myApplications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              JobsTexts.youHaveNoApplications,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myApplications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final application = controller.myApplications[index];
          return ApplicationCard(application: application);
        },
      ),
    );
  }

  Widget _buildSavedTab() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.savedJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              JobsTexts.youHaveNoSavedJobs,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.savedJobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = controller.savedJobs[index];
          return JobCard(
            job: job,
            onApply: () => _showApplyDialog(job.id),
            onToggleSaved: () => controller.toggleSaved(job.id),
            isSaved: true,
            hasApplied: controller.hasAppliedToJob(job.id),
            isApplying: controller.isApplying.value,
            isTogglingSaved: controller.isTogglingSaved.value,
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(JobsTexts.searchJobs),
        content: TextField(
          decoration: const InputDecoration(
            hintText: JobsTexts.searchHint,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            Get.back();
            controller.searchJobs(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearSearch();
            },
            child: const Text(JobsTexts.clear),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(JobsTexts.cancel),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(String jobId) {
    Get.dialog(
      ApplyJobDialog(
        onApply: (coverLetter) => controller.applyToJob(jobId, coverLetter: coverLetter),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(JobsTexts.signOut),
        content: const Text(JobsTexts.signOutQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(JobsTexts.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await controller.doLogout();
              } catch (e) {
                Get.snackbar(
                  JobsTexts.error,
                  '${JobsTexts.failedToSignOutPrefix}${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(JobsTexts.signOut),
          ),
        ],
      ),
    );
  }
}