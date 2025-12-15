import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio HTTP base para todas las peticiones a la API
class ApiService {
  // URL base de la API desde .env
  static String get baseUrl {
    final url = dotenv.env['RENDER_URL'] ?? '';
    // Asegurar que tiene el protocolo
    if (!url.startsWith('http')) {
      return 'https://$url';
    }
    return url;
  }

  // API_KEY desde .env
  static String get apiKey {
    final key = dotenv.env['API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'API_KEY no configurada. Por favor:\n'
        '1. Crea un archivo .env en la raíz del proyecto\n'
        '2. Agrega: API_KEY=tu_api_key_aqui\n'
        '3. Asegúrate de que .env esté en .gitignore'
      );
    }
    return key;
  }

  // Headers comunes para todas las peticiones
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-KEY': apiKey,
  };

  /// GET request
  static Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      // ✅ SEGURO: Solo loggear la URL, NO la API_KEY
      print('🌐 GET: $url');
      
      final response = await http.get(url, headers: headers);
      
      print('📥 Response: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error body: ${response.body}');
      }
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
      
      // ✅ SEGURO: Solo loggear URL y body, NO la API_KEY
      print('🌐 POST: $url');
      print('📤 Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error body: ${response.body}');
      }
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
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error en la petición');
      } catch (e) {
        throw Exception('Error en la petición: ${response.statusCode}');
      }
    }
  }
}