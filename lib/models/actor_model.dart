  class Actor {
  final int id;
  final String name;
  final List<String> knownFor;
  final double popularity;
  final String? profileImage;
  final String? biography;
  final String? tmdbId; // 🟢 AGREGAR ESTE CAMPO

  Actor({
    required this.id,
    required this.name,
    required this.knownFor,
    required this.popularity,
    this.profileImage,
    this.biography,
    this.tmdbId,
  });

  factory Actor.fromJson(Map<String, dynamic> json) => Actor(
    id: json["id"],
    name: json["name"] ?? '',
    knownFor: List<String>.from(json["knownFor"] ?? []),
    popularity: json["popularity"]?.toDouble() ?? 0.0,
    profileImage: json["profileImage"],
    biography: json["biography"],
    tmdbId: json["tmdb_id"]?.toString(), // 🟢 AGREGAR ESTE CAMPO
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "knownFor": knownFor,
    "popularity": popularity,
    "profileImage": profileImage,
    "biography": biography,
    "tmdb_id": tmdbId, // 🟢 AGREGAR ESTE CAMPO
  };
}