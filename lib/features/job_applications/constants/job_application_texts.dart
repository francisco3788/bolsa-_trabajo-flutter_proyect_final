class JobApplicationTexts {
  // Screen titles
  static const jobApplicationTitle = 'Job Application';
  static const companyDashboardTitle = 'Applications Dashboard';
  static const myApplicationsTitle = 'My Applications';

  // Form labels
  static const applyingFor = 'Applying for';
  static const coverLetter = 'Cover Letter';
  static const coverLetterLabel = 'Cover Letter';
  static const coverLetterHint = 'Tell us why you are a good fit for this position...';
  static const coverLetterRequired = 'Cover letter is required';
  static const coverLetterTooShort = 'Cover letter must be at least 50 characters';
  static const additionalInfo = 'Additional Information';
  static const phoneNumber = 'Phone Number';
  static const linkedInProfile = 'LinkedIn Profile';
  static const yearsExperience = 'Years of Experience';

  // Application status
  static const allStatus = 'All';
  static const pendingStatus = 'Pending';
  static const underReviewStatus = 'Under Review';
  static const acceptedStatus = 'Accepted';
  static const rejectedStatus = 'Rejected';
  static const cancelledStatus = 'Cancelled';

  // Actions
  static const submitApplication = 'Submit Application';
  static const searchApplications = 'Search applications...';
  static const markUnderReview = 'Mark Under Review';
  static const acceptApplication = 'Accept';
  static const rejectApplication = 'Reject';
  static const confirm = 'Confirm';
  static const cancel = 'Cancel';
  static const refresh = 'Refresh';

  // Messages
  static const applicationSubmitted = 'Application submitted successfully!';
  static const pleaseCompleteForm = 'Please complete the form correctly';
  static const mustBeLoggedIn = 'You must be logged in to apply';
  static const noApplications = 'No applications found';
  static const totalApplications = 'Total';
  static const pendingApplications = 'Pending';
  static const acceptedApplications = 'Accepted';
  static const reviewNotes = 'Review Notes';
  static const reviewNotesHint = 'Add your review notes here...';

  // Dialog titles and messages
  static const markUnderReviewTitle = 'Mark as Under Review';
  static const acceptApplicationTitle = 'Accept Application';
  static const rejectApplicationTitle = 'Reject Application';
  static const updateStatus = 'Update Status';
  static const updateStatusMessage = 'Are you sure you want to update this application status?';
  static const underReviewMessage = 'This will mark the application as under review.';
  static const acceptMessage = 'This will accept the candidate for the position.';
  static const rejectMessage = 'This will reject the application.';

  // Stats
  static const totalApplicationsStat = 'Total Applications';
  static const pendingApplicationsStat = 'Pending Review';
  static const underReviewApplicationsStat = 'Under Review';
  static const acceptedApplicationsStat = 'Accepted';
  static const rejectedApplicationsStat = 'Rejected';
  static const aiInsightsTitle = 'AI Insights';
  static const aiGenerateInsights = 'Generate Insights';
  static const aiBatchSuggest = 'Batch Suggestions';
  static const aiInsightsOverall = 'Overall Assessment';
  static const aiInsightsRecommendations = 'Recommendations';
  static const cancelledApplicationsStat = 'Cancelled';
  static const errorTitle = 'Error';
  static const successTitle = 'Success';
  static const aiSuggestionTitle = 'AI Suggestion';
  static const aiRecommendationTitle = 'AI Recommendation';
  static const aiSuggestionGenerated = 'Status recommendation generated';
  static const aiInsightsGenerated = 'Analytics generated successfully';
  static const statusUpdated = 'Application status updated!';
  static const regenerate = 'Regenerate';
  static const clear = 'Clear';
  static const recommendedStatus = 'Recommended Status';
  static const confidence = 'Confidence';

  // AI suggestions UI
  static const aiStatusSuggestionTitle = 'AI Status Suggestion';
  static const aiPoweredRecommendationsIntro = 'Get AI-powered recommendations for this application';
  static const getAiSuggestion = 'Get AI Suggestion';
  static const reasoningTitle = 'Reasoning';
  static const keyStrengthsTitle = 'Key Strengths';
  static const keyConcernsTitle = 'Key Concerns';
  static const recommendedNextStepsTitle = 'Recommended Next Steps';

  // Common labels
  static const applicationDetailsTitle = 'Application Details';
  static const positionLabel = 'Position:';
  static const companyLabel = 'Company:';
  static const appliedLabel = 'Applied:';
  static const statusLabel = 'Status:';
  static const updatedLabel = 'Updated:';
  static const yourCoverLetterTitle = 'Your Cover Letter:';
  static const close = 'Close';
  static const notificationsTooltip = 'Notifications';
  static const qualityLabel = 'Quality:';
  static const startApplyingToJobsHint = 'Start applying to jobs to see them here';

  // Error prefixes for snackbars
  static const failedToApplyPrefix = 'Failed to apply:';
  static const failedToLoadApplicationsPrefix = 'Failed to load applications:';
  static const failedToLoadCompanyApplicationsPrefix = 'Failed to load company applications:';
  static const failedToUpdateStatusPrefix = 'Failed to update status:';
  static const failedToLoadStatsPrefix = 'Failed to load stats:';

  // AI service/messages
  static const aiServiceNotAvailable = 'AI service not available';
  static const aiSuggestionErrorPrefix = 'AI suggestion error:';
  static const failedToGenerateAiSuggestion = 'Failed to generate AI suggestion';
  static const failedToGenerateInsights = 'Failed to generate insights';
  static const applicationNotFound = 'Application not found';
  static const aiInsightsErrorPrefix = 'AI insights error:';

  // Candidate card labels
  static const applicationHeaderTitle = 'Application';
  static const applicationIdPrefix = 'Application ID:';
  static const tapForDetails = 'Tap for details';
  static const appliedPrefix = 'Applied';

  // Relative time helpers
  static String relativeDays(int days) => '$days days ago';
  static String relativeHours(int hours) => '$hours hours ago';
  static String relativeMinutes(int minutes) => '$minutes minutes ago';
  static const justNow = 'Just now';

  // AI Insights content
  static const overallAssessmentModerate = 'Moderate application quality';
  static const pendingRatePrefix = 'Pending rate:';
  static const underReviewPrefix = 'Under review:';
  static const recommendationPrioritizeUnderReview = 'Prioritize underReview applications for human screening';
  static const recommendationEncourageCoverLetters = 'Encourage candidates to provide detailed cover letters';
  static const expectedHiringSuccessMedium = 'medium';
  static const strengthDetailedCoverLetter = 'Detailed cover letter';
  static const strengthRelevantExperience = 'Relevant experience';
  static const strengthHasLinkedInProfile = 'Has LinkedIn profile';
  static const concernVeryShortCoverLetter = 'Very short cover letter';
  static const reasoningHeuristicSingle = 'Heuristic based on cover letter length and experience.';
  static const reasoningHeuristicBatch = 'Heuristic batch suggestion';
  static const nextStepsCombined = 'Proceed to human review if underReview; request more info if pending.';

  // Notifications
  static const newJobApplicationTitle = 'New Job Application';
  static const newApplicationReceivedTitle = 'New Application Received';
  static const newApplicationMessageSuffix = ' has applied for your job posting';
  static const applicationUnderReviewTitle = 'Application Under Review';
  static const applicationUnderReviewMessage = 'Your application for the position is being reviewed by the hiring team.';
  static const applicationAcceptedTitle = 'Application Accepted!';
  static const applicationAcceptedMessage = 'Congratulations! Your application has been accepted. The company will contact you soon.';
  static const applicationUpdateTitle = 'Application Update';
  static const applicationRejectedMessage = 'Thank you for your application. Unfortunately, we have decided to move forward with other candidates.';
  static const candidateAcceptedTitle = 'Candidate Accepted';
  static const candidateAcceptedMessagePrefix = 'You have accepted ';
  static const candidateAcceptedMessageSuffix = "'s application.";
  static const candidateRejectedTitle = 'Candidate Rejected';
  static const candidateRejectedMessagePrefix = 'You have rejected ';
  static const candidateRejectedMessageSuffix = "'s application.";
  static const applicationStatusUpdatedTitle = 'Application Status Updated';
  static const applicationStatusChangedFromPrefix = 'Your application status changed from ';
  static const applicationStatusChangedToConnector = ' to ';
}