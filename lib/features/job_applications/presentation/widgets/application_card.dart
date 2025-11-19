import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/job_application_texts.dart';
import '../../domain/entities/job_application.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final Function(ApplicationStatus, String?) onStatusUpdate;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: _buildHeader(),
        subtitle: _buildSubtitle(),
        children: [
          _buildDetails(),
          _buildActions(),
        ],
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
                application.candidateName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Applied: ${_formatDate(application.appliedAt)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        if (application.statusUpdatedAt != null) ...[
          Text(
            'Updated: ${_formatDate(application.statusUpdatedAt!)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip() {
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
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            JobApplicationTexts.coverLetter,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              application.coverLetter ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (application.metadata != null && (application.metadata as Map).isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              JobApplicationTexts.additionalInfo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildMetadata(),
          ],
          if (application.notes != null) ...[
            const SizedBox(height: 16),
            Text(
              JobApplicationTexts.reviewNotes,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                application.notes!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (application.metadata ?? {}).entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '${_formatFieldName(entry.key)}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entry.value.toString()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    if (application.status == ApplicationStatus.accepted || 
        application.status == ApplicationStatus.rejected) {
      return Container(); // No actions for final statuses
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (application.status == ApplicationStatus.pending) ...[
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text(JobApplicationTexts.markUnderReview),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showStatusUpdateDialog(ApplicationStatus.underReview),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (application.status == ApplicationStatus.underReview) ...[
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text(JobApplicationTexts.acceptApplication),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showStatusUpdateDialog(ApplicationStatus.accepted),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text(JobApplicationTexts.rejectApplication),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () => _showStatusUpdateDialog(ApplicationStatus.rejected),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusUpdateDialog(ApplicationStatus newStatus) async {
    final TextEditingController notesController = TextEditingController();
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(_getDialogTitle(newStatus)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getDialogMessage(newStatus)),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: JobApplicationTexts.reviewNotes,
                hintText: JobApplicationTexts.reviewNotesHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(JobApplicationTexts.cancel),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getDialogColor(newStatus),
            ),
            child: const Text(JobApplicationTexts.confirm),
          ),
        ],
      ),
    );

    if (result == true) {
      onStatusUpdate(newStatus, notesController.text);
    }
  }

  String _getDialogTitle(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.underReview:
        return JobApplicationTexts.markUnderReviewTitle;
      case ApplicationStatus.accepted:
        return JobApplicationTexts.acceptApplicationTitle;
      case ApplicationStatus.rejected:
        return JobApplicationTexts.rejectApplicationTitle;
      default:
        return JobApplicationTexts.updateStatus;
    }
  }

  String _getDialogMessage(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.underReview:
        return JobApplicationTexts.underReviewMessage;
      case ApplicationStatus.accepted:
        return JobApplicationTexts.acceptMessage;
      case ApplicationStatus.rejected:
        return JobApplicationTexts.rejectMessage;
      default:
        return JobApplicationTexts.updateStatusMessage;
    }
  }

  Color _getDialogColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.accepted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFieldName(String field) {
    return field.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}