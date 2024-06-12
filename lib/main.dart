import 'package:flutter/material.dart';
import 'package:music/notfiers/audio_player_notifier.dart';
import 'package:music/routes/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AudioPlayerModel(),
    child: MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true),
      home: const Home(),
    ),
  ));
}
