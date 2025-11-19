import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to verify Gemini API key
void main() async {
  const apiKey = 'AIzaSyBo1x2hOXsKh4uKaynIqV0pPHUZSS6ZaB8'; // Your Gemini API key
  
  print('Testing Gemini API key...');
  
  try {
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Generate 1 simple job posting for "Software Developer" in JSON format with title, company_name, location, salary_min, salary_max, currency.',
              },
            ],
          },
        ],
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('✅ Gemini API key is working!');
    } else {
      print('❌ Gemini API key failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error testing Gemini API: $e');
  }
}