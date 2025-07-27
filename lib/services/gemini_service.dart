import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // static const String _apiKey = ; // Replace with your actual API key
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String?> generateAnswer(
      String question, String userAnswer, String subject, String topic) async {
    try {
      final prompt = _buildPrompt(question, userAnswer, subject, topic);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
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
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractAnswer(data);
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return null;
    }
  }

  static String _buildPrompt(
      String question, String userAnswer, String subject, String topic) {
    return '''
You are an expert interviewer and career coach specializing in $subject with focus on $topic.

Question: $question
User's Answer: $userAnswer

Please provide a comprehensive analysis and feedback on the user's answer. Include:

1. **Answer Quality Assessment** (1-2 sentences)
2. **Key Points Covered** (bullet points)
3. **Areas for Improvement** (if any)
4. **Expert Insights** (additional knowledge or tips)
5. **Sample Answer** (a well-structured response)

Keep the response professional, constructive, and educational. Focus on helping the user improve their interview skills and knowledge.

Format your response in a clear, structured manner.
''';
  }

  static String? _extractAnswer(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>;
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          return parts[0]['text'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error extracting answer: $e');
      return null;
    }
  }
}
