import 'package:flutter/material.dart';
import '../../models/series.dart';

class SeriesCard extends StatelessWidget {
  final Series series;
  final VoidCallback onTap;

  const SeriesCard({
    super.key,
    required this.series,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final titleSize = cardWidth * 0.05;
        final subtitleSize = titleSize * 0.8;

        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la serie
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'series-${series.id}',
                        child: Image.network(
                          series.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.tv,
                                size: cardWidth * 0.2,
                                color: Colors.white54,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Badge de estado (si está disponible)
                      if (series.status.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: cardWidth * 0.03,
                              vertical: cardWidth * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(series.status),
                              borderRadius: BorderRadius.circular(cardWidth * 0.03),
                            ),
                            child: Text(
                              _getStatusText(series.status),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: cardWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      
                      // Géneros (overlay en la parte inferior)
                      if (series.genres.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(cardWidth * 0.02),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Wrap(
                              spacing: 4,
                              children: series.genres.take(2).map((genre) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    genre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: cardWidth * 0.03,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Información de la serie
                Padding(
                  padding: EdgeInsets.all(cardWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: cardWidth * 0.02),
                      
                      // Network y año
                      Row(
                        children: [
                          if (series.network.isNotEmpty) ...[
                            Icon(
                              Icons.live_tv,
                              size: cardWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: cardWidth * 0.01),
                            Flexible(
                              child: Text(
                                series.network,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      if (series.premiered.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: cardWidth * 0.01),
                          child: Text(
                            _formatYear(series.premiered),
                            style: TextStyle(
                              fontSize: subtitleSize * 0.9,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        return 'TBD';
      default:
        return status;
    }
  }

  String _formatYear(String premiered) {
    if (premiered.isEmpty) return '';
    try {
      final year = premiered.split('-')[0];
      return year;
    } catch (e) {
      return premiered;
    }
  }
}