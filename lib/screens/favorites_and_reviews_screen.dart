import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/reviews_service.dart';
import '../services/auth_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/custom_app_bar.dart';

class FavoritesAndReviewsScreen extends StatefulWidget {
  const FavoritesAndReviewsScreen({super.key});

  @override
  State<FavoritesAndReviewsScreen> createState() => _FavoritesAndReviewsScreenState();
}

class _FavoritesAndReviewsScreenState extends State<FavoritesAndReviewsScreen> with SingleTickerProviderStateMixin {
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  final TMDBService _tmdbService = TMDBService();
  
  late TabController _tabController;
  
  List<Map<String, dynamic>> _favoritesWithDetails = [];
  List<Review> _reviews = [];
  bool _isLoadingFavorites = true;
  bool _isLoadingReviews = true;
  String? _error;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final isAuth = await _authService.isAuthenticated();
    if (!isAuth) {
      setState(() {
        _error = 'Debes iniciar sesión';
        _isLoadingFavorites = false;
        _isLoadingReviews = false;
      });
      return;
    }

    _loadFavorites();
    _loadReviews();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoadingFavorites = true;
      _error = null;
    });

    try {
      final favorites = await _favoriteService.getUserFavoritesDetailed();
      
      final favoritesWithTMDB = <Map<String, dynamic>>[];
      
      for (var favorite in favorites) {
        Map<String, dynamic>? tmdbDetails;
        
        try {
          if (favorite.itemType == 'movie') {
            tmdbDetails = await _tmdbService.getMovieDetails(favorite.tmdbId ?? favorite.itemId);
          } else if (favorite.itemType == 'series') {
            tmdbDetails = await _tmdbService.getSeriesDetails(favorite.tmdbId ?? favorite.itemId);
          } else if (favorite.itemType == 'actor') {
            tmdbDetails = await _tmdbService.getActorDetails(favorite.tmdbId ?? favorite.itemId);
          }
        } catch (e) {
          print('Error obteniendo detalles de TMDB: $e');
        }

        favoritesWithTMDB.add({
          'favorite': favorite,
          'tmdb': tmdbDetails,
        });
      }

      if (mounted) {
        setState(() {
          _favoritesWithDetails = favoritesWithTMDB;
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoadingFavorites = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviews = await _reviewService.getUserReviews();
      
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredFavorites {
    if (_filterType == 'all') return _favoritesWithDetails;
    return _favoritesWithDetails.where((item) {
      final favorite = item['favorite'] as Favorite;
      return favorite.itemType == _filterType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mi Contenido',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _error != null
          ? _buildErrorWidget()
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
                    Tab(icon: Icon(Icons.rate_review), text: 'Reseñas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFavoritesTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFavoritesTab() {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: _isLoadingFavorites
              ? const Center(child: CircularProgressIndicator())
              : _filteredFavorites.isEmpty
                  ? _buildEmptyWidget('No tienes favoritos')
                  : _buildFavoritesList(),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return _buildEmptyWidget('No has escrito reseñas');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('Todos', 'all', Icons.grid_view),
            const SizedBox(width: 8),
            _buildChip('Películas', 'movie', Icons.movie),
            const SizedBox(width: 8),
            _buildChip('Series', 'series', Icons.tv),
            const SizedBox(width: 8),
            _buildChip('Actores', 'actor', Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String type, IconData icon) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filterType = type);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFavorites.length,
        itemBuilder: (context, index) {
          final item = _filteredFavorites[index];
          final favorite = item['favorite'] as Favorite;
          final tmdbData = item['tmdb'] as Map<String, dynamic>?;
          
          return _buildFavoriteCard(favorite, tmdbData);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Favorite favorite, Map<String, dynamic>? tmdbData) {
    String title = 'Sin título';
    String? subtitle;
    String? imageUrl;
    double? rating;

    if (tmdbData != null) {
      if (favorite.itemType == 'movie') {
        title = tmdbData['title'] ?? title;
        subtitle = tmdbData['release_date']?.toString().substring(0, 4);
        imageUrl = tmdbData['poster_path'];
        rating = tmdbData['vote_average']?.toDouble();
      }
      else if (favorite.itemType == 'series') {
        title = tmdbData['name'] ?? title;
        subtitle = tmdbData['first_air_date']?.toString().substring(0, 4);
        imageUrl = tmdbData['poster_path'];
        rating = tmdbData['vote_average']?.toDouble();
      }
      else if (favorite.itemType == 'actor') {
        title = tmdbData['name'] ?? title;
        subtitle = tmdbData['known_for_department'];
        imageUrl = tmdbData['profile_path'];
      }

      if (imageUrl != null && !imageUrl.startsWith('http')) {
        imageUrl = 'https://image.tmdb.org/t/p/w500$imageUrl';
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetails(favorite, tmdbData),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(favorite.itemType),
                      )
                    : _buildPlaceholderImage(favorite.itemType),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildTypeChip(favorite.itemType),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteDialog(favorite, title),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  // 🟢 CAMBIO 1: Agregar tmdbData en el FutureBuilder
  Widget _buildReviewCard(Review review) {  
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getReviewDetails(review),
      builder: (context, snapshot) {
        String title = 'Cargando...';
        String? imageUrl;
        Map<String, dynamic>? tmdbData; // 🟢 AGREGAR ESTA LÍNEA
        
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          title = data['title'] ?? 'Sin título';
          imageUrl = data['imageUrl'];
          tmdbData = data['tmdbData']; // 🟢 AGREGAR ESTA LÍNEA
        } else if (snapshot.hasError) {
          title = 'Error al cargar';
        }
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          // 🟢 CAMBIO 2: Agregar InkWell para hacer el card clickeable
          child: InkWell(
            onTap: tmdbData != null 
                ? () {
                    // Crear un Favorite temporal para reutilizar _navigateToDetails
                    final tempFavorite = Favorite(
                      userId: review.userId,
                      itemType: review.itemType,
                      itemId: review.itemId,
                      tmdbId: review.tmdbId,
                    );
                    _navigateToDetails(tempFavorite, tmdbData);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderImage(review.itemType),
                              )
                            : _buildPlaceholderImage(review.itemType),
                  ),
                  const SizedBox(width: 12),
                  // Contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip(review.itemType),
                            const Spacer(),
                            if (review.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${review.rating}/10',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            review.reviewText!,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Actualizado: ${_formatDate(review.updatedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🟢 CAMBIO 3: Agregar tmdbData en el return
  Future<Map<String, dynamic>?> _getReviewDetails(Review review) async {
    try {
      Map<String, dynamic>? tmdbData;
      
      if (review.itemType == 'movie') {
        tmdbData = await _tmdbService.getMovieDetails(review.tmdbId ?? review.itemId);
        if (tmdbData != null) {
          String? imageUrl = tmdbData['poster_path'];
          if (imageUrl != null && !imageUrl.startsWith('http')) {
            imageUrl = 'https://image.tmdb.org/t/p/w500$imageUrl';
          }
          return {
            'title': tmdbData['title'],
            'imageUrl': imageUrl,
            'tmdbData': tmdbData, // 🟢 AGREGAR ESTA LÍNEA
          };
        }
      } else if (review.itemType == 'series') {
        tmdbData = await _tmdbService.getSeriesDetails(review.tmdbId ?? review.itemId);
        if (tmdbData != null) {
          String? imageUrl = tmdbData['poster_path'];
          if (imageUrl != null && !imageUrl.startsWith('http')) {
            imageUrl = 'https://image.tmdb.org/t/p/w500$imageUrl';
          }
          return {
            'title': tmdbData['name'],
            'imageUrl': imageUrl,
            'tmdbData': tmdbData, // 🟢 AGREGAR ESTA LÍNEA
          };
        }
      }
    } catch (e) {
      print('Error obteniendo detalles de review: $e');
    }
    return null;
  }

  Widget _buildPlaceholderImage(String itemType) {
    IconData icon;
    switch (itemType) {
      case 'movie':
        icon = Icons.movie;
        break;
      case 'series':
        icon = Icons.tv;
        break;
      case 'actor':
        icon = Icons.person;
        break;
      default:
        icon = Icons.image_not_supported;
    }

    return Container(
      width: 80,
      height: 120,
      color: Colors.grey[300],
      child: Icon(icon, size: 40, color: Colors.grey[600]),
    );
  }

  Widget _buildTypeChip(String type) {
    String label;
    IconData icon;
    Color color;
    
    switch (type) {
      case 'movie':
        label = 'Película';
        icon = Icons.movie;
        color = Colors.blue;
        break;
      case 'series':
        label = 'Serie';
        icon = Icons.tv;
        color = Colors.purple;
        break;
      case 'actor':
        label = 'Actor';
        icon = Icons.person;
        color = Colors.green;
        break;
      default:
        label = type;
        icon = Icons.help;
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      avatar: Icon(icon, size: 16, color: Colors.white),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora contenido y agrega tus favoritos',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, 'login'),
            icon: const Icon(Icons.login),
            label: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Favorite favorite, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de favoritos'),
        content: Text('¿Deseas eliminar "$title" de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _favoriteService.deleteFavorite(
                  id: favorite.id,
                  itemType: favorite.itemType,
                  itemId: favorite.itemId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Eliminado de favoritos'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadFavorites();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Favorite favorite, Map<String, dynamic>? tmdbData) {
    String route;
    dynamic arguments;

    switch (favorite.itemType) {
      case 'movie':
        route = 'movie_details';
        arguments = {
          'key': '/movies/${favorite.tmdbId ?? favorite.itemId}',
          'title': tmdbData?['title'] ?? 'Sin título',
          'releaseDate': tmdbData?['release_date'] ?? '',
          'overview': tmdbData?['overview'] ?? '',
          'voteAverage': tmdbData?['vote_average'] ?? 0.0,
          'genres': tmdbData?['genres'] != null 
              ? (tmdbData!['genres'] as List).map((g) => g['id']).toList()
              : [],
          'posterPath': tmdbData?['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${tmdbData!['poster_path']}'
              : null,
        };
        break;
        
      case 'series':
        route = 'series_detail';
        
        // Extraer ID de múltiples fuentes como respaldo
        String? extractedId = favorite.tmdbId ?? favorite.itemId;
        if (tmdbData != null && tmdbData['id'] != null) {
          extractedId = tmdbData['id'].toString();
        }
        
        arguments = {
          'imagePath': tmdbData?['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${tmdbData!['poster_path']}'
              : '',
          'title': tmdbData?['name'] ?? 'Sin título',
          'description': tmdbData?['overview'] ?? 'Sin descripción',
          'series': null,
          'seriesId': extractedId,
        };
        break;
        
      case 'actor':
        route = 'actor_details';
        arguments = {
          'id': int.tryParse(favorite.tmdbId ?? favorite.itemId) ?? 0,
          'name': tmdbData?['name'] ?? 'Sin nombre',
          'knownFor': tmdbData?['known_for_department'] != null 
              ? [tmdbData!['known_for_department']]
              : <String>[],
          'popularity': tmdbData?['popularity'] ?? 0.0,
          'profileImage': tmdbData?['profile_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${tmdbData!['profile_path']}'
              : null,
          'biography': tmdbData?['biography'],
        };
        break;
        
      default:
        return;
    }

    Navigator.pushNamed(context, route, arguments: arguments);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Desconocido';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}