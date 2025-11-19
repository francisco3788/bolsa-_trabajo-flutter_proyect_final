import 'package:flutter/material.dart';

import '../../domain/entities/job_application.dart';
import '../../constants/job_application_texts.dart';

class CandidateApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;

  const CandidateApplicationCard({
    Key? key,
    required this.application,
    required this.onTap,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildJobInfo(),
              const SizedBox(height: 12),
              _buildStatus(),
              if (application.notes != null) ...[
                const SizedBox(height: 12),
                _buildReviewNotes(),
              ],
              const SizedBox(height: 8),
              _buildFooter(),
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
                JobApplicationTexts.applicationHeaderTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                application.candidateEmail,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildJobInfo() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${JobApplicationTexts.appliedPrefix} ${_formatDate(application.appliedAt)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    Color color;
    String text;
    IconData icon;

    switch (application.status) {
      case ApplicationStatus.pending:
        color = Colors.orange;
        text = JobApplicationTexts.pendingStatus;
        icon = Icons.pending;
        break;
      case ApplicationStatus.underReview:
        color = Colors.blue;
        text = JobApplicationTexts.underReviewStatus;
        icon = Icons.visibility;
        break;
      case ApplicationStatus.accepted:
        color = Colors.green;
        text = JobApplicationTexts.acceptedStatus;
        icon = Icons.check_circle;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        text = JobApplicationTexts.rejectedStatus;
        icon = Icons.cancel;
        break;
      case ApplicationStatus.cancelled:
        color = Colors.grey;
        text = JobApplicationTexts.cancelledStatus;
        icon = Icons.remove_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (application.status) {
      case ApplicationStatus.pending:
        color = Colors.orange;
        text = JobApplicationTexts.pendingStatus;
        break;
      case ApplicationStatus.underReview:
        color = Colors.blue;
        text = JobApplicationTexts.underReviewStatus;
        break;
      case ApplicationStatus.accepted:
        color = Colors.green;
        text = JobApplicationTexts.acceptedStatus;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        text = JobApplicationTexts.rejectedStatus;
        break;
      case ApplicationStatus.cancelled:
        color = Colors.grey;
        text = JobApplicationTexts.cancelledStatus;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildReviewNotes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                JobApplicationTexts.reviewNotes,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            application.notes!,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${JobApplicationTexts.applicationIdPrefix} ${application.id.substring(0, 8)}...',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
        Text(
          JobApplicationTexts.tapForDetails,
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return JobApplicationTexts.relativeDays(difference.inDays);
    } else if (difference.inHours > 0) {
      return JobApplicationTexts.relativeHours(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return JobApplicationTexts.relativeMinutes(difference.inMinutes);
    } else {
      return JobApplicationTexts.justNow;
    }
  }
}