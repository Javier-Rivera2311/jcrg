import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  DeliveriesScreenState createState() => DeliveriesScreenState();
}

class DeliveriesScreenState extends State<DeliveriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Entregas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        leading: Center(
        child: FlutterLogo(size:25)),
        actions: [
          ThemeSwitcher(), // Botón para cambiar el tema
        ],
      ),
      // Fondo dinámico según el tema
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(
          child: Text('Aquí va el contenido'),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Se puede cambiar según el ThemeSwitcher
      home: const DeliveriesScreen(),
    ),
  );
}
