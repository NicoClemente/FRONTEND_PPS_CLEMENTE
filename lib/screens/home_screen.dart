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
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _loadPopularMovies();
    _scrollController.addListener(_updateArrows);
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 0;
      _showRightArrow = _scrollController.offset < 
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadPopularMovies() async {
    try {
      final movies = await MovieService().getPopularMovies();
      setState(() {
        _popularMovies = movies.take(20).toList();
        _isLoading = false;
      });
      
      // Actualizar flechas después de cargar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _updateArrows();
        }
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
              
              // Movies Carousel with Arrows
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _popularMovies.isEmpty
                      ? const Center(child: Text('No hay películas disponibles'))
                      : Stack(
                          children: [
                            SizedBox(
                              height: 320,
                              child: ListView.builder(
                                controller: _scrollController,
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
                            
                            // Left Arrow
                            if (_showLeftArrow)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: _scrollLeft,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Right Arrow
                            if (_showRightArrow)
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: _scrollRight,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}