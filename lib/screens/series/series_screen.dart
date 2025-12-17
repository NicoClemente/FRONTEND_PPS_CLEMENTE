import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/series_widgets/series_card.dart';
import 'package:flutter_app/services/series_service.dart';
import 'package:flutter_app/models/series.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final SeriesService _seriesService = SeriesService();
  String _searchQuery = '';
  String? _selectedGenre;
  List<Series> _allSeries = [];
  bool _isLoading = true;

  // Géneros disponibles para series
  final List<String> _genres = [
    'Todos',
    'Drama',
    'Comedy',
    'Action',
    'Thriller',
    'Science-Fiction',
    'Horror',
    'Romance',
    'Crime',
  ];

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar series de múltiples páginas para tener más contenido
      List<Series> series = [];
      for (int page = 1; page <= 3; page++) {
        final pageSeries = await SeriesService.obtenerSeries(page);
        series.addAll(pageSeries);
      }
      
      if (mounted) {
        setState(() {
          _allSeries = series;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _searchSeries(String query) async {
    if (query.isEmpty) {
      _loadSeries();
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final results = await SeriesService.buscarSeries(query);
      
      if (mounted) {
        setState(() {
          _allSeries = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Series> get _filteredSeries {
    var series = _allSeries;
    
    // Filtrar por género
    if (_selectedGenre != null && _selectedGenre != 'Todos') {
      series = series.where((s) {
        return s.genres.any((g) => 
          g.toLowerCase().contains(_selectedGenre!.toLowerCase())
        );
      }).toList();
    }
    
    return series;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(title: 'Series'),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSearchBar(theme),
                const SizedBox(height: 16),
                _buildGenreFilters(),
              ],
            ),
          ),
          
          // Grid de series
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSeries.isEmpty
                    ? _buildEmptyState()
                    : _buildSeriesGrid(_filteredSeries),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar series',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 15
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
          if (value.length > 2 || value.isEmpty) {
            _searchSeries(value);
          }
        },
      ),
    );
  }

  Widget _buildGenreFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(_genres[index]),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String genre) {
    final isSelected = _selectedGenre == genre || 
                       (genre == 'Todos' && _selectedGenre == null);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          genre,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedGenre = genre == 'Todos' ? null : genre;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.primaryColor,
        elevation: isSelected ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : theme.dividerColor,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron series',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otra búsqueda',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesGrid(List<Series> series) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return RefreshIndicator(
          onRefresh: _loadSeries,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: series.length,
            itemBuilder: (context, index) {
              return SeriesCard(
                series: series[index],
                onTap: () => _navigateToDetails(series[index]),
              );
            },
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 450) return 1;
    if (width < 800) return 2;
    if (width < 1100) return 3;
    return 4;
  }

  void _navigateToDetails(Series series) {
    Navigator.pushNamed(
      context,
      'series_detail',
      arguments: {
        'imagePath': series.imageUrl,
        'title': series.name,
        'description': series.summary,
        'series': series,
      },
    );
  }
}