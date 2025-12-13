import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Modelo de Usuario
class User {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    email: json['email'],
    telefono: json['telefono'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    if (telefono != null) 'telefono': telefono,
  };
}

/// Servicio para gestión de usuarios
class UserService {
  /// Crear un nuevo usuario
  Future<User> createUser(User user) async {
    try {
      final response = await ApiService.post('/users', user.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al crear usuario');
    } catch (e) {
      print('❌ Error en createUser: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Obtener todos los usuarios con paginación
  Future<List<User>> getAllUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService.get('/users?page=$page&limit=$limit');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al obtener usuarios');
    } catch (e) {
      print('❌ Error en getAllUsers: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener un usuario por ID
  Future<User> getUserById(int id) async {
    try {
      final response = await ApiService.get('/users/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Usuario no encontrado');
    } catch (e) {
      print('❌ Error en getUserById: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualizar un usuario
  Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put('/users/$id', updates);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al actualizar usuario');
    } catch (e) {
      print('❌ Error en updateUser: $e');
      throw Exception('Error al actualizar: $e');
    }
  }

  /// Eliminar un usuario
  Future<void> deleteUser(int id) async {
    try {
      final response = await ApiService.delete('/users/$id');

      if (response.statusCode != 200) {
        ApiService.handleHttpError(response);
        throw Exception('Error al eliminar usuario');
      }
    } catch (e) {
      print('❌ Error en deleteUser: $e');
      throw Exception('Error al eliminar: $e');
    }
  }
}