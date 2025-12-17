import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  /// Registrar usuario
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? telefono,
  }) async {
    try {
      final body = {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        if (telefono != null) 'telefono': telefono,
      };

      final url = '${ApiService.baseUrl.replaceAll('/api/v1', '')}/auth/register';
      print('🌐 POST REGISTER: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['token'] != null) {
          await ApiService.saveToken(jsonResponse['token']);
        }

        return {
          'success': true,
          'user': UserModel.fromJson(jsonResponse['user']),
          'token': jsonResponse['token'],
        };
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al registrar usuario');
    } catch (e) {
      print('❌ Error en register: $e');
      throw Exception('Error al registrar: $e');
    }
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
      };

      final url = '${ApiService.baseUrl.replaceAll('/api/v1', '')}/auth/login';
      print('🌐 POST LOGIN: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['token'] != null) {
          await ApiService.saveToken(jsonResponse['token']);
        }

        return {
          'success': true,
          'user': UserModel.fromJson(jsonResponse['user']),
          'token': jsonResponse['token'],
        };
      }

      ApiService.handleHttpError(response);
      throw Exception('Credenciales inválidas');
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await ApiService.removeToken();
  }

  /// Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtener perfil
  Future<UserModel> getProfile() async {
    try {
      final url = '${ApiService.baseUrl.replaceAll('/api/v1', '')}/auth/profile';
      final token = await ApiService.getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return UserModel.fromJson(jsonResponse['user']);
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al obtener perfil');
    } catch (e) {
      print('❌ Error en getProfile: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}