import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/screens/screens.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/helpers/preferences.dart';
import 'package:flutter_app/services/auth_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final isDarkMode = await Preferences.getThemePreference();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialRoute;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated();
      
      if (mounted) {
        setState(() {
          _initialRoute = isAuthenticated ? 'home' : 'login';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Si hay error, redirigir a login
      if (mounted) {
        setState(() {
          _initialRoute = 'login';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se verifica autenticación
    if (_isLoading || _initialRoute == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: widget.isDarkMode),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlixFinder',
            theme: themeProvider.temaActual,
            initialRoute: _initialRoute,
            routes: {
              // Auth routes
              'login': (context) => const LoginScreen(),
              'register': (context) => const RegisterScreen(),
              
              // Main routes
              'home': (context) => const HomeScreen(),
              'profile': (context) => const ProfileScreen(),
              
              // Content routes
              'actors': (context) => const ActorsListScreen(),
              'actor_details': (context) => const ActorDetailsScreen(),
              
              // Series routes (AGREGADO)
              'series': (context) => const SeriesScreen(),
              'series_detail': (context) => const SeriesDetailScreen(),
              
              // Movies routes
              'movies': (context) => const MoviesListScreen(),
              'movie_details': (context) => const MovieDetailsScreen(),
              
              // Favorites route
               'favorites': (context) => const FavoritesAndReviewsScreen(),
            },
          );
        },
      ),
    );
  }
}