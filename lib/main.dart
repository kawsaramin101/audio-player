import 'package:flutter/material.dart';
import 'package:music/componants/shared/player.dart';
import 'package:music/data/playlist_song_model.dart';

import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music/notifiers/audio_player_notifier.dart';

import 'package:music/routes/home.dart';
import 'package:music/routes/playlist.dart' as playlist_route;
import 'package:music/routes/add_song_to_playlist.dart';
import 'package:music/routes/route_arguments/playlist_arguments.dart';

import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';

// Packages installed in Debian: mediainfo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PlaylistSchema, PlaylistSongSchema, SongSchema],
    directory: dir.path,
  );

  await clearDatabase(isar);
  // TODO: songs doesn't show when added for the first time in playlist page
  // TODO: Show artist and album name

  // TODO: Songlist should scroll to position of the song playing
  // TODO: improve playlist list, add three dot menu
  // TODO: Song sorting by date, name
  // TODO: Custom sorting using drag and drop, show drag handle on hover
  // TODO: settings page
  // TODO: show playlist on the player
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
      child: MaterialApp(
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        initialRoute: "/",
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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext context) => const Home();
              break;
            case '/playlist':
              builder = (BuildContext context) {
                final args = settings.arguments as PlaylistArguments;
                return playlist_route.Playlist(playlistId: args.id);
              };
              break;
            case '/addSongToPlaylist':
              builder = (BuildContext context) => AddSongToPlaylist(
                    args: settings.arguments as PlaylistArguments,
                  );
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFF232323),
        height: 125.0,
        child: Player(),
      ),
    );
  }
}
