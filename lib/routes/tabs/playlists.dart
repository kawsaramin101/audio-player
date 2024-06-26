import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:music/componants/playlist/playlist_name_dialog.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/routes/route_arguments/playlist_arguments.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  late Stream<List<Playlist>> playlistStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    setupPlaylistStream();
  }

  void setupPlaylistStream() async {
    final isar = Provider.of<Isar>(context, listen: false);

    playlistStream = isar.playlists
        .where()
        .filter()
        .typeEqualTo(PlaylistType.local)
        .or()
        .typeEqualTo(PlaylistType.favorite)
        .sortByOrder()
        .watch(fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Playlist>>(
        stream: playlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No playlists available'));
          } else {
            final playlists = snapshot.data!;
            return ListView.separated(
              itemCount: playlists.length,
              separatorBuilder: (context, index) => const Divider(
                height: 0.0,
                thickness: 2.0,
              ),
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return Container(
                  color:
                      context.watch<AudioPlayerNotifier>().currentPlaylistId !=
                                  null &&
                              context
                                      .watch<AudioPlayerNotifier>()
                                      .currentPlaylistId! ==
                                  playlist.id
                          ? const Color(0xFF2A2A2A)
                          : null,
                  child: ListTile(
                    leading: playlist.type == PlaylistType.favorite
                        ? const Icon(
                            Icons.favorite_rounded,
                            size: 40,
                          )
                        : const Icon(
                            Icons.playlist_play_rounded,
                            size: 50,
                          ),
                    title: Text(playlist.name),
                    subtitle: FutureBuilder<int>(
                      future: playlist.songs.count(),
                      builder: (context, countSnapshot) {
                        if (countSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (countSnapshot.hasError) {
                          return const Text('Error loading song count');
                        } else if (countSnapshot.hasData) {
                          return Text('Total songs: ${countSnapshot.data}');
                        } else {
                          return const Text('Total songs: 0');
                        }
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Add your onPressed code here
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/playlist',
                        arguments: PlaylistArguments(playlist.id),
                      ).then((_) {
                        // Ensure the stream updates when returning from the playlist detail
                        setState(() {
                          setupPlaylistStream();
                        });
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return const PlaylistNameDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
