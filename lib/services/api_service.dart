import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio HTTP base para todas las peticiones a la API
class ApiService {
  // URL base de la API - desde constantes de compilación
  static String get baseUrl {
    const apiUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://localhost:3000/api/v1',
    );
    return apiUrl;
  }

  // API_KEY para autenticación - desde constantes de compilación
  static String get apiKey {
    const key = String.fromEnvironment(
      'API_KEY',
      defaultValue: '', // Vacío por defecto para seguridad
    );
    return key;
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
      print('🌐 GET: $url');
      
      final response = await http.get(url, headers: headers);
      
      print('📥 Response: ${response.statusCode}');
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
      print('🌐 POST: $url');
      print('📤 Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        url,
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

  /// PUT request
  static Future<http.Response> put(String endpoint, dynamic body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT: $url');
      print('📤 Body: ${jsonEncode(body)}');
      
      final response = await http.put(
        url,
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

  /// DELETE request
  static Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE: $url');
      
      final response = await http.delete(url, headers: headers);
      
      print('📥 Response: ${response.statusCode}');
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