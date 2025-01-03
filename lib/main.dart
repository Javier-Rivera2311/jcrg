import 'package:jcrg/screens/navigation_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: NavigationScreen()

    );
  }
}
