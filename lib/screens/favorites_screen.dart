import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_app_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();
  List<Favorite> _favorites = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        setState(() {
          _error = 'Debes iniciar sesión para ver tus favoritos';
          _isLoading = false;
        });
        return;
      }

      final favorites = await _favoriteService.getUserFavoritesDetailed();

      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<Favorite> get _filteredFavorites {
    if (_filterType == 'all') return _favorites;
    return _favorites.where((fav) => fav.itemType == _filterType).toList();
  }

  Future<void> _deleteFavorite(int? favoriteId, {String? itemType, String? itemId}) async {
    try {
      await _favoriteService.deleteFavorite(
        id: favoriteId,
        itemType: itemType,
        itemId: itemId,
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
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mis Favoritos',
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _filteredFavorites.isEmpty
                        ? _buildEmptyWidget()
                        : _buildFavoritesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('Todos', 'all'),
            const SizedBox(width: 8),
            _buildChip('Películas', 'movie'),
            const SizedBox(width: 8),
            _buildChip('Series', 'series'),
            const SizedBox(width: 8),
            _buildChip('Actores', 'actor'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String type) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filterType == 'all'
                ? 'No tienes favoritos aún'
                : 'No tienes ${_getTypeName(_filterType)} favoritos',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Empieza a agregar contenido a tus favoritos',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'movie':
        return 'películas';
      case 'series':
        return 'series';
      case 'actor':
        return 'actores';
      default:
        return '';
    }
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        itemCount: _filteredFavorites.length,
        itemBuilder: (context, index) {
          final favorite = _filteredFavorites[index];
          return _buildFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Favorite favorite) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingImage(favorite),
        title: Text(
          _getTitle(favorite),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getSubtitle(favorite)),
            const SizedBox(height: 4),
            _buildTypeChip(favorite.itemType),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(favorite),
        ),
        onTap: () => _navigateToDetails(favorite),
      ),
    );
  }

  Widget _buildLeadingImage(Favorite favorite) {
    final imageUrl = _getImageUrl(favorite);
    
    if (imageUrl == null) {
      return const Icon(Icons.image_not_supported, size: 50);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    String label;
    IconData icon;
    
    switch (type) {
      case 'movie':
        label = 'Película';
        icon = Icons.movie;
        break;
      case 'series':
        label = 'Serie';
        icon = Icons.tv;
        break;
      case 'actor':
        label = 'Actor';
        icon = Icons.person;
        break;
      default:
        label = type;
        icon = Icons.help;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      avatar: Icon(icon, size: 16),
      visualDensity: VisualDensity.compact,
    );
  }

  String _getTitle(Favorite favorite) {
    final details = favorite.details;
    if (details == null) return 'Sin título';
    
    return details['title'] ?? 
           details['name'] ?? 
           details['nombre'] ?? 
           'Sin título';
  }

  String _getSubtitle(Favorite favorite) {
    final details = favorite.details;
    if (details == null) return '';
    
    if (favorite.itemType == 'movie') {
      return details['release_date'] ?? details['releaseDate'] ?? '';
    } else if (favorite.itemType == 'series') {
      return details['premiered'] ?? details['first_air_date'] ?? '';
    } else if (favorite.itemType == 'actor') {
      final known = details['knownFor'] ?? details['known_for'];
      if (known is List && known.isNotEmpty) {
        return known.join(', ');
      }
      return details['known_for_department'] ?? '';
    }
    return '';
  }

  String? _getImageUrl(Favorite favorite) {
    final details = favorite.details;
    if (details == null) return null;
    
    return details['poster_path'] ?? 
           details['posterPath'] ?? 
           details['imageUrl'] ?? 
           details['image_url'] ??
           details['profile_path'] ??
           details['profileImage'];
  }

  void _showDeleteDialog(Favorite favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de favoritos'),
        content: Text('¿Deseas eliminar "${_getTitle(favorite)}" de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFavorite(
                favorite.id,
                itemType: favorite.itemType,
                itemId: favorite.itemId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Favorite favorite) {
    // Navegación según tipo
    // (manteniendo la misma lógica que antes)
  }
}