import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/ai_config.dart';
import '../../domain/entities/ai_generated_job.dart';
import 'ai_remote_datasource.dart';
import '../../constants/ai_texts.dart';

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final http.Client client;
  final String supabaseUrl;
  final String supabaseAnonKey;
  
  // Simple cache to reduce API calls
  final Map<String, List<AiGeneratedJob>> _cache = {};
  DateTime? _lastApiCall;

  AiRemoteDataSourceImpl({
    required this.client,
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
    // Check cache first
    final cacheKey = '${searchQuery}_${location}_${workMode}_${jobType}_$limit';
    if (_cache.containsKey(cacheKey)) {
      print('AI: Returning cached results for: $searchQuery');
      return _cache[cacheKey]!;
    }
    
    // Rate limiting - wait if last call was too recent
    if (_lastApiCall != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall.inSeconds < 10) {
        final waitTime = 10 - timeSinceLastCall.inSeconds;
        print('AI: Rate limiting - waiting $waitTime seconds...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
    
    try {
      // Try OpenAI first (you have it configured)
      return await _generateJobsWithOpenAI(
        searchQuery: searchQuery,
        limit: limit,
        location: location,
        workMode: workMode,
        jobType: jobType,
        cacheKey: cacheKey,
      );
    } catch (e) {
      print('AI: Error with OpenAI: $e');
      try {
        // Fallback to Gemini
        return await _generateJobsWithGemini(
          searchQuery: searchQuery,
          limit: limit,
          location: location,
          workMode: workMode,
          jobType: jobType,
          cacheKey: cacheKey,
        );
      } catch (geminiError) {
        print('AI: Error with Gemini: $geminiError');
        rethrow;
      }
    }
  }
  
  Future<List<AiGeneratedJob>> _generateJobsWithGemini({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
    required String cacheKey,
  }) async {
    print('AI: Generating jobs with Google Gemini for: $searchQuery');
    
    // Use Gemini API key from configuration
    final geminiApiKey = AiConfig.geminiApiKey;
    
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(AiTexts.geminiNotConfiguredError);
    }
    
    final prompt = _buildJobGenerationPrompt(
      searchQuery: searchQuery,
      limit: limit,
      location: location,
      workMode: workMode,
      jobType: jobType,
    );
    
    final response = await client.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('${AiTexts.geminiApiErrorPrefix} ${response.statusCode} - ${response.body}');
    }

    final data = json.decode(response.body);
    final content = data['candidates'][0]['content']['parts'][0]['text'];
    
    // Parse the generated jobs from AI response
    final jobs = _parseGeneratedJobs(content, searchQuery);
    
    // Save to Supabase
    await saveGeneratedJobs(jobs);
    
    // Cache the results
    _cache[cacheKey] = jobs;
    _lastApiCall = DateTime.now();
    
    print('AI: Generated and cached ${jobs.length} jobs with Gemini for: $searchQuery');
    
    return jobs;
  }
  
  Future<List<AiGeneratedJob>> _generateJobsWithOpenAI({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
    required String cacheKey,
  }) async {
    print('AI: Generating jobs with OpenAI for: $searchQuery');
    
    // Use OpenAI API key from configuration
    final openAiApiKey = AiConfig.openAiApiKey;
    
    if (openAiApiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      throw Exception(AiTexts.openAiNotConfiguredError);
    }
    
    final prompt = _buildJobGenerationPrompt(
      searchQuery: searchQuery,
      limit: limit,
      location: location,
      workMode: workMode,
      jobType: jobType,
    );

    final response = await client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a job posting generator. Generate realistic job postings in JSON format.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 429) {
        throw Exception(AiTexts.openAiRateLimitError);
      } else if (response.statusCode == 401) {
        throw Exception(AiTexts.openAiInvalidKeyError);
      } else if (response.statusCode == 500) {
        throw Exception(AiTexts.openAiServerError);
      } else {
        throw Exception('${AiTexts.openAiApiErrorPrefix} ${response.statusCode}');
      }
    }

    final data = json.decode(response.body);
    final content = data['choices'][0]['message']['content'];
    
    // Parse the generated jobs from AI response
    final jobs = _parseGeneratedJobs(content, searchQuery);
    
    // Save to Supabase
    await saveGeneratedJobs(jobs);
    
    // Cache the results
    _cache[cacheKey] = jobs;
    _lastApiCall = DateTime.now();
    
    print('AI: Generated and cached ${jobs.length} jobs with OpenAI for: $searchQuery');
    
    return jobs;
  }

  String _buildJobGenerationPrompt({
    required String searchQuery,
    required int limit,
    String? location,
    String? workMode,
    String? jobType,
  }) {
    return '''
Generate $limit realistic job postings for "$searchQuery" in JSON format.

${AiTexts.promptRequirementsHeader}:
- Each job should have: title, description, company_name, location, work_mode (remote/hybrid/onsite), 
  job_type (full_time/part_time/contract/internship), salary_range (min/max), currency (USD), 
  skills (array), requirements, benefits
- Make descriptions detailed and professional
- Use realistic company names
- Include relevant technical skills
- Make salary ranges realistic for the position and location
${location != null ? '- Location: $location' : ''}
${workMode != null ? '- Work mode: $workMode' : ''}
${jobType != null ? '- Job type: $jobType' : ''}

Return ONLY a valid JSON array with $limit job objects. No additional text.
Example format:
[
  {
    "title": "Senior Flutter Developer",
    "description": "We are looking for an experienced Flutter developer...",
    "company_name": "TechCorp Inc.",
    "location": "San Francisco, CA",
    "work_mode": "remote",
    "job_type": "full_time",
    "salary_min": 120000,
    "salary_max": 180000,
    "currency": "USD",
    "skills": ["Flutter", "Dart", "Firebase", "Git"],
    "requirements": "5+ years of mobile development experience",
    "benefits": "Health insurance, 401k, remote work"
  }
]
''';
  }

  List<AiGeneratedJob> _parseGeneratedJobs(String content, String searchQuery) {
    try {
      final jsonData = json.decode(content);
      final uuid = Uuid();
      
      if (jsonData is! List) {
        throw Exception('${AiTexts.expectedJsonArrayError}, got ${jsonData.runtimeType}');
      }
      
      return jsonData.map<AiGeneratedJob>((jobData) {
        final salaryMin = jobData['salary_min'] ?? (jobData['salary_range'] != null 
            ? int.tryParse(jobData['salary_range'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 50000
            : 50000);
        final salaryMax = jobData['salary_max'] ?? (jobData['salary_range'] != null 
            ? int.tryParse(jobData['salary_range'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 80000
            : 80000);
        
        return AiGeneratedJob(
          id: uuid.v4(),
          title: jobData['title'] ?? AiTexts.defaultTitle,
          description: jobData['description'] ?? AiTexts.defaultDescription,
          companyName: jobData['company_name'] ?? AiTexts.defaultCompanyName,
          location: jobData['location'] ?? AiTexts.defaultLocationRemote,
          workMode: jobData['work_mode'] ?? 'remote',
          jobType: jobData['job_type'] ?? 'full_time',
          salaryMin: salaryMin,
          salaryMax: salaryMax,
          currency: jobData['currency'] ?? AiTexts.defaultCurrencyUSD,
          skills: List<String>.from(jobData['skills'] ?? [AiTexts.defaultSkillGeneric]),
          requirements: jobData['requirements'] ?? AiTexts.requirementsNotSpecified,
          benefits: jobData['benefits'] ?? AiTexts.benefitsNotSpecified,
          aiConfidenceScore: (Random().nextDouble() * 0.3) + 0.7, // 0.7 to 1.0
          aiSearchQuery: searchQuery,
          generatedAt: DateTime.now(),
          isActive: true,
        );
      }).toList();
    } catch (e) {
      print('Error parsing AI response: $e');
      print('Raw content: $content');
      rethrow;
    }
  }

  @override
  Future<List<AiGeneratedJob>> getGeneratedJobs({
    int? limit,
    bool? isActive,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$supabaseUrl/rest/v1/ai_generated_jobs?order=generated_at.desc${limit != null ? '&limit=$limit' : ''}${isActive != null ? '&is_active=eq.$isActive' : ''}'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('${AiTexts.supabaseErrorPrefix} ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return (data as List).map((job) => AiGeneratedJob.fromMap(job)).toList();
    } catch (e) {
      throw Exception('${AiTexts.failedToGetGeneratedJobs}: $e');
    }
  }

  @override
  Future<void> saveGeneratedJobs(List<AiGeneratedJob> jobs) async {
    try {
      final jobsData = jobs.map((job) => job.toMap()).toList();
      
      final response = await client.post(
        Uri.parse('$supabaseUrl/rest/v1/ai_generated_jobs'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: json.encode(jobsData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('${AiTexts.supabaseErrorPrefix} ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('${AiTexts.failedToSaveGeneratedJobs}: $e');
    }
  }

  @override
  Future<void> deactivateJob(String jobId) async {
    try {
      final response = await client.patch(
        Uri.parse('$supabaseUrl/rest/v1/ai_generated_jobs?id=eq.$jobId'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_active': false}),
      );

      if (response.statusCode != 204) {
        throw Exception('${AiTexts.supabaseErrorPrefix} ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('${AiTexts.failedToDeactivateJob}: $e');
    }
  }

  @override
  Future<List<AiGeneratedJob>> searchJobs({
    required String query,
    int? limit,
  }) async {
    try {
      // Search in both title and description
      final response = await client.get(
        Uri.parse('$supabaseUrl/rest/v1/ai_generated_jobs?or=(title.ilike.*$query*,description.ilike.*$query*)&is_active=eq.true&order=ai_confidence_score.desc${limit != null ? '&limit=$limit' : ''}'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('${AiTexts.supabaseErrorPrefix} ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return (data as List).map((job) => AiGeneratedJob.fromMap(job)).toList();
    } catch (e) {
      throw Exception('${AiTexts.failedToSearchJobs}: $e');
    }
  }
}