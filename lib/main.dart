import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/screens/screens.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/helpers/preferences.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final isDarkMode = await Preferences.getThemePreference();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: isDarkMode),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlixFinder',
            theme: themeProvider.temaActual,
            initialRoute: 'login',
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