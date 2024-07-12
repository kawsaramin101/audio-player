import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/componants/playlist/playlist_name_dialog.dart';
import 'package:music/componants/playlist/playlist_tile.dart';
import 'package:music/componants/shared/appbar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/routes/tabs/all_songs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaru/yaru.dart';

import 'package:music/componants/shared/player.dart';

import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import 'package:music/data/playlist_model.dart' as playlist_model;
import 'package:music/routes/playlist.dart' as playlist_route;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Isar isar;
  bool isLoading = true;
  int? _dragTargetIndex;

  List<playlist_model.Playlist> playlists = [];

  playlist_model.Playlist? selectedPlaylist;
  int selectedPlaylistIndex = 0;

  YaruPageController? controller;

  @override
  void initState() {
    super.initState();
    isar = Provider.of<Isar>(context, listen: false);
    setupPlaylistStream();
  }

  void setupPlaylistStream() async {
    final Stream<void> playlistStream =
        isar.playlists.where().watch(fireImmediately: true);
    final Stream<void> playlistSongStream =
        isar.playlistSongs.where().watch(fireImmediately: true);

    playlistStream.listen((_) {
      fetchPlaylist();
    });

    playlistSongStream.listen((_) {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getInt("selectedPlaylistIndex")! <= playlists.length) {
        selectedPlaylistIndex = prefs.getInt("selectedPlaylistIndex") ?? 0;
      } else {
        selectedPlaylistIndex = 0;
      }
    });
  }

  void deletePlaylist(int id) {
    controller?.index = 0;
    playlist_model.deletePlaylist(isar, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isLoading
          ? MyAppbar(
              selectedPlaylist:
                  selectedPlaylist ?? playlists[selectedPlaylistIndex])
          : AppBar(),
      body: isLoading
          ? const Center(child: YaruCircularProgressIndicator())
          : YaruMasterDetailPage(
              controller: controller,
              onSelected: (index) async {
                if (index != null) {
                  setState(() {
                    selectedPlaylist = playlists[index];
                  });
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt("selectedPlaylistIndex", index);
                }
              },
              initialIndex: selectedPlaylistIndex,
              appBar: AppBar(
                title: const Text("Playlists"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "New playlist",
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
                return Column(
                  children: [
                    Draggable<int>(
                      data: index,
                      feedback: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          width: availableWidth,
                          child: PlaylistTile(
                            deletePlaylist: deletePlaylist,
                            selected: selected,
                            playlist: playlists[index],
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: PlaylistTile(
                          deletePlaylist: deletePlaylist,
                          selected: selected,
                          playlist: playlists[index],
                        ),
                      ),
                      child: DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          final oldIndex = details.data;
                          setState(() {
                            final playlist = playlists.removeAt(oldIndex);
                            playlists.insert(index, playlist);
                            _dragTargetIndex = null;
                          });
                        },
                        onWillAcceptWithDetails: (details) {
                          return details.data != index;
                        },
                        onMove: (details) {
                          setState(() {
                            _dragTargetIndex = index;
                          });
                        },
                        onLeave: (data) {
                          setState(() {
                            _dragTargetIndex = null;
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return PlaylistTile(
                            deletePlaylist: deletePlaylist,
                            selected: selected,
                            playlist: playlists[index],
                          );
                        },
                      ),
                    ),
                    if (_dragTargetIndex == index)
                      Container(
                        height: 2,
                        color: Colors.grey[400],
                      ),
                  ],
                );
              },
              pageBuilder: (context, index) {
                if (playlists[index].type == playlist_model.PlaylistType.main) {
                  return const AllSongs();
                }
                return playlist_route.Playlist(
                  playlistId: playlists[index].id,
                );
              },
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
