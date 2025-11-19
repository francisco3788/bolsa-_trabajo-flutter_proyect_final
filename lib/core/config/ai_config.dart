import 'app_env.dart';

class AiConfig {
  // Google Gemini API Configuration
  static String get geminiApiKey => AppEnv.geminiApiKey.isNotEmpty ? AppEnv.geminiApiKey : 'YOUR_GEMINI_API_KEY_HERE';
  static const String geminiModel = 'gemini-pro';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  // OpenAI API Configuration (fallback)
  static String get openAiApiKey => AppEnv.openAiApiKey.isNotEmpty ? AppEnv.openAiApiKey : 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiModel = 'gpt-3.5-turbo';
  
  // Rate limiting configuration
  static const int minSecondsBetweenCalls = 10;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  
  // Cache configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
}