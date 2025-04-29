import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this URL to match your Python backend when it's ready
  static const String baseUrl = 'http://localhost:8000';

  // For Android emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> validateCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'errors': ['Server returned ${response.statusCode}'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errors': ['Connection error: $e'],
      };
    }
  }
}
