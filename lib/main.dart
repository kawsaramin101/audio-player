import 'package:flutter/material.dart';
import 'package:music/routes/home.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: const Home(),
  ));
}
