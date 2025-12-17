import 'dart:convert';
import 'api_service.dart';

/// Modelo de Favorito
class Favorite {
  final int? id;
  final int userId;
  final String itemType; // 'movie', 'series', 'actor'
  final String itemId;
  final String? tmdbId;
  final String? createdAt;
  final dynamic details; // Detalles del item cuando se usa /detailed

  Favorite({
    this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.tmdbId,
    this.createdAt,
    this.details,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'],
    userId: json['user_id'],
    itemType: json['item_type'],
    itemId: json['item_id'].toString(),
    tmdbId: json['tmdb_id']?.toString(),
    createdAt: json['created_at'],
    details: json['details'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'item_type': itemType,
    'item_id': itemId,
    if (tmdbId != null) 'tmdb_id': tmdbId,
  };
}

/// Servicio para gestión de favoritos
class FavoriteService {
  
  /// Toggle favorito (agregar o eliminar) - MÉTODO RECOMENDADO
  Future<Map<String, dynamic>> toggleFavorite({
    required String itemType,
    required String itemId,
    String? tmdbId,
  }) async {
    try {
      final body = {
        'item_type': itemType,
        'item_id': itemId,
        'tmdb_id': tmdbId ?? itemId,
      };

      print('📤 Toggle favorito: $body');

      final response = await ApiService.post('/favorites/toggle', body);

      print('📥 Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        return {
          'success': true,
          'isFavorite': jsonResponse['isFavorite'] ?? false,
          'msg': jsonResponse['msg'] ?? '',
          'data': jsonResponse['data'],
        };
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al toggle favorito');
    } catch (e) {
      print('❌ Error en toggleFavorite: $e');
      rethrow;
    }
  }

  /// Verificar si un item es favorito
  Future<bool> checkFavorite({
    required String itemType,
    required String itemId,
  }) async {
    try {
      final response = await ApiService.get(
        '/favorites/check?item_type=$itemType&item_id=$itemId'
      );

      print('📥 Check favorito: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['isFavorite'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error en checkFavorite: $e');
      return false;
    }
  }

  /// Obtener favoritos con información detallada
  Future<List<Favorite>> getUserFavoritesDetailed() async {
    try {
      final response = await ApiService.get('/favorites/detailed');

      print('📥 Get favorites detailed: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        return data.map((item) => Favorite.fromJson(item)).toList();
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al obtener favoritos');
    } catch (e) {
      print('❌ Error en getUserFavoritesDetailed: $e');
      rethrow;
    }
  }

  /// Obtener todos los favoritos del usuario
  Future<List<Favorite>> getUserFavorites({String? type}) async {
    try {
      String endpoint = '/favorites';
      if (type != null && type != 'all') {
        endpoint += '?type=$type';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        return data.map((item) => Favorite.fromJson(item)).toList();
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al obtener favoritos');
    } catch (e) {
      print('❌ Error en getUserFavorites: $e');
      rethrow;
    }
  }

  /// Eliminar un favorito
  Future<void> deleteFavorite({int? id, String? itemType, String? itemId}) async {
    try {
      final body = <String, dynamic>{};
      
      if (id != null) {
        body['id'] = id;
      } else if (itemType != null && itemId != null) {
        body['item_type'] = itemType;
        body['item_id'] = itemId;
      } else {
        throw Exception('Proporciona id o (item_type + item_id)');
      }

      final response = await ApiService.delete('/favorites', body: body);

      if (response.statusCode == 200) {
        return;
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al eliminar favorito');
    } catch (e) {
      print('❌ Error en deleteFavorite: $e');
      rethrow;
    }
  }
}