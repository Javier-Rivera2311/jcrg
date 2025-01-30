import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _messageController = TextEditingController();

  void sendUDPMessage(String message) async {
    if (message.isEmpty) return;

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final data = utf8.encode(message);

    // Enviar el mensaje a todos los dispositivos en la red local
    socket.send(data, InternetAddress("192.168.1.255"), 4545);
    print('✅ Notificación enviada: "$message"');

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Notificación', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        leading: Center(
          child: Image.asset(
            'lib/assets/Log/LOGO.png',
            height: 75,
            width: 75,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Escribe el mensaje de notificación:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Ingrese el mensaje",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendUDPMessage(_messageController.text);
              },
              child: Text("Enviar Notificación"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 107, 135, 182),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
