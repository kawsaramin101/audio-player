import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:music/data/playlist_model.dart' as playlist_model;
import 'package:music/routes/route_arguments/playlist_arguments.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        Container(
          color: Theme.of(context).primaryColor,
          child: AppBar(
            title: Text('Playlist ${playlist?.name ?? ''}'),
            automaticallyImplyLeading: true, // Enable back button
          ),
        ),
        playlist == null
            ? const Center(child: CircularProgressIndicator())
            : playlist!.songs.isEmpty
                ? Expanded(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/addSongToPlaylist",
                            arguments: PlaylistArguments(playlist!.id),
                          );
                        },
                        child: const Text('Add Song'),
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/addSongToPlaylist",
                                arguments: PlaylistArguments(playlist!.id),
                              );
                            },
                            child: const Text('Add or Remove Song'),
                          ),
                        ),
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
