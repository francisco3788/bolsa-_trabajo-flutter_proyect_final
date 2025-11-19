import 'dart:convert';
import '../../domain/entities/job_application.dart';

class ApplicationAIService {
  final String apiKey;
  
  ApplicationAIService({required this.apiKey});

  Future<Map<String, dynamic>> suggestApplicationStatus({
    required JobApplication application,
    required String jobTitle,
    required String jobDescription,
    required String companyRequirements,
  }) async {
    // Stubbed logic without external dependencies
    final coverLen = (application.coverLetter ?? '').length;
    final hasLinkedIn = (application.metadata ?? {})['linkedin'] != null;
    final experienceYears = (application.metadata ?? {})['experience_years'] ?? 0;

    String suggested = 'pending';
    double confidence = 0.6;
    final strengths = <String>[];
    final concerns = <String>[];

    if (coverLen >= 300) {
      suggested = 'underReview';
      confidence = 0.7;
      strengths.add('Detailed cover letter');
    }
    if (experienceYears is int && experienceYears >= 3) {
      suggested = 'underReview';
      confidence = 0.75;
      strengths.add('Relevant experience');
    }
    if (hasLinkedIn) {
      confidence += 0.05;
      strengths.add('Has LinkedIn profile');
    }
    if (coverLen < 50) {
      concerns.add('Very short cover letter');
      confidence -= 0.2;
    }

    final suggestion = {
      'suggested_status': suggested,
      'confidence_score': confidence.clamp(0.0, 1.0),
      'reasoning': 'Heuristic based on cover letter length and experience.',
      'key_strengths': strengths,
      'key_concerns': concerns,
      'recommended_next_steps': 'Proceed to human review if underReview; request more info if pending.',
    };

    return {
      'success': true,
      'suggestion': suggestion,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> batchSuggestApplications({
    required List<JobApplication> applications,
    required String jobTitle,
    required String jobDescription,
    required String companyRequirements,
  }) async {
    // Simple batched heuristic
    return applications.map((app) {
      final coverLen = (app.coverLetter ?? '').length;
      final experienceYears = (app.metadata ?? {})['experience_years'] ?? 0;
      String suggested = 'pending';
      double confidence = 0.6;
      if (coverLen >= 300 || (experienceYears is int && experienceYears >= 3)) {
        suggested = 'underReview';
        confidence = 0.75;
      }
      return {
        'success': true,
        'application_id': app.id,
        'suggestion': {
          'suggested_status': suggested,
          'confidence_score': confidence,
          'reasoning': 'Heuristic batch suggestion',
          'key_strengths': [],
          'key_concerns': [],
        }
      };
    }).toList();
  }

  String _cleanJsonResponse(String response) {
    // Remove markdown code blocks if present
    return response
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
  }

  Future<Map<String, dynamic>> generateApplicationInsights({
    required List<JobApplication> applications,
    required String jobTitle,
  }) async {
    try {
      final stats = {
        'total': applications.length,
        'pending': applications.where((a) => a.status == ApplicationStatus.pending).length,
        'underReview': applications.where((a) => a.status == ApplicationStatus.underReview).length,
        'accepted': applications.where((a) => a.status == ApplicationStatus.accepted).length,
        'rejected': applications.where((a) => a.status == ApplicationStatus.rejected).length,
      };

      final insights = {
        'overall_assessment': 'Moderate application quality',
        'key_insights': [
          'Pending rate: ${stats['pending']}',
          'Under review: ${stats['underReview']}',
        ],
        'recommendations': [
          'Prioritize underReview applications for human screening',
          'Encourage candidates to provide detailed cover letters',
        ],
        'quality_score': 0.65,
        'expected_hiring_success': 'medium',
      };

      return {
        'success': true,
        'insights': insights,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}