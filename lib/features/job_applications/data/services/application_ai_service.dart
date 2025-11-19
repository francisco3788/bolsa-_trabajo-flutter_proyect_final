import 'dart:convert';
import '../../domain/entities/job_application.dart';
import '../../constants/job_application_texts.dart';

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
      strengths.add(JobApplicationTexts.strengthDetailedCoverLetter);
    }
    if (experienceYears is int && experienceYears >= 3) {
      suggested = 'underReview';
      confidence = 0.75;
      strengths.add(JobApplicationTexts.strengthRelevantExperience);
    }
    if (hasLinkedIn) {
      confidence += 0.05;
      strengths.add(JobApplicationTexts.strengthHasLinkedInProfile);
    }
    if (coverLen < 50) {
      concerns.add(JobApplicationTexts.concernVeryShortCoverLetter);
      confidence -= 0.2;
    }

    final suggestion = {
      'suggested_status': suggested,
      'confidence_score': confidence.clamp(0.0, 1.0),
      'reasoning': JobApplicationTexts.reasoningHeuristicSingle,
      'key_strengths': strengths,
      'key_concerns': concerns,
      'recommended_next_steps': JobApplicationTexts.nextStepsCombined,
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
          'reasoning': JobApplicationTexts.reasoningHeuristicBatch,
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
        'overall_assessment': JobApplicationTexts.overallAssessmentModerate,
        'key_insights': [
          '${JobApplicationTexts.pendingRatePrefix} ${stats['pending']}',
          '${JobApplicationTexts.underReviewPrefix} ${stats['underReview']}',
        ],
        'recommendations': [
          JobApplicationTexts.recommendationPrioritizeUnderReview,
          JobApplicationTexts.recommendationEncourageCoverLetters,
        ],
        'quality_score': 0.65,
        'expected_hiring_success': JobApplicationTexts.expectedHiringSuccessMedium,
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