import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/data/song_model.dart';
import 'package:provider/provider.dart';

class AddOrRemoveSongDialog extends StatefulWidget {
  final String title;
  final Playlist playlist;
  const AddOrRemoveSongDialog(
      {super.key, required this.playlist, this.title = "Add Song"});

  @override
  State<AddOrRemoveSongDialog> createState() => _AddOrRemoveSongDialogState();
}

class _AddOrRemoveSongDialogState extends State<AddOrRemoveSongDialog> {
  late Isar isar;

  List<Song> songs = [];
  StreamSubscription<void>? songsSubscription;
  StreamSubscription<void>? playlistSongsSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isar = Provider.of<Isar>(context, listen: false);

    fetchSongsAndPlaylist();
    setupWatchers();
  }

  @override
  void dispose() {
    songsSubscription?.cancel();
    playlistSongsSubscription?.cancel();
    super.dispose();
  }

  void fetchSongsAndPlaylist() async {
    final allSongs = await isar.songs.where().findAll();

    setState(() {
      songs = allSongs;
    });
  }

  void setupWatchers() {
    final isar = Provider.of<Isar>(context, listen: false);

    songsSubscription = isar.songs.watchLazy().listen((_) {
      fetchSongsAndPlaylist();
    });

    playlistSongsSubscription = isar.playlistSongs.watchLazy().listen((_) {
      fetchSongsAndPlaylist();
    });
  }

  void onCheckboxChanged(bool? value, Song song) async {
    if (value == true) {
      // Add the song to the playlist if not already added
      await createPlaylistSong(isar, song, widget.playlist);
    } else {
      // Remove the song from the playlist if it exists
      await deletePlaylistSong(isar, song, widget.playlist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 18.0),
      ),
      content: SizedBox(
        width: 350,
        height: 350,
        child: songs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    title: Text(song.filePath!.split('/').last),
                    trailing: Checkbox(
                      value: song.playlists.any(
                          (ps) => ps.playlist.value!.id == widget.playlist.id),
                      onChanged: (bool? value) {
                        onCheckboxChanged(value, song);
                      },
                    ),
                  );
                },
              ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
