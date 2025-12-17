import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/drawer_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlixFinder'),
        centerTitle: true,
        automaticallyImplyLeading: true, // Muestra el icono del drawer
      ),
      drawer: DrawerMenu(),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_cine.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido superpuesto
          const Center(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}