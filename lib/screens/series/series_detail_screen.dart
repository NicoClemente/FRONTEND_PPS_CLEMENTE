import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/favorite_button.dart';
import '../../models/series.dart';

class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _commentController;

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
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Series? series = args['series'];
    final String imagePath = args['imagePath'] ?? '';
    final String title = args['title'] ?? 'Sin título';
    final String description = args['description'] ?? 'Sin descripción';
    
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSmallScreen) ...[
                _buildSeriesHeader(imagePath, series),
                const SizedBox(height: 16),
                _buildSeriesInfo(title, description, series),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildSeriesHeader(imagePath, series),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildSeriesInfo(title, description, series),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              _buildReviewForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesHeader(String imagePath, Series? series) {
    return Stack(
      children: [
        // Imagen
        Hero(
          tag: series != null ? 'series-${series.id}' : 'series-$imagePath',
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              ),
            ),
          ),
        ),
        
        // Botón de favorito flotante
        if (series != null)
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
                itemType: 'series',
                itemId: series.id,
                tmdbId: series.id,
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
      child: const Icon(Icons.tv, size: 100, color: Colors.white54),
    );
  }

  Widget _buildSeriesInfo(String title, String description, Series? series) {
    // Limpiar HTML del summary
    String cleanDescription = description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        
        if (series != null) ...[
          const SizedBox(height: 16),
          
          // Estado
          if (series.status.isNotEmpty)
            _buildInfoRow(
              Icons.live_tv,
              'Estado',
              _getStatusText(series.status),
              _getStatusColor(series.status),
            ),
          
          // Network
          if (series.network.isNotEmpty)
            _buildInfoRow(
              Icons.tv,
              'Canal',
              series.network,
              null,
            ),
          
          // Fecha de estreno
          if (series.premiered.isNotEmpty)
            _buildInfoRow(
              Icons.calendar_today,
              'Estreno',
              series.premiered,
              null,
            ),
          
          // Géneros
          if (series.genres.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: series.genres.map((genre) => Chip(
                label: Text(genre),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ],
        
        const SizedBox(height: 24),
        Text(
          'Sinopsis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          cleanDescription.isEmpty ? 'No hay sinopsis disponible' : cleanDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[600],
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'ended':
        return Colors.red;
      case 'to be determined':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return 'En emisión';
      case 'ended':
        return 'Finalizada';
      case 'to be determined':
        return 'Por determinar';
      default:
        return status;
    }
  }

  Widget _buildReviewForm() {
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
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Escribe tu reseña',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              hintText: 'Comparte tu opinión sobre la serie...',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor escribe un comentario';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('¡Reseña guardada con éxito!'),
                      backgroundColor: Theme.of(context).primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  _commentController.clear();
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