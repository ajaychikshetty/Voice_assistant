import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'http://192.168.0.105:8000'; // Replace with your backend URL

  Future<String> generateResponse(String topic) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-response'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'topic': topic}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response']['text']; // Extract the 'text' field
    } else {
      throw Exception('Failed to generate response');
    }
  }
}
