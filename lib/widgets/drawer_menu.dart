import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DrawerMenu extends StatelessWidget {
  final AuthService _authService = AuthService();

  final List<Map<String, String>> _menuItems = <Map<String, String>>[
    {'route': 'home', 'title': 'Home', 'subtitle': 'Home page'},
    {'route': 'actors', 'title': 'Actores Populares'},
    {'route': 'series', 'title': 'Series'},
    {'route': 'movies', 'title': 'Películas'},
    {'route': 'favorites', 'title': 'Mis Favoritos', 'subtitle': '❤️ Tu contenido favorito'},
    {'route': 'profile','title': 'Perfil de Usuario','subtitle': 'Perfil de usuario-Cambio de tema light/dark '},
  ];

  DrawerMenu({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          'login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const _DrawerHeaderAlternative(),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: ListTile.divideTiles(
                context: context,
                tiles: _menuItems.map((item) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, 
                    horizontal: 10
                  ),
                  dense: true,
                  minLeadingWidth: 25,
                  iconColor: Colors.blueGrey,
                  title: Text(
                    item['title']!,
                    style: const TextStyle(fontFamily: 'FuzzyBubbles')
                  ),
                  subtitle: Text(
                    item['subtitle'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'RobotoMono', 
                      fontSize: 11
                    )
                  ),
                  leading: _getMenuIcon(item['route']!),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, item['route']!);
                  },
                ))
              ).toList(),
            ),
          ),
          
          const Divider(),
          
          FutureBuilder<bool>(
            future: _authService.isAuthenticated(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout(context);
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.login, color: Colors.green),
                  title: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'login');
                  },
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Icon _getMenuIcon(String route) {
    switch (route) {
      case 'home':
        return const Icon(Icons.home);
      case 'actors':
        return const Icon(Icons.person);
      case 'series':
        return const Icon(Icons.tv);
      case 'movies':
        return const Icon(Icons.movie);
      case 'favorites':
        return const Icon(Icons.favorite);
      case 'profile':
        return const Icon(Icons.account_circle);
      default:
        return const Icon(Icons.arrow_right);
    }
  }
}

class _DrawerHeaderAlternative extends StatelessWidget {
  const _DrawerHeaderAlternative();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/menu.jpg', 
              fit: BoxFit.cover, 
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Text(
              '  Menu  ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,  
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}