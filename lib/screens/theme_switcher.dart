import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jcrg/widgets/theme_manager.dart';

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLightTheme = themeNotifier.themeMode == ThemeMode.light;

    return IconButton(
      icon: Icon(
        isLightTheme ? Icons.light_mode : Icons.dark_mode, // Ícono dinámico
        color: Colors.white, // Color del ícono
      ),
      tooltip: 'Cambiar tema',
      onPressed: () {
        // Alterna entre tema claro y oscuro
        themeNotifier.setThemeMode(
          isLightTheme ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
