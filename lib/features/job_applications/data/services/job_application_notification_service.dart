import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bolsa_de_trabajo/features/job_applications/domain/entities/job_application.dart';
import '../../constants/job_application_texts.dart';

class JobApplicationNotificationService {
  final SupabaseClient supabaseClient;

  JobApplicationNotificationService({required this.supabaseClient});

  Future<void> notifyApplicationStatusChanged({
    required JobApplication application,
    required ApplicationStatus oldStatus,
    required ApplicationStatus newStatus,
  }) async {
    try {
      // Notify candidate
      await _notifyCandidate(
        application: application,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );

      // Notify company
      await _notifyCompany(
        application: application,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );

      // Create notification record in database
      await _createNotificationRecord(
        application: application,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> notifyNewApplication({
    required JobApplication application,
  }) async {
    try {
      // Notify company about new application
      await _notifyCompanyNewApplication(application: application);

      // Create notification record
      final jobRow = await supabaseClient
          .from('jobs_with_stats')
          .select('company_id')
          .eq('id', application.jobId)
          .maybeSingle();
      final companyId = jobRow != null ? jobRow['company_id'] as String? : null;

      await supabaseClient.from('notifications').insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': companyId ?? application.jobId,
        'type': 'new_application',
        'title': JobApplicationTexts.newJobApplicationTitle,
        'message': '${application.candidateName}${JobApplicationTexts.newApplicationMessageSuffix}',
        'data': {
          'application_id': application.id,
          'job_id': application.jobId,
          'candidate_name': application.candidateName,
          'candidate_email': application.candidateEmail,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending new application notification: $e');
    }
  }

  Future<void> _notifyCandidate({
    required JobApplication application,
    required ApplicationStatus oldStatus,
    required ApplicationStatus newStatus,
  }) async {
    String title;
    String message;

    switch (newStatus) {
      case ApplicationStatus.underReview:
        title = JobApplicationTexts.applicationUnderReviewTitle;
        message = JobApplicationTexts.applicationUnderReviewMessage;
        break;
      case ApplicationStatus.accepted:
        title = JobApplicationTexts.applicationAcceptedTitle;
        message = JobApplicationTexts.applicationAcceptedMessage;
        break;
      case ApplicationStatus.rejected:
        title = JobApplicationTexts.applicationUpdateTitle;
        message = JobApplicationTexts.applicationRejectedMessage;
        break;
      default:
        return; // Don't notify for pending status
    }

    try {
      // In a real app, this would send push notifications, emails, etc.
      // For now, we'll just show a local notification
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: _getStatusColor(newStatus),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Create notification record for candidate
      await supabaseClient.from('notifications').insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': application.candidateId,
        'type': 'application_status_changed',
        'title': title,
        'message': message,
        'data': {
          'application_id': application.id,
          'job_id': application.jobId,
          'old_status': oldStatus.name,
          'new_status': newStatus.name,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error notifying candidate: $e');
    }
  }

  Future<void> _notifyCompany({
    required JobApplication application,
    required ApplicationStatus oldStatus,
    required ApplicationStatus newStatus,
  }) async {
    // Only notify company for significant status changes
    if (newStatus != ApplicationStatus.accepted && newStatus != ApplicationStatus.rejected) {
      return;
    }

    String title;
    String message;

    if (newStatus == ApplicationStatus.accepted) {
      title = JobApplicationTexts.candidateAcceptedTitle;
      message = '${JobApplicationTexts.candidateAcceptedMessagePrefix}${application.candidateName}${JobApplicationTexts.candidateAcceptedMessageSuffix}';
    } else {
      title = JobApplicationTexts.candidateRejectedTitle;
      message = '${JobApplicationTexts.candidateRejectedMessagePrefix}${application.candidateName}${JobApplicationTexts.candidateRejectedMessageSuffix}';
    }

    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: _getStatusColor(newStatus),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error notifying company: $e');
    }
  }

  Future<void> _notifyCompanyNewApplication({
    required JobApplication application,
  }) async {
    Get.snackbar(
      JobApplicationTexts.newApplicationReceivedTitle,
      '${application.candidateName}${JobApplicationTexts.newApplicationMessageSuffix}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _createNotificationRecord({
    required JobApplication application,
    required ApplicationStatus oldStatus,
    required ApplicationStatus newStatus,
  }) async {
    try {
      await supabaseClient.from('notifications').insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': application.candidateId,
        'type': 'application_status_changed',
        'title': JobApplicationTexts.applicationStatusUpdatedTitle,
        'message': '${JobApplicationTexts.applicationStatusChangedFromPrefix}${oldStatus.name}${JobApplicationTexts.applicationStatusChangedToConnector}${newStatus.name}',
        'data': {
          'application_id': application.id,
          'job_id': application.jobId,
          'old_status': oldStatus.name,
          'new_status': newStatus.name,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating notification record: $e');
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.accepted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.cancelled:
        return Colors.grey;
    }
  }

  // Get unread notifications for a user
  Future<List<Map<String, dynamic>>> getUnreadNotifications(String userId) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting unread notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting notification count: $e');
      return 0;
    }
  }
}