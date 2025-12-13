import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/actor_model.dart';
import 'api_service.dart';

class ActorService {
  /// Obtener actores populares con paginación
  Future<List<Actor>> getPopularActors({int page = 1, int limit = 50}) async {
    try {
      final response = await ApiService.get('/actores?page=$page&limit=$limit');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((actorJson) => Actor.fromJson(actorJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar actores');
    } catch (e) {
      print('❌ Error en getPopularActors: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Buscar actores por nombre
  Future<List<Actor>> searchActors(String query, {int page = 1}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await ApiService.get('/actores/name?nombre=$encodedQuery&page=$page');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['data'] == null || (jsonResponse['data'] as List).isEmpty) {
          return [];
        }

        return (jsonResponse['data'] as List)
            .map((actorJson) => Actor.fromJson(actorJson))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error en la búsqueda');
    } catch (e) {
      print('❌ Error en searchActors: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener detalles de un actor por ID
  Future<Actor> getActorDetails(int id) async {
    try {
      final response = await ApiService.get('/actores/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Actor.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar detalles del actor');
    } catch (e) {
      print('❌ Error en getActorDetails: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}