import 'package:flutter/material.dart';
import 'package:music/data/playlist_song_model.dart';

import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music/notfiers/audio_player_notifier.dart';

import 'package:music/routes/home.dart';
import 'package:music/routes/playlist.dart' as playlist_route;

import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PlaylistSchema, PlaylistSongSchema, SongSchema],
    directory: dir.path,
  );

  // await clearDatabase(isar);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioPlayerModel()),
        Provider<Isar>.value(value: isar),
      ],
      child: MaterialApp(
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        theme: ThemeData(useMaterial3: true),
        routes: {
          '/': (context) => const Home(),
          '/playlist': (context) => const playlist_route.Playlist(),
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
