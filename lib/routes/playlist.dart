import 'package:flutter/material.dart';

import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:provider/provider.dart';

import 'package:music/data/playlist_model.dart' as playlist_model;

import 'package:music/routes/route_arguments/playlist_arguments.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  playlist_model.Playlist? playlist;
  List<PlaylistSong> playlistSongs = [];

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
    if (fetchedPlaylist != null) {
      await fetchedPlaylist.songs.load();
      setState(() {
        playlist = fetchedPlaylist;
        playlistSongs = fetchedPlaylist.songs.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: playlist == null
          ? const Center(child: CircularProgressIndicator())
          : playlistSongs.isEmpty
              ? Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your song adding logic here
                    },
                    child: const Text('Add Song'),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: playlistSongs.map((playlistSong) {
                      final song = playlistSong.song.value!;
                      return ListTile(
                        title:
                            Text(song.filePath!), // Adjust to show song details
                        // Add more UI elements to display song details
                      );
                    }).toList(),
                  ),
                ),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
            playlist != null ? "Playlist ${playlist!.name}" : "Loading..."),
      ),
    );
  }
}
