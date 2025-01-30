import 'dart:io';
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'widgets/theme_manager.dart';
import 'screens/navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await localNotifier.setup(
    appName: 'JCRG App',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1400, 600),
    center: true,
    backgroundColor: Color.fromARGB(0, 0, 0, 0),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
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

  // Iniciar la escucha de mensajes UDP
  startUDPListener();
}

/// Escucha notificaciones UDP en el puerto 4545
void startUDPListener() async {
  RawDatagramSocket socket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4545);
  socket.broadcastEnabled = true;

  print("🔎 Escuchando notificaciones UDP en el puerto 4545...");

  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = socket.receive();
      if (datagram != null) {
        String mensaje = utf8.decode(datagram.data);
        print("📩 Notificación UDP recibida: $mensaje");

        // Mostrar la notificación en Windows
        showLocalNotification(mensaje);
      }
    }
  });
}

/// Envía una notificación UDP a todos los dispositivos en la red
void sendUDPMessage(String message) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final data = utf8.encode(message);

  // Enviar el mensaje a todos los dispositivos de la red local
  socket.send(data, InternetAddress("192.168.1.255"), 4545);
  print('✅ Mensaje enviado: "$message"');
}

/// Muestra la notificación en Windows con local_notifier
void showLocalNotification(String message) async {
  final notification = LocalNotification(
    title: '📢 Notificación UDP',
    body: message,
  );
  await notification.show();
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
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        cardColor: const Color(0xFF2C2C2C),
      ),
      themeMode: themeNotifier.themeMode,
      home: const NavigationScreen(tasks: []),
    );
  }
}
