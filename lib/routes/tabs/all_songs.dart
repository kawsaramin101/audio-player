import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:mime/mime.dart';

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
  // MediaInfo? mediaInfo;

  @override
  void initState() {
    super.initState();
  }

  void pickAndScanFolder() async {
    String? folderPath = await pickFolder();
    if (folderPath != null) {
      List<File> files = await scanForMusicFiles(folderPath);
      await saveFilesToIsar(files);
    }
  }

  Future<void> saveFilesToIsar(List<File> files) async {
    final isar = Provider.of<Isar>(context, listen: false);

    // Check if the main playlist exists
    var mainPlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.main)
        .findFirst();

    // If not, create it
    if (mainPlaylist == null) {
      mainPlaylist = Playlist()
        ..name = 'All Songs'
        ..order = 1
        ..type = PlaylistType.main;
      await isar.writeTxn(() async {
        await isar.playlists.put(mainPlaylist!);
      });
    }

    // Create a favourite Playlist if it doesn't exist

    var favouritePlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.favorite)
        .findFirst();

    if (favouritePlaylist == null) {
      favouritePlaylist = Playlist()
        ..name = 'Favorites'
        ..order = 2
        ..type = PlaylistType.favorite;
      await isar.writeTxn(() async {
        await isar.playlists.put(favouritePlaylist!);
      });
    }

    for (var file in files) {
      // final info = await getMediaInfo(file.path);

      var song =
          await isar.songs.filter().filePathEqualTo(file.path).findFirst();

      if (song == null) {
        // If the song doesn't exist, create it
        final fileStat = await file.stat();
        song = Song()
          ..filePath = file.path
          // ..albumname = info.albumName
          // ..artistname = info.trackArtistNames.join(", ")
          ..createdAt = fileStat.changed
          ..length = await file
              .length(); // You might need to calculate the length differently
        await isar.writeTxn(() async {
          await isar.songs.put(song!);
        });
      }

      // Use the createPlaylistSong function to add the song to the playlist
      await createPlaylistSong(isar, song, mainPlaylist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SongList(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: pickAndScanFolder,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Scan'),
              ),
            ),
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
