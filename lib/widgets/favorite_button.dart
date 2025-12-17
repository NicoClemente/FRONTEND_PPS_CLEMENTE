import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';

class FavoriteButton extends StatefulWidget {
  final String itemType;
  final String itemId;
  final String? tmdbId;
  final double size;

  const FavoriteButton({
    super.key,
    required this.itemType,
    required this.itemId,
    this.tmdbId,
    this.size = 24.0,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        setState(() => _isLoading = false);
        return;
      }

      final user = await _authService.getProfile();
      final isFav = await _favoriteService.isFavorite(
        userId: user.id,
        itemType: widget.itemType,
        itemId: int.parse(widget.itemId),
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al verificar favorito: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final isAuth = await _authService.isAuthenticated();
    if (!isAuth) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes iniciar sesión para agregar favoritos'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, 'login'),
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = await _authService.getProfile();
      final result = await _favoriteService.toggleFavorite(
        userId: user.id,
        itemType: widget.itemType,
        itemId: int.parse(widget.itemId),
        tmdbId: widget.tmdbId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = result['isFavorite'];
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite 
                  ? '❤️ Agregado a favoritos' 
                  : 'Eliminado de favoritos',
            ),
            backgroundColor: _isFavorite ? Colors.green : Colors.grey,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: _isProcessing
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey,
              size: widget.size,
            ),
      onPressed: _isProcessing ? null : _toggleFavorite,
      tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
    );
  }
}