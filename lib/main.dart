import 'package:flutter/material.dart';
import 'package:music/routes/home.dart';

void main() {
  runApp(MaterialApp(
    darkTheme: ThemeData(
      brightness: Brightness.dark,
    ),
    themeMode: ThemeMode.dark,
    theme: ThemeData(useMaterial3: true),
    home: const Home(),
  ));
}
