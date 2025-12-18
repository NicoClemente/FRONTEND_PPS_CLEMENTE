import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool showHomeButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,  // Por defecto muestra back
    this.showHomeButton = true,   // Por defecto muestra home
  });

  @override
  Widget build(BuildContext context) {
    // Determinar qué botón leading usar
    Widget? leadingWidget = leading;
    
    if (leading == null && showBackButton) {
      // Mostrar botón de volver atrás
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Volver',
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    // Construir lista de actions
    List<Widget> appBarActions = [...?actions];
    
    // Agregar botón home al final de las actions
    if (showHomeButton) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Ir al inicio',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'home',
              (route) => false,
            );
          },
        ),
      );
    }

    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: leadingWidget,
      actions: appBarActions.isNotEmpty ? appBarActions : null,
      automaticallyImplyLeading: showBackButton && leading == null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}