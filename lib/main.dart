import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'widgets/theme_manager.dart'; // Asegúrate de que exista este archivo
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
  ),
  darkTheme: FluentThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.blue,
  ),
  themeMode: themeNotifier.themeMode, // Cambia entre tema claro y oscuro
  home: const NavigationScreen(tasks: [],),
);

  }
}
