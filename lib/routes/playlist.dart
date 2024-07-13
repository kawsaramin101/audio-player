import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/componants/playlist/add_or_remove_song_dialog.dart';
import 'package:provider/provider.dart';
import 'package:music/data/playlist_model.dart' as playlist_model;
import 'package:music/componants/shared/songlist.dart';

class Playlist extends StatefulWidget {
  final int playlistId;
  const Playlist({super.key, required this.playlistId});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  playlist_model.Playlist? playlist;

  @override
  void initState() {
    super.initState();
    fetchPlaylist();
  }

  void fetchPlaylist() async {
    final isar = Provider.of<Isar>(context, listen: false);
    final fetchedPlaylist = await isar.playlists.get(widget.playlistId);
    setState(() {
      playlist = fetchedPlaylist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        playlist == null
            ? const Center(child: Text("Playlist not found!"))
            : playlist!.songs.isEmpty
                ? Expanded(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (BuildContext context) {
                              return AddOrRemoveSongDialog(
                                playlist: playlist!,
                              );
                            },
                          ).then((_) {
                            fetchPlaylist();
                          });
                        },
                        child: const Text('Add Song'),
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SongList(
                            playlistId: playlist!.id,
                          ),
                        ),
                      ],
                    ),
                  ),
      ],
    );
  }
}
