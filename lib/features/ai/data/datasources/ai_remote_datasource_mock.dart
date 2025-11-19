import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_generated_job.dart';
import 'ai_remote_datasource.dart';
import '../../constants/ai_texts.dart';

/// Mock implementation of AI data source that generates realistic job data
/// without requiring external API calls. This ensures the app works immediately
/// while maintaining the same interface as the real AI implementation.
class AiRemoteDataSourceMock implements AiRemoteDataSource {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final Random _random = Random();
  final Uuid _uuid = Uuid();
  
  // Mock cache to simulate real behavior
  final Map<String, List<AiGeneratedJob>> _cache = {};
  DateTime? _lastApiCall;

  AiRemoteDataSourceMock({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  @override
  Future<List<AiGeneratedJob>> generateJobs({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  }) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 1));
    
    // Check cache first (simulated)
    final cacheKey = '${searchQuery}_${location}_${workMode}_${jobType}_$limit';
    if (_cache.containsKey(cacheKey)) {
      print('AI: Returning cached results for: $searchQuery');
      return _cache[cacheKey]!;
    }
    
    // Rate limiting simulation
    if (_lastApiCall != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall.inSeconds < 5) {
        final waitTime = 5 - timeSinceLastCall.inSeconds;
        print('AI: Rate limiting - waiting $waitTime seconds...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
    
    print('AI: Generating mock jobs for: $searchQuery');
    
    // Generate realistic mock jobs based on search query
    final jobs = _generateMockJobs(
      searchQuery: searchQuery,
      limit: limit,
      location: location,
      workMode: workMode,
      jobType: jobType,
    );
    
    // Simulate saving to Supabase (but don't actually save in mock mode)
    print('AI: Simulating save to Supabase for ${jobs.length} jobs');
    
    // Cache the results
    _cache[cacheKey] = jobs;
    _lastApiCall = DateTime.now();
    
    print('AI: Generated and cached ${jobs.length} mock jobs for: $searchQuery');
    
    return jobs;
  }

  List<AiGeneratedJob> _generateMockJobs({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  }) {
    final jobs = <AiGeneratedJob>[];
    
    final companies = AiTexts.companiesPool;
    final locations = AiTexts.locationsPool;
    final workModes = AiTexts.workModes;
    final jobTypes = AiTexts.jobTypes;
    
    // Skills pool based on search query
    final skillPools = AiTexts.skillPools;
    
    // Determine relevant skills based on search query
    List<String> relevantSkills = ['Software Development', 'Problem Solving', 'Communication'];
    for (var entry in skillPools.entries) {
      if (searchQuery.toLowerCase().contains(entry.key)) {
        relevantSkills = entry.value;
        break;
      }
    }
    
    // Generate jobs
    for (int i = 0; i < limit; i++) {
      final company = companies[_random.nextInt(companies.length)];
      final jobLocation = location ?? locations[_random.nextInt(locations.length)];
      final jobWorkMode = workMode ?? workModes[_random.nextInt(workModes.length)];
      final jobJobType = jobType ?? jobTypes[_random.nextInt(jobTypes.length)];
      
      // Generate realistic salary based on location and role
      int salaryMin = 50000 + (_random.nextInt(20) * 5000); // 50k to 150k
      int salaryMax = salaryMin + (20000 + (_random.nextInt(15) * 10000)); // 20k to 170k range
      
      // Adjust for seniority level
      if (searchQuery.toLowerCase().contains('senior')) {
        salaryMin += 30000;
        salaryMax += 40000;
      } else if (searchQuery.toLowerCase().contains('junior') || searchQuery.toLowerCase().contains('entry')) {
        salaryMin -= 20000;
        salaryMax -= 25000;
      }
      
      // Ensure minimum salary
      salaryMin = salaryMin.clamp(35000, 300000);
      salaryMax = salaryMax.clamp(salaryMin + 10000, 500000);
      
      // Generate job title variations
      String title = searchQuery;
      if (searchQuery.toLowerCase().contains('developer')) {
        final prefixes = ['Senior', 'Junior', 'Mid-Level', 'Lead', 'Full-Stack', 'Front-End', 'Back-End'];
        final prefix = prefixes[_random.nextInt(prefixes.length)];
        title = '$prefix $searchQuery';
      }
      
      final job = AiGeneratedJob(
        id: _uuid.v4(),
        title: title,
        description: AiTexts.mockJobDescription(searchQuery, company),
        companyName: company,
        location: jobLocation,
        workMode: jobWorkMode,
        jobType: jobJobType,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        currency: AiTexts.defaultCurrencyUSD,
        skills: relevantSkills.take(3 + _random.nextInt(3)).toList(),
        requirements: AiTexts.mockRequirementsText(2 + _random.nextInt(8)),
        benefits: AiTexts.mockBenefitsText(),
        aiConfidenceScore: 0.85 + (_random.nextDouble() * 0.15), // 0.85 to 1.0
        aiSearchQuery: searchQuery,
        generatedAt: DateTime.now().subtract(Duration(minutes: _random.nextInt(60))),
        isActive: true,
      );
      
      jobs.add(job);
    }
    
    return jobs;
  }

  @override
  Future<List<AiGeneratedJob>> getGeneratedJobs({
    int? limit,
    bool? isActive,
  }) async {
    // Return some mock data for testing
    final mockJobs = _generateMockJobs(
      searchQuery: 'Software Developer',
      limit: limit ?? 10,
    );
    
    return isActive == null 
        ? mockJobs 
        : mockJobs.where((job) => job.isActive == isActive).toList();
  }

  @override
  Future<void> saveGeneratedJobs(List<AiGeneratedJob> jobs) async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    print('AI: Simulated save of ${jobs.length} jobs to Supabase');
  }

  @override
  Future<void> deactivateJob(String jobId) async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    print('AI: Simulated deactivation of job $jobId');
  }

  @override
  Future<List<AiGeneratedJob>> searchJobs({
    required String query,
    int? limit,
  }) async {
    // Generate mock search results
    final results = _generateMockJobs(
      searchQuery: query,
      limit: limit ?? 10,
    );
    
    return results;
  }
}