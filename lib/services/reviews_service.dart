import 'dart:convert';
import 'api_service.dart';

/// Modelo de Review
class Review {
  final int? id;
  final int userId;
  final String itemType; // 'movie', 'series'
  final String itemId;
  final String? tmdbId;
  final int? rating; // 1-10
  final String? reviewText;
  final bool? isFavorite;
  final String? createdAt;
  final String? updatedAt;

  Review({
    this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.tmdbId,
    this.rating,
    this.reviewText,
    this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    userId: json['user_id'],
    itemType: json['item_type'],
    itemId: json['item_id'].toString(),
    tmdbId: json['tmdb_id']?.toString(),
    rating: json['rating'],
    reviewText: json['review_text'],
    isFavorite: json['is_favorite'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'item_type': itemType,
    'item_id': itemId,
    if (tmdbId != null) 'tmdb_id': tmdbId,
    if (rating != null) 'rating': rating,
    if (reviewText != null) 'review_text': reviewText,
    if (isFavorite != null) 'is_favorite': isFavorite,
  };
}

/// Servicio para gestión de reviews
class ReviewService {
  
  /// Crear o actualizar una review
  Future<Map<String, dynamic>> createOrUpdateReview({
    required String itemType,
    required String itemId,
    String? tmdbId,
    int? rating,
    String? reviewText,
    bool? isFavorite,
  }) async {
    try {
      final body = {
        'item_type': itemType,
        'item_id': itemId,
        'tmdb_id': tmdbId ?? itemId,
        if (rating != null) 'rating': rating,
        if (reviewText != null) 'review_text': reviewText,
        if (isFavorite != null) 'is_favorite': isFavorite,
      };

      print('📤 Guardar review: $body');

      final response = await ApiService.post('/reviews', body);

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        return {
          'success': true,
          'msg': jsonResponse['msg'] ?? 'Review guardada',
          'data': jsonResponse['data'],
        };
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al guardar review');
    } catch (e) {
      print('❌ Error en createOrUpdateReview: $e');
      rethrow;
    }
  }

  /// Obtener reviews del usuario
  Future<List<Review>> getUserReviews({String? type}) async {
    try {
      String endpoint = '/reviews';
      if (type != null) {
        endpoint += '?type=$type';
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        return data.map((item) => Review.fromJson(item)).toList();
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al obtener reviews');
    } catch (e) {
      print('❌ Error en getUserReviews: $e');
      rethrow;
    }
  }

  /// Obtener una review específica
  Future<Review?> getReview({
    required String itemType,
    required String itemId,
  }) async {
    try {
      final response = await ApiService.get(
        '/reviews/single?item_type=$itemType&item_id=$itemId'
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Review.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        return null; // No existe review
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al obtener review');
    } catch (e) {
      print('❌ Error en getReview: $e');
      return null;
    }
  }

  /// Eliminar una review
  Future<void> deleteReview({int? id, String? itemType, String? itemId}) async {
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

      final response = await ApiService.delete('/reviews', body: body);

      if (response.statusCode == 200) {
        return;
      }

      ApiService.handleHttpError(response);
      throw Exception('Error al eliminar review');
    } catch (e) {
      print('❌ Error en deleteReview: $e');
      rethrow;
    }
  }

  /// Obtener todas las reviews de un item (público)
  Future<List<Map<String, dynamic>>> getItemReviews({
    required String itemType,
    required String itemId,
  }) async {
    try {
      final response = await ApiService.get(
        '/reviews/item?item_type=$itemType&item_id=$itemId'
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse['data'] ?? []);
      }

      return [];
    } catch (e) {
      print('❌ Error en getItemReviews: $e');
      return [];
    }
  }
}