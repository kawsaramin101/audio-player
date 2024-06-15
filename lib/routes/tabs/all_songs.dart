import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:music/componants/shared/song_card.dart';
import 'package:music/componants/shared/songlist.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/data/song_model.dart';
import 'package:provider/provider.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  List<PlaylistSong> playlistSongs = [];

  @override
  void initState() {
    super.initState();
    fetchSongsFromIsar();
  }

  void fetchSongsFromIsar() async {
    final isar = Provider.of<Isar>(context, listen: false);
    final mainPlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.main)
        .findFirst();
    if (mainPlaylist != null) {
      await mainPlaylist.songs.load();
      final loadedPlaylistSongs = mainPlaylist.songs.toList();
      for (var playlistSong in loadedPlaylistSongs) {
        await playlistSong.song.load();
      }
      setState(() {
        playlistSongs = loadedPlaylistSongs;
      });
    }
  }

  void pickAndScanFolder() async {
    String? folderPath = await pickFolder();
    if (folderPath != null) {
      List<File> files = await scanForMusicFiles(folderPath);
      await saveFilesToIsar(files);
      fetchSongsFromIsar();
    }
  }

  Future<void> saveFilesToIsar(List<File> files) async {
    final isar = Provider.of<Isar>(context, listen: false);

    // Check if the main playlist exists outside of transaction
    var mainPlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.main)
        .findFirst();

    // If not, create it
    if (mainPlaylist == null) {
      mainPlaylist = Playlist()
        ..name = 'main'
        ..type = PlaylistType.main;
      await isar.writeTxn(() async {
        await isar.playlists.put(mainPlaylist!);
      });
    }

    final newPlaylistSongs = <PlaylistSong>[];

    for (var file in files) {
      // Check if the song already exists by file path or URL
      var song =
          await isar.songs.filter().filePathEqualTo(file.path).findFirst();

      if (song == null) {
        // If the song doesn't exist, create it
        song = Song()
          ..filePath = file.path
          ..url = null
          ..length = await file
              .length(); // You might need to calculate the length differently
        await isar.writeTxn(() async {
          await isar.songs.put(song!);
        });
      }

      // Create the PlaylistSong entry
      var playlistSong = PlaylistSong()
        ..order = mainPlaylist.songs.length
        ..playlist.value = mainPlaylist
        ..song.value = song;

      newPlaylistSongs.add(playlistSong);
    }

    await isar.writeTxn(() async {
      for (var playlistSong in newPlaylistSongs) {
        await isar.playlistSongs.put(playlistSong);

        // Link the song to the playlist
        mainPlaylist!.songs.add(playlistSong);
        await mainPlaylist.songs.save();

        // Link the playlistSong to the song
        playlistSong.song.value!.playlists.add(playlistSong);
        await playlistSong.song.value!.playlists.save();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: pickAndScanFolder,
          child: const Text('Pick A Folder'),
        ),
        const Expanded(
          child: SongList(
            playlistId: 1,
          ),
        ),
      ],
    );
  }
}

Future<String?> pickFolder() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  return selectedDirectory;
}

Future<List<File>> scanForMusicFiles(String directoryPath) async {
  final directory = Directory(directoryPath);
  List<File> musicFiles = [];

  await for (var entity
      in directory.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      final mimeType = lookupMimeType(entity.path);
      if (mimeType != null && mimeType.startsWith('audio/')) {
        musicFiles.add(entity);
      }
    }
  }

  return musicFiles;
}
