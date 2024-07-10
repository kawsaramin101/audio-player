import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/base_layout.dart';
import 'package:yaru/yaru.dart';

import 'package:music/data/playlist_song_model.dart';

import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music/notifiers/audio_player_notifier.dart';

import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';

// Packages installed in Debian: mediainfo

void main() async {
  await YaruWindowTitleBar.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PlaylistSchema, PlaylistSongSchema, SongSchema],
    directory: dir.path,
  );

  // await clearDatabase(isar);
  // TODO: songs doesn't show when added for the first time in playlist page
  // TODO: Show artist and album name
  // TODO: Song sorting by date, name
  // TODO: Custom sorting using drag and drop, show drag handle on hover
  // TODO: settings page
  // TODO: scan feature
  // TODO: implement keyboard shortcuts
  //       - spacebar to pause and play
  //       - arrow right next song, arrow left previous song
  //       - arrow up go back 7 seconds, arrow down skip 7 seconds

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioPlayerNotifier()),
        Provider<Isar>.value(value: isar),
      ],
      child: YaruTheme(
        data:
            const YaruThemeData(themeMode: ThemeMode.dark, useMaterial3: true),
        builder: (context, yaru, child) {
          final ThemeData lightTheme = yaru.theme ?? ThemeData.light();
          final ThemeData darkTheme = yaru.darkTheme ?? ThemeData.dark();

          return MaterialApp(
            theme: _buildTheme(lightTheme, Brightness.light),
            darkTheme: _buildTheme(darkTheme, Brightness.dark),
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
            initialRoute: "/",
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.1),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    ),
  );
}

Future<void> clearDatabase(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.playlists.clear();
    await isar.songs.clear();
    await isar.playlistSongs.clear();
  });
}

ThemeData _buildTheme(ThemeData base, Brightness brightness) {
  const String fontFamily = 'NotoSans';

  return base.copyWith(
    brightness: brightness,
    splashFactory: NoSplash.splashFactory,
    textTheme: Typography().white.apply(
          fontFamily: fontFamily,
        ),
  );
}
