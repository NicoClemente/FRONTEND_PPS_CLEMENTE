import 'dart:convert';

List<Series> seriesFromJson(String str) => List<Series>.from(json.decode(str).map((x) => Series.fromJson(x)));

String seriesToJson(List<Series> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Series {
  String id;
  String name;
  List<String> genres;
  String premiered;
  String status;
  String summary;
  String network;
  String imageUrl;
  String? tmdbId; 
  Series({
    required this.id,
    required this.name,
    required this.genres,
    required this.premiered,
    required this.status,
    required this.summary,
    required this.network,
    required this.imageUrl,
    this.tmdbId,
  });

  factory Series.fromJson(Map<String, dynamic> json) => Series(
    id: json["id"].toString(),
    name: json["name"],
    genres: List<String>.from(json["genres"].map((x) => x.toString())),
    premiered: json["first_air_date"] ?? '',
    status: '', // Not in JSON
    summary: json["overview"] ?? '',
    network: '', // Not in JSON
    imageUrl: json["poster_path"] != null ? 'https://image.tmdb.org/t/p/w500${json["poster_path"]}' : '',
    tmdbId: json["id"].toString(), 
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "genres": List<dynamic>.from(genres.map((x) => x)),
    "premiered": premiered,
    "status": status,
    "summary": summary,
    "network": network,
    "imageUrl": imageUrl,
    "tmdb_id": tmdbId,
  };
}  