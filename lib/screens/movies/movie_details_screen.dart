import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/services/movie_service.dart';
import 'package:flutter_app/services/reviews_service.dart';
import 'package:flutter_app/services/auth_service.dart';
import '../../widgets/favorite_button.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  
  late TextEditingController _commentController;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: movie['title'] ?? ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSmallScreen) ...[
                _buildMovieHeader(movie),
                const SizedBox(height: 16),
                _buildMovieInfo(movie),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildMovieHeader(movie),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildMovieInfo(movie),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              _buildReviewForm(movie),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader(Map<String, dynamic> movie) {
    final heroTag = 'movie-${movie['key'] ?? DateTime.now().toString()}';

    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: movie['posterPath'] != null
                    ? Image.network(
                        movie['posterPath'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
        ),
        
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FavoriteButton(
              itemType: 'movie',
              itemId: movie['key']?.replaceAll('/movies/', '') ?? '',
              tmdbId: movie['key']?.replaceAll('/movies/', ''),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.movie, size: 100, color: Colors.white54),
    );
  }

  Widget _buildMovieInfo(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie['title'] ?? '',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 20),
            const SizedBox(width: 4),
            Text(
              movie['voteAverage']?.toString() ?? '0.0',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            Text(
              'Año: ${movie['releaseDate'] ?? 'No disponible'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (movie['genres'] != null &&
            (movie['genres'] as List).isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (movie['genres'] as List)
                .map((genreId) => Chip(
                      label: Text(
                          MovieService.genreNames[genreId] ?? 'Desconocido'),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Sinopsis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          movie['overview'] ?? 'No hay sinopsis disponible',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Future<void> _saveReview(String movieId) async {
    final isAuth = await _authService.isAuthenticated();
    
    if (!isAuth) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para dejar una reseña'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    final reviewText = _commentController.text.trim();
    
    if (reviewText.isEmpty || movieId.isEmpty) {
      return;
    }
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    try {
      await _reviewService.createOrUpdateReview(
        itemType: 'movie',
        itemId: movieId,
        tmdbId: movieId,
        rating: _selectedRating,
        reviewText: reviewText,
      );
      
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Reseña guardada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        _commentController.clear();
        setState(() {
          _selectedRating = 5;
        });
      }
      
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildReviewForm(Map<String, dynamic> movie) {
    final movieId = movie['key']?.replaceAll('/movies/', '') ?? '';
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu opinión',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Rating
          const Text(
            'Calificación:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(10, (index) {
              final rating = index + 1;
              return IconButton(
                icon: Icon(
                  rating <= _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = rating;
                  });
                },
              );
            }),
          ),
          Text(
            '$_selectedRating/10',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Campo de texto
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Escribe tu reseña',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              hintText: 'Comparte tu opinión sobre la película...',
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor escribe un comentario';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Botón guardar
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveReview(movieId);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar reseña'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}