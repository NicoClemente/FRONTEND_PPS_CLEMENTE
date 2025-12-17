import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static String get baseUrl {
    String url = dotenv.env['RENDER_URL'] ?? '';
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    return url;
  }

  static String get apiKey {
    final key = dotenv.env['API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('API_KEY no configurada en .env');
    }
    return key;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, String>> get headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': apiKey,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
    'X-API-KEY': apiKey,
  };

  static void handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage;
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['msg'] ?? errorData['error'] ?? 'Error desconocido';
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('🌐 GET: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en GET: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = '$baseUrl$endpoint';
    print('🌐 POST: $url');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await headers,
        body: jsonEncode(body),
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en POST: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = '$baseUrl$endpoint';
    print('🌐 PUT: $url');
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await headers,
        body: jsonEncode(body),
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en PUT: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint, {dynamic body}) async {
    final url = '$baseUrl$endpoint';
    print('🌐 DELETE: $url');
    
    try {
      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(await headers);
      
      if (body != null) {
        request.body = jsonEncode(body);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en DELETE: $e');
      rethrow;
    }
  }
}