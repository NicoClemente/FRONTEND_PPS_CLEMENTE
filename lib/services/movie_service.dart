import 'dart:convert';
import '../models/movie_model.dart';
import 'api_service.dart';

class MovieService {
  // Mapeo de géneros (sincronizado con el backend)
  static final Map<String, int> genreIds = {
    'Acción': 28,
    'Aventura': 12,
    'Ciencia Ficción': 878,
    'Crimen': 80,
    'Drama': 18,
    'Fantasía': 14,
    'Historia': 36,
    'Romance': 10749,
    'Suspenso': 53
  };

  static final Map<int, String> genreNames = {
    28: 'Acción',
    12: 'Aventura',
    878: 'Ciencia Ficción',
    80: 'Crimen',
    18: 'Drama',
    14: 'Fantasía',
    36: 'Historia',
    10749: 'Romance',
    53: 'Suspenso'
  };

  /// Obtener películas populares desde TMDb
  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await ApiService.get('/peliculas');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar películas');
    } catch (e) {
      print('❌ Error en getPopularMovies: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Buscar películas por título
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await ApiService.get('/peliculas/buscar?query=$encodedQuery');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error en la búsqueda');
    } catch (e) {
      print('❌ Error en searchMovies: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener lista de géneros
  Future<List<String>> getGenres() async {
    try {
      final response = await ApiService.get('/peliculas/generos');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return List<String>.from(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar géneros');
    } catch (e) {
      print('❌ Error en getGenres: $e');
      // Retornar géneros por defecto en caso de error
      return genreIds.keys.toList();
    }
  }

  /// Obtener películas por género
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final encodedGenre = Uri.encodeComponent(genre);
      final response = await ApiService.get('/peliculas/generos?genre=$encodedGenre');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al filtrar por género');
    } catch (e) {
      print('❌ Error en getMoviesByGenre: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener detalles de una película por ID de TMDb
  Future<Movie> getMovieById(String id) async {
    try {
      final response = await ApiService.get('/peliculas/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Movie.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar película');
    } catch (e) {
      print('❌ Error en getMovieById: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // ============================================
  // NUEVAS FUNCIONES - CRUD CON BASE DE DATOS
  // ============================================

  /// Guardar película en la base de datos local
  Future<Map<String, dynamic>> saveMovie(Movie movie) async {
    try {
      final body = {
        'tmdb_id': movie.key.replaceAll('/movies/', ''),
        'title': movie.title,
        'overview': movie.overview,
        'release_date': movie.releaseDate,
        'vote_average': movie.voteAverage,
        'poster_path': movie.posterPath,
        'genre_ids': movie.genres,
      };

      final response = await ApiService.post('/peliculas/db', body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else if (response.statusCode == 409) {
        // Ya existe
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al guardar película');
    } catch (e) {
      print('❌ Error en saveMovie: $e');
      throw Exception('Error al guardar: $e');
    }
  }

  /// Obtener películas guardadas en la base de datos
  Future<List<Movie>> getSavedMovies({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService.get('/peliculas/db?page=$page&limit=$limit');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return (jsonResponse['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      }
      
      ApiService.handleHttpError(response);
      throw Exception('Error al cargar películas guardadas');
    } catch (e) {
      print('❌ Error en getSavedMovies: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Eliminar película de la base de datos
  Future<void> deleteMovie(int id) async {
    try {
      final response = await ApiService.delete('/peliculas/db/$id');

      if (response.statusCode != 200) {
        ApiService.handleHttpError(response);
        throw Exception('Error al eliminar película');
      }
    } catch (e) {
      print('❌ Error en deleteMovie: $e');
      throw Exception('Error al eliminar: $e');
    }
  }
}