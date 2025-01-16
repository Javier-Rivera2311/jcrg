import 'package:jcrg/screens/navigation_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: FluentThemeData(
        brightness: Brightness.light, // Tema claro
        accentColor: Colors.blue, // Color de acento
        scaffoldBackgroundColor: Colors.white, // Fondo del scaffold
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark, // Tema oscuro
        accentColor: Colors.blue, // Color de acento
        scaffoldBackgroundColor: Colors.black, // Fondo del scaffold
      ),
      themeMode: ThemeMode.system, // Cambia automáticamente entre claro y oscuro
      home: NavigationScreen(),
    );
  }
}
