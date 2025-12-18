import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'TU_API_KEY_DE_TMDB'; // ← REEMPLAZAR con tu API key
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Obtener detalles de una película
  Future<Map<String, dynamic>?> getMovieDetails(String movieId) async {
    try {
      final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalles de película: $e');
      return null;
    }
  }

  /// Obtener detalles de una serie
  Future<Map<String, dynamic>?> getSeriesDetails(String seriesId) async {
    try {
      final url = '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalles de serie: $e');
      return null;
    }
  }

  /// Obtener detalles de un actor
  Future<Map<String, dynamic>?> getActorDetails(String actorId) async {
    try {
      final url = '$_baseUrl/person/$actorId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo detalles de actor: $e');
      return null;
    }
  }

  /// Construir URL completa de imagen
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$_imageBaseUrl$path';
  }
}