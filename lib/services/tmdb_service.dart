import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // 🟢 Leer API Key desde .env
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Obtener detalles de una película
  Future<Map<String, dynamic>?> getMovieDetails(String movieId) async {
    try {
      // Limpiar el ID por si viene con formato "/movies/123"
      final cleanId = movieId.replaceAll('/movies/', '').replaceAll('/', '').trim();
      
      print('🔵 TMDBService.getMovieDetails: cleanId="$cleanId"');
      print('🔵 API Key presente: ${_apiKey.isNotEmpty}');
      
      final url = '$_baseUrl/movie/$cleanId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));
      
      print('🔵 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Película encontrada: ${data['title']}');
        return data;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo detalles de película: $e');
      return null;
    }
  }

  /// Obtener detalles de una serie
  Future<Map<String, dynamic>?> getSeriesDetails(String seriesId) async {
    try {
      // Limpiar el ID
      final cleanId = seriesId.replaceAll('/series/', '').replaceAll('/', '').trim();
      
      print('🔵 TMDBService.getSeriesDetails: cleanId="$cleanId"');
      
      final url = '$_baseUrl/tv/$cleanId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));
      
      print('🔵 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Serie encontrada: ${data['name']}');
        return data;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo detalles de serie: $e');
      return null;
    }
  }

  /// Obtener detalles de un actor
  Future<Map<String, dynamic>?> getActorDetails(String actorId) async {
    try {
      // Limpiar el ID
      final cleanId = actorId.replaceAll('/actors/', '').replaceAll('/person/', '').replaceAll('/', '').trim();
      
      print('🔵 TMDBService.getActorDetails: cleanId="$cleanId"');
      
      final url = '$_baseUrl/person/$cleanId?api_key=$_apiKey&language=es-ES';
      final response = await http.get(Uri.parse(url));
      
      print('🔵 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Actor encontrado: ${data['name']}');
        return data;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo detalles de actor: $e');
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