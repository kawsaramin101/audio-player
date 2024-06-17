import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/componants/shared/player.dart';
import 'package:provider/provider.dart';
import 'package:music/data/playlist_model.dart' as playlist_model;
import 'package:music/routes/route_arguments/playlist_arguments.dart';
import 'package:music/componants/shared/songlist.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

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
    final args =
        ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    final isar = Provider.of<Isar>(context, listen: false);

    final fetchedPlaylist = await isar.playlists.get(args.id);
    setState(() {
      playlist = fetchedPlaylist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: playlist == null
          ? const Center(child: Text("Couldn't load the playlist."))
          : Column(
              children: [
                if (playlist!.songs.isEmpty)
                  Expanded(
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
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/addSongToPlaylist",
                        arguments: PlaylistArguments(playlist!.id),
                      );
                    },
                    child: const Text('Add Song'),
                  ),
                if (playlist!.songs.isNotEmpty)
                  Expanded(
                    child: SongList(
                      playlistId: playlist!.id,
                    ),
                  ),
              ],
            ),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          playlist != null ? "Playlist ${playlist!.name}" : "Loading...",
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple[800],
        height: 90.0,
        child: const Player(),
      ),
    );
  }
}
