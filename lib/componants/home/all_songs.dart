import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:music/componants/shared/song_card.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';
import 'package:provider/provider.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  List<Song> songs = [];

  String? selectedFolder;

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
      setState(() {
        songs = mainPlaylist.songs.toList();
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
    await isar.writeTxn(() async {
      var playlist = await isar.playlists
          .filter()
          .typeEqualTo(PlaylistType.main)
          .findFirst();
      if (playlist == null) {
        playlist = Playlist()
          ..name = 'main'
          ..type = PlaylistType.main;
        await isar.playlists.put(playlist);
      }

      for (var file in files) {
        final song = Song()
          ..filePath = file.path
          ..url = '' // Add the appropriate URL if needed
          ..length = await file.length(); // Calculate length as needed

        await isar.songs.put(song);
        playlist.songs.add(song);
        await playlist.songs.save();
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
        Expanded(
          child: songs.isNotEmpty
              ? ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return SongCard(
                      song: song,
                    );
                  },
                )
              : const Center(child: Text('No songs available')),
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

  // Recursively scan the directory for music files
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
