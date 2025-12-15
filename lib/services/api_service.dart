import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiService {
  static String get baseUrl {
    String url = dotenv.env['RENDER_URL'] ?? '';
    
    // Agregar https:// si no está presente
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

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-API-KEY': apiKey,
  };

  // Manejo de errores HTTP
  static void handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage;
      
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] ?? errorData['message'] ?? 'Error desconocido';
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
      
      throw Exception(errorMessage);
    }
  }

  // GET
  static Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('🌐 GET: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en GET: $e');
      rethrow;
    }
  }

  // POST
  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = '$baseUrl$endpoint';
    print('🌐 POST: $url');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en POST: $e');
      rethrow;
    }
  }

  // PUT
  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = '$baseUrl$endpoint';
    print('🌐 PUT: $url');
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en PUT: $e');
      rethrow;
    }
  }

  // DELETE
  static Future<http.Response> delete(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('🌐 DELETE: $url');
    
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en DELETE: $e');
      rethrow;
    }
  }
}