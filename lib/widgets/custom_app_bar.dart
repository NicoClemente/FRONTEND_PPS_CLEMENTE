import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showHomeButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: actions,
      leading: leading ??
          (showHomeButton
              ? IconButton(
                  icon: const Icon(Icons.home),
                  tooltip: 'Ir al inicio',
                  onPressed: () {
                    // Siempre ir al home, limpiando el stack
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'home',
                      (route) => false,
                    );
                  },
                )
              : null),
      automaticallyImplyLeading: showHomeButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}