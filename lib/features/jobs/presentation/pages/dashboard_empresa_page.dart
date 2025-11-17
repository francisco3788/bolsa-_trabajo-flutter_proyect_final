import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/jobs_texts.dart';
import '../controllers/company_home_controller.dart';
import '../widgets/kpi_chip.dart';
import '../../domain/entities/job_entity.dart';

class DashboardCompanyPage extends StatelessWidget {
  const DashboardCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanyHomeController>();

  return Scaffold(
    appBar: AppBar(
      title: const Text(JobsTexts.companyAppBarTitle),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.goToCreateJob(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(controller),
                const SizedBox(height: 20),
                _buildJobsSection(controller),
              ],
            ),
          ),
        ),
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
                  Icons.business,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  JobsTexts.companyPanel,
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
            title: const Text(JobsTexts.myJobs),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text(JobsTexts.postJob),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/job/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(JobsTexts.myProfile),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(JobsTexts.signOut, style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(CompanyHomeController controller) {
    return Obx(() {
      final kpis = controller.kpis.value;
      final isLoading = controller.isLoadingKpis.value;

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
                JobsTexts.welcome,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Text(
                JobsTexts.companyAppBarTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    KpiChip(
                      label: JobsTexts.jobs,
                      value: kpis?.totalJobs.toString() ?? '0',
                      color: Colors.white,
                    ),
                    KpiChip(
                      label: JobsTexts.applications,
                      value: kpis?.totalApplications.toString() ?? '0',
                      color: Colors.white,
                    ),
                    KpiChip(
                      label: JobsTexts.interviews,
                      value: kpis?.totalInterviews.toString() ?? '0',
                      color: Colors.white,
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildJobsSection(CompanyHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          JobsTexts.myJobListings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTabBar(controller),
        const SizedBox(height: 16),
        _buildJobsList(controller),
      ],
    );
  }

  Widget _buildTabBar(CompanyHomeController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(controller, 'all', JobsTexts.all),
          const SizedBox(width: 8),
          _buildTabButton(controller, 'active', JobsTexts.active),
          const SizedBox(width: 8),
          _buildTabButton(controller, 'pending', JobsTexts.pending),
          const SizedBox(width: 8),
          _buildTabButton(controller, 'closed', JobsTexts.closed),
        ],
      ),
    );
  }

  Widget _buildTabButton(CompanyHomeController controller, String status, String label) {
    return Obx(() {
      final isSelected = controller.currentStatus.value == status;
      return GestureDetector(
        onTap: () => controller.loadJobsByStatus(status),
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

  Widget _buildJobsList(CompanyHomeController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final jobs = controller.getJobsByStatus(controller.currentStatus.value);

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (jobs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.work_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  JobsTexts.noJobListings,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  JobsTexts.publishFirstJobHint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildCompanyJobCard(job, controller);
        },
      );
    });
  }

  Widget _buildCompanyJobCard(JobEntity job, CompanyHomeController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.goToJobApplications(job.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'change_status') {
                        _showChangeStatusDialog(job, controller);
                      } else if (value == 'view_applications') {
                        controller.goToJobApplications(job.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view_applications',
                        child: Row(
                          children: [
                            Icon(Icons.people),
                            SizedBox(width: 8),
                            Text(JobsTexts.viewApplications),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'change_status',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text(JobsTexts.changeStatus),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(job.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(job.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    job.createdAtFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (job.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: job.skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _getStatusDisplayName(String status) {
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

  void _showChangeStatusDialog(JobEntity job, CompanyHomeController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text(JobsTexts.changeStatusTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change the status of "${job.title}"?'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: job.status,
              decoration: const InputDecoration(
                labelText: JobsTexts.newStatus,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'active', child: Text(JobsTexts.active)),
                DropdownMenuItem(value: 'pending', child: Text(JobsTexts.pending)),
                DropdownMenuItem(value: 'closed', child: Text(JobsTexts.closed)),
              ],
              onChanged: (value) {
                if (value != null && value != job.status) {
                  Get.back();
                  controller.changeJobStatus(job.id, value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(JobsTexts.cancel),
          ),
        ],
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
                final controller = Get.find<CompanyHomeController>();
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