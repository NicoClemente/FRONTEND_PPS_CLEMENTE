import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/series.dart';
import 'api_service.dart';

class SeriesService {
  /// Obtener series con paginación
  static Future<List<Series>> obtenerSeries(int page) async {
    try {
      final response = await ApiService.get('/series?page=$page');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          List<dynamic> body = jsonResponse['data'];
          List<Series> series = body.map((dynamic item) => Series.fromJson(item)).toList();
          return series;
        } catch (e) {
          print('❌ Error al parsear series: $e');
          throw Exception("Error al parsear la respuesta: $e");
        }
      }
      
      ApiService.handleHttpError(response);
      throw Exception("Error al cargar series: ${response.statusCode} - ${response.reasonPhrase}");
    } catch (e) {
      print('❌ Error en obtenerSeries: $e');
      throw Exception("Error de conexión: $e");
    }
  }

  /// Buscar series por nombre
  static Future<List<Series>> buscarSeries(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await ApiService.get('/series/buscar?query=$encodedQuery');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          List<dynamic> body = jsonResponse['data'];
          List<Series> series = body.map((dynamic item) => Series.fromJson(item)).toList();
          return series;
        } catch (e) {
          print('❌ Error al parsear búsqueda: $e');
          throw Exception("Error al parsear la respuesta: $e");
        }
      }
      
      ApiService.handleHttpError(response);
      throw Exception("Error al buscar series: ${response.statusCode} - ${response.reasonPhrase}");
    } catch (e) {
      print('❌ Error en buscarSeries: $e');
      throw Exception("Error de conexión: $e");
    }
  }

  /// Obtener serie por ID
  static Future<Series> getSerieById(String id) async {
    try {
      final response = await ApiService.get('/series/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Series.fromJson(jsonResponse['data']);
      }
      
      ApiService.handleHttpError(response);
      throw Exception("Serie no encontrada");
    } catch (e) {
      print('❌ Error en getSerieById: $e');
      throw Exception("Error de conexión: $e");
    }
  }

  /// Filtrar series por género
  static Future<List<Series>> getSeriesByGenre(String genre) async {
    try {
      final encodedGenre = Uri.encodeComponent(genre);
      final response = await ApiService.get('/series/genero?genre=$encodedGenre');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> body = jsonResponse['data'];
        List<Series> series = body.map((dynamic item) => Series.fromJson(item)).toList();
        return series;
      }
      
      ApiService.handleHttpError(response);
      throw Exception("Error al filtrar series");
    } catch (e) {
      print('❌ Error en getSeriesByGenre: $e');
      throw Exception("Error de conexión: $e");
    }
  }
}