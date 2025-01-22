import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'widgets/theme_manager.dart'; // Archivo para manejar el tema
import 'screens/navigation_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'JCRG App',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Fondo claro del scaffold
        cardColor: Colors.white, // Fondo de tarjetas claras
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C), // Fondo oscuro del scaffold
        cardColor: const Color(0xFF2C2C2C), // Fondo de tarjetas oscuras
      ),
      themeMode: themeNotifier.themeMode, // Cambia entre modo claro y oscuro
      home: const NavigationScreen(tasks: []),
    );
  }
}
