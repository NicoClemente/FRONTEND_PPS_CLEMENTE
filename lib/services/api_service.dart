import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio HTTP base para todas las peticiones a la API
/// Incluye automáticamente la API_KEY en cada request
class ApiService {
  // URL base de la API
  static String get baseUrl {
    final url = dotenv.env['RENDER_URL'] ?? 'localhost:3000/api/v1';
    // Asegurarse de que tenga el protocolo correcto
    if (url.startsWith('localhost')) {
      return 'http://$url';
    }
    return url.startsWith('http') ? url : 'https://$url';
  }

  // API_KEY para autenticación
  static String get apiKey {
    return dotenv.env['API_KEY'] ?? '';
  }

  // Headers comunes para todas las peticiones
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-API-KEY': apiKey,
  };

  /// GET request
  static Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 GET: $url'); // Debug
      
      final response = await http.get(url, headers: headers);
      
      print('📥 Response: ${response.statusCode}'); // Debug
      return response;
    } catch (e) {
      print('❌ Error en GET: $e');
      rethrow;
    }
  }

  /// POST request
  static Future<http.Response> post(String endpoint, dynamic body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST: $url'); // Debug
      print('📤 Body: ${jsonEncode(body)}'); // Debug
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response: ${response.statusCode}'); // Debug
      return response;
    } catch (e) {
      print('❌ Error en POST: $e');
      rethrow;
    }
  }

  /// PUT request
  static Future<http.Response> put(String endpoint, dynamic body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT: $url'); // Debug
      print('📤 Body: ${jsonEncode(body)}'); // Debug
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response: ${response.statusCode}'); // Debug
      return response;
    } catch (e) {
      print('❌ Error en PUT: $e');
      rethrow;
    }
  }

  /// DELETE request
  static Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE: $url'); // Debug
      
      final response = await http.delete(url, headers: headers);
      
      print('📥 Response: ${response.statusCode}'); // Debug
      return response;
    } catch (e) {
      print('❌ Error en DELETE: $e');
      rethrow;
    }
  }

  /// Manejo de errores HTTP
  static void handleHttpError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('API_KEY inválida o faltante');
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado');
    } else if (response.statusCode == 404) {
      throw Exception('Recurso no encontrado');
    } else if (response.statusCode >= 500) {
      throw Exception('Error del servidor');
    } else if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error en la petición');
    }
  }
}