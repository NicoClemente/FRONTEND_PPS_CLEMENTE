import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/drawer_menu.dart';
import 'package:flutter_app/models/movie_model.dart';
import 'package:flutter_app/services/movie_service.dart';
import 'package:flutter_app/widgets/movies/movie_card.dart';
import 'package:flutter_app/screens/movies/movie_details_screen.dart';
import 'package:flutter_app/screens/movies/movies_list_screen.dart';
import 'package:flutter_app/screens/series/series_screen.dart';
import 'package:flutter_app/screens/actors/actor_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _popularMovies = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPopularMovies();
  }

  Future<void> _loadPopularMovies() async {
    try {
      final movies = await MovieService().getPopularMovies();
      setState(() {
        _popularMovies = movies.take(10).toList(); // Show top 10
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar películas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlixFinder'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      drawer: DrawerMenu(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                '¡Bienvenido a FlixFinder!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre las mejores películas, series y actores.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar películas, series o actores...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onSubmitted: (query) {
                  // Navigate to search results or handle search
                  // For now, just show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Buscar: $query')),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(
                    context,
                    'Películas',
                    Icons.movie,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoviesListScreen()),
                    ),
                  ),
                  _buildNavButton(
                    context,
                    'Series',
                    Icons.tv,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SeriesScreen()),
                    ),
                  ),
                  _buildNavButton(
                    context,
                    'Actores',
                    Icons.person,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActorsListScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Popular Movies Section
              Text(
                'Películas Populares',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _popularMovies.isEmpty
                      ? const Center(child: Text('No hay películas disponibles'))
                      : SizedBox(
                          height: 320,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _popularMovies.length,
                            itemBuilder: (context, index) {
                              final movie = _popularMovies[index];
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 10),
                                child: MovieCard(
                                  movie: {
                                    'key': movie.key,
                                    'posterPath': movie.posterPath,
                                    'title': movie.title,
                                    'overview': movie.overview,
                                    'voteAverage': movie.voteAverage,
                                    'releaseDate': movie.releaseDate,
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MovieDetailsScreen(),
                                        settings: RouteSettings(arguments: {
                                          'key': movie.key,
                                          'posterPath': movie.posterPath,
                                          'title': movie.title,
                                          'overview': movie.overview,
                                          'voteAverage': movie.voteAverage,
                                          'releaseDate': movie.releaseDate,
                                          'genres': movie.genres,
                                        }),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}