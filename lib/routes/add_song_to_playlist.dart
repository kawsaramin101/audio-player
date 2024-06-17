import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/data/song_model.dart'; // Import your Song model
import 'package:music/routes/route_arguments/playlist_arguments.dart';
import 'package:music/data/playlist_model.dart' as playlist_model;
import 'package:provider/provider.dart';

class AddSongToPlaylist extends StatefulWidget {
  const AddSongToPlaylist({super.key});

  @override
  State<AddSongToPlaylist> createState() => _AddSongToPlaylistState();
}

class _AddSongToPlaylistState extends State<AddSongToPlaylist> {
  int? playlistId;
  playlist_model.Playlist? playlist;
  List<Song> songs = [];
  StreamSubscription<void>? songsSubscription;
  StreamSubscription<void>? playlistSongsSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as PlaylistArguments;
    playlistId = args.id;
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
    final isar = Provider.of<Isar>(context, listen: false);
    final allSongs =
        await isar.songs.where().findAll(); // Adjust the query as necessary

    final fetchedPlaylist = await isar.playlists.get(playlistId!);
    setState(() {
      songs = allSongs;
      playlist = fetchedPlaylist;
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
    final isar = Provider.of<Isar>(context, listen: false);

    if (value == true) {
      // Check if the song is already in the playlist
      final existingPlaylistSong = await isar.playlistSongs
          .filter()
          .playlist((q) => q.idEqualTo(playlistId!))
          .and()
          .song((q) => q.idEqualTo(song.id))
          .findFirst();

      if (existingPlaylistSong == null) {
        // Add the song to the playlist if not already added
        await isar.writeTxn(() async {
          final newPlaylistSong = PlaylistSong()
            ..playlist.value = playlist
            ..song.value = song
            ..order = 0;
          await isar.playlistSongs.put(newPlaylistSong);
          await newPlaylistSong.playlist.save();
          await newPlaylistSong.song.save();
        });
      }
    } else {
      // Remove the song from the playlist if it exists
      await isar.writeTxn(() async {
        final playlistSong = await isar.playlistSongs
            .filter()
            .playlist((q) => q.idEqualTo(playlistId!))
            .and()
            .song((q) => q.idEqualTo(song.id))
            .findFirst();

        if (playlistSong != null) {
          await isar.playlistSongs.delete(playlistSong.id);
          await playlistSong.playlist.save(); // Save playlist after deletion
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Songs to Playlist'),
      ),
      body: songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  title: Text(song.filePath!),
                  trailing: Checkbox(
                    value: song.playlists
                        .any((ps) => ps.playlist.value?.id == playlistId),
                    onChanged: (bool? value) {
                      onCheckboxChanged(value, song);
                    },
                  ),
                );
              },
            ),
    );
  }
}
