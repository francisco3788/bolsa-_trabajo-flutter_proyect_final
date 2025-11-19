import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/job_application_texts.dart';
import '../controllers/job_application_controller.dart';

class AISuggestionsWidget extends StatelessWidget {
  final String applicationId;
  final String jobTitle;
  final String jobDescription;
  final String companyRequirements;

  const AISuggestionsWidget({
    Key? key,
    required this.applicationId,
    required this.jobTitle,
    required this.jobDescription,
    required this.companyRequirements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicationController>();
    
    return Obx(() {
      final suggestion = controller.getAISuggestionForApp(applicationId);
      
      if (suggestion == null) {
        return _buildEmptyState(controller);
      }

      return _buildSuggestionCard(suggestion, controller);
    });
  }

  Widget _buildEmptyState(JobApplicationController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              size: 48,
              color: Colors.blue[400],
            ),
            const SizedBox(height: 12),
            Text(
              'AI Status Suggestion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get AI-powered recommendations for this application',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => controller.isAISuggesting.value
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Get AI Suggestion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _generateSuggestion(controller),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion, JobApplicationController controller) {
    final status = suggestion['suggested_status'] ?? 'pending';
    final confidence = (suggestion['confidence_score'] ?? 0.0) as double;
    final reasoning = suggestion['reasoning'] ?? '';
    final strengths = List<String>.from(suggestion['key_strengths'] ?? []);
    final concerns = List<String>.from(suggestion['key_concerns'] ?? []);
    final nextSteps = suggestion['recommended_next_steps'] ?? '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.blue[400],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Recommendation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                _buildConfidenceBadge(confidence),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRecommendation(status, confidence),
            const SizedBox(height: 12),
            _buildSection('Reasoning', reasoning),
            if (strengths.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildListSection('Key Strengths', strengths, Colors.green),
            ],
            if (concerns.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildListSection('Key Concerns', concerns, Colors.orange),
            ],
            if (nextSteps.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSection('Recommended Next Steps', nextSteps),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate'),
                    onPressed: () => _generateSuggestion(controller),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => controller.clearAISuggestions(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).round();
    final color = confidence >= 0.8 ? Colors.green : 
                  confidence >= 0.6 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusRecommendation(String status, double confidence) {
    final color = _getStatusColor(status);
    final statusText = _formatStatusText(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(status), color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Status: $statusText',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Confidence: ${(confidence * 100).round()}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 2),
          child: Row(
            children: [
              Icon(Icons.circle, size: 6, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _generateSuggestion(JobApplicationController controller) async {
    // Find the application in the controller
    final application = controller.companyApplications.firstWhere(
      (app) => app.id == applicationId,
      orElse: () => controller.candidateApplications.firstWhere(
        (app) => app.id == applicationId,
        orElse: () => throw Exception('Application not found'),
      ),
    );

    await controller.getAISuggestionForApplication(
      application: application,
      jobTitle: jobTitle,
      jobDescription: jobDescription,
      companyRequirements: companyRequirements,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'under_review':
        return Icons.visibility;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatusText(String status) {
    return status.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}