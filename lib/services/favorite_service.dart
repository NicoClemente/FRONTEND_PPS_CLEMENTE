import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Modelo de Favorito
class Favorite {
  final int? id;
  final int userId;
  final String itemType; // 'movie', 'series', 'actor'
  final int itemId;
  final String? createdAt;
  final dynamic details; // Detalles del item cuando se usa /detailed

  Favorite({
    this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.createdAt,
    this.details,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'],
    userId: json['user_id'],
    itemType: json['item_type'],
    itemId: json['item_id'],
    createdAt: json['created_at'],
    details: json['details'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'item_type': itemType,
    'item_id': itemId,
  };
}

/// Servicio para gestión de favoritos
class FavoriteService {
  /// Agregar un elemento a favoritos
  Future<Favorite> addFavorite({
    required int userId,
    required String itemType,
    required int itemId,
  }) async {
    try {
      final body = {
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
      };

      final response = await ApiService.post('/favorites', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Favorite.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 409) {
        // Ya existe en favoritos
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Favorite.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al agregar favorito');
    } catch (e) {
      print('❌ Error en addFavorite: $e');
      throw Exception('Error al agregar favorito: $e');
    }
  }

  /// Obtener favoritos de un usuario
  Future<List<Favorite>> getUserFavorites(int userId, {String? type}) async {
    try {
      String endpoint = '/favorites/user/$userId';
      if (type != null) {
        endpoint += '?type=$type';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((favJson) => Favorite.fromJson(favJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al obtener favoritos');
    } catch (e) {
      print('❌ Error en getUserFavorites: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener favoritos con información detallada
  Future<List<Favorite>> getUserFavoritesDetailed(int userId) async {
    try {
      final response = await ApiService.get('/favorites/user/$userId/detailed');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((favJson) => Favorite.fromJson(favJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al obtener favoritos detallados');
    } catch (e) {
      print('❌ Error en getUserFavoritesDetailed: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Eliminar un favorito por ID
  Future<void> deleteFavorite(int favoriteId) async {
    try {
      final response = await ApiService.delete('/favorites/$favoriteId');

      if (response.statusCode != 200) {
        ApiService.handleHttpError(response);
        throw Exception('Error al eliminar favorito');
      }
    } catch (e) {
      print('❌ Error en deleteFavorite: $e');
      throw Exception('Error al eliminar: $e');
    }
  }

  /// Eliminar favorito específico
  Future<void> removeFavorite({
    required int userId,
    required String itemType,
    required int itemId,
  }) async {
    try {
      final body = {
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
      };

      // DELETE con body requiere configuración especial
      final url = Uri.parse('${ApiService.baseUrl}/favorites/remove');
      final response = await http.delete(
        url,
        headers: await ApiService.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        ApiService.handleHttpError(response);
        throw Exception('Error al eliminar favorito');
      }
    } catch (e) {
      print('❌ Error en removeFavorite: $e');
      throw Exception('Error al eliminar: $e');
    }
  }

  /// Verificar si un item está en favoritos
  Future<bool> isFavorite({
    required int userId,
    required String itemType,
    required int itemId,
  }) async {
    try {
      final favorites = await getUserFavorites(userId, type: itemType);
      return favorites.any((fav) => fav.itemId == itemId);
    } catch (e) {
      print('❌ Error en isFavorite: $e');
      return false;
    }
  }

  /// Alternar favorito (agregar o quitar)
  Future<Map<String, dynamic>> toggleFavorite({
    required int userId,
    required String itemType,
    required int itemId,
    String? tmdbId,
  }) async {
    try {
      final isFav = await isFavorite(userId: userId, itemType: itemType, itemId: itemId);
      
      if (isFav) {
        // Quitar de favoritos
        await removeFavorite(userId: userId, itemType: itemType, itemId: itemId);
        return {'isFavorite': false};
      } else {
        // Agregar a favoritos
        await addFavorite(userId: userId, itemType: itemType, itemId: itemId);
        return {'isFavorite': true};
      }
    } catch (e) {
      print('❌ Error en toggleFavorite: $e');
      throw Exception('Error al alternar favorito: $e');
    }
  }
}