import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Ayuda', style: TextStyle(color: Colors.white)),
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
      body: Center(
        child: Text(
          'Ayuda',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
