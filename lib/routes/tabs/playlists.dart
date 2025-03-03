import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
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

class _PlaylistsState extends State<Playlists>
    with AutomaticKeepAliveClientMixin {
  late Stream<List<Playlist>> playlistStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    setupPlaylistStream();
  }

  @override
  bool get wantKeepAlive => true;

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

  void _deletePlaylist(int playlistId) async {
    final isar = Provider.of<Isar>(context, listen: false);
    await isar.writeTxn(() async {
      final playlistSongs = await isar.playlistSongs
          .filter()
          .playlist((q) => q.idEqualTo(playlistId))
          .findAll();

      for (final playlistSong in playlistSongs) {
        await isar.playlistSongs.delete(playlistSong.id);

        await isar.playlists.delete(playlistId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                            size: 40.0,
                          )
                        : const Icon(
                            Icons.playlist_play_rounded,
                            size: 50,
                          ),
                    title: Padding(
                      padding: EdgeInsets.only(
                          left: playlist.type == PlaylistType.favorite
                              ? 10.0
                              : 0),
                      child: Text(playlist.name),
                    ),
                    subtitle: FutureBuilder<int>(
                      future: playlist.songs.count(),
                      builder: (context, countSnapshot) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: playlist.type == PlaylistType.favorite
                                  ? 10.0
                                  : 0),
                          child: Text("Songs: ${countSnapshot.data ?? 0}"),
                        );
                      },
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'Delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_rounded),
                              title: Text('Delete'),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'Close',
                            child: ListTile(
                              leading: Icon(Icons.close_rounded),
                              title: Text('Close'),
                            ),
                          ),
                        ];
                      },
                      onSelected: (String value) {
                        switch (value) {
                          case 'Delete':
                            _deletePlaylist(playlist.id);
                            break;
                          case 'Close':
                            break;
                        }
                      },
                      icon: const Icon(Icons.more_vert),
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
