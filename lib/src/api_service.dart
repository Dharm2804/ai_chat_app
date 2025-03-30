import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<void> saveChatMessage(String role, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role, 'text': text}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save chat message');
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/chat'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {
        'role': item['role'],
        'text': item['text'],
        'timestamp': item['timestamp'],
      }).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }
}