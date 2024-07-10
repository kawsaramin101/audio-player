import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/componants/playlist/playlist_name_dialog.dart';
import 'package:music/componants/playlist/playlist_tile.dart';
import 'package:music/componants/shared/appbar.dart';
import 'package:music/componants/shared/songlist.dart';
import 'package:yaru/yaru.dart';

import 'package:music/componants/shared/player.dart';

import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import 'package:music/data/playlist_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Isar isar;
  bool isLoading = true;

  late Stream<void>? playlistStream;

  StreamSubscription<void>? playlistSubscription;

  List<Playlist> playlists = [];
  Playlist? selectedPlaylist;

  @override
  void initState() {
    super.initState();
    isar = Provider.of<Isar>(context, listen: false);
    fetchPlaylist();
  }

  void setupPlaylistStream() async {
    playlistStream = isar.playlists.where().watch(fireImmediately: true);
    playlistSubscription = playlistStream?.listen((_) {
      fetchPlaylist();
    });
  }

  void fetchPlaylist() async {
    final fetchedPlaylist =
        await isar.playlists.where().sortByOrder().findAll();
    setState(() {
      playlists = fetchedPlaylist;
      isLoading = false;
    });

    setState(() {
      selectedPlaylist = playlists.firstWhere(
        (item) => item.type == PlaylistType.main,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(selectedPlaylist: selectedPlaylist),
      body: isLoading
          ? const Center(child: YaruCircularProgressIndicator())
          : YaruMasterDetailPage(
              onSelected: (index) {
                if (index != null) {
                  setState(() {
                    selectedPlaylist = playlists[index];
                  });
                }
              },
              appBar: AppBar(
                title: const Text("Playlists"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (BuildContext context) {
                          return const PlaylistNameDialog();
                        },
                      );
                    },
                  ),
                ],
              ),
              length: playlists.length,
              layoutDelegate:
                  const YaruMasterFixedPaneDelegate(paneWidth: 250.0),

              tileBuilder: (context, index, selected, availableWidth) {
                return PlaylistTile(
                    selected: selected, playlist: playlists[index]);
              },
              pageBuilder: (context, index) => SongList(
                playlistId: playlists[index].id,
              ),
              // pageBuilder: (context, index) => Navigator(
              //   onGenerateRoute: (RouteSettings settings) {
              //     WidgetBuilder builder;
              //     switch (settings.name) {
              //       case '/':
              //         builder = (BuildContext context) => const Home();
              //         break;
              //       case '/playlist':
              //         builder = (BuildContext context) {
              //           final args = settings.arguments as PlaylistArguments;
              //           return playlist_route.Playlist(playlistId: args.id);
              //         };
              //         break;
              //       case '/addSongToPlaylist':
              //         builder = (BuildContext context) => AddSongToPlaylist(
              //               args: settings.arguments as PlaylistArguments,
              //             );
              //         break;
              //       default:
              //         throw Exception('Invalid route: ${settings.name}');
              //     }
              //     return MaterialPageRoute(
              //         builder: builder, settings: settings);
              //   },
              // ),
            ),
      bottomNavigationBar: const BottomAppBar(
        elevation: 10.0,
        // color: Color(0xff31363b),
        color: Color.fromARGB(255, 56, 54, 54),
        height: 125.0,
        child: Player(),
      ),
    );
  }
}
