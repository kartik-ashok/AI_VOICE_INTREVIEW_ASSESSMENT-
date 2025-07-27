import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiApi {
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  static final String? _apiKey =
      dotenv.env['GEMINI_API_KEY']; // Or use dotenv.env['GEMINI_API_KEY']

  static Future<String> generateContent(String prompt) async {
    final url = Uri.parse("$_baseUrl?key=$_apiKey");

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // For debugging
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          "No response";
    } else {
      throw Exception("Failed: ${response.statusCode}, ${response.body}");
    }
  }
}
