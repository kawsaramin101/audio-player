import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/componants/shared/song_card.dart';
import 'package:provider/provider.dart';

class SongList extends StatefulWidget {
  final int? playlistId;

  const SongList({super.key, this.playlistId});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List<PlaylistSong> playlistSongs = [];
  Playlist? playlist;
  Stream<void>? playlistStream;
  StreamSubscription<void>? subscription;

  @override
  void initState() {
    super.initState();
    setupWatcher();
    fetchSongs();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void setupWatcher() {
    final isar = Provider.of<Isar>(context, listen: false);
    playlistStream = isar.playlistSongs.watchLazy();

    subscription = playlistStream?.listen((_) {
      fetchSongs();
    });
  }

  void fetchSongs() async {
    final isar = Provider.of<Isar>(context, listen: false);

    if (widget.playlistId != null) {
      playlist = await isar.playlists.get(widget.playlistId!);
    } else {
      playlist = await isar.playlists.filter().nameEqualTo('main').findFirst();
    }

    if (playlist != null) {
      await playlist!.songs.load();

      // Query playlist songs and order by 'order' property
      final loadedPlaylistSongs = await isar.playlistSongs
          .filter()
          .playlist((q) => q.idEqualTo(playlist!.id))
          .sortByOrderDesc()
          .findAll();

      // Load song details for each playlist song
      for (var playlistSong in loadedPlaylistSongs) {
        await playlistSong.song.load();
      }

      setState(() {
        playlistSongs = loadedPlaylistSongs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return playlistSongs.isEmpty
        ? const Center(
            child: Text('No Songs'),
          )
        : ListView.separated(
            itemCount: playlistSongs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final playlistSong = playlistSongs[index];
              final song = playlistSong.song.value;
              if (song != null) {
                return SongCard(
                  song: song,
                  playListId: playlist!.id,
                  playlistSongId: playlistSong.id,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
  }
}
