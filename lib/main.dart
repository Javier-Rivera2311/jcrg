import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart'; // Import the window_manager package
import 'widgets/theme_manager.dart'; // Archivo para manejar el tema
import 'screens/navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1400, 600),
    center: true,
    backgroundColor: Color.fromARGB(0, 0, 0, 0),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal, // Add this line to show the title bar with buttons
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });

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
