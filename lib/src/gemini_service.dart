import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = ''; // Directly place your API key here


  Future<String> sendMessage(String userMessage) async {
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": userMessage}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Error: ${response.body}";
    }
  }

  sendMessageStream(String userMessage) {}
}
