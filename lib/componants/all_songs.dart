import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:music/componants/song_card.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  List<File> musicFiles = [];
  String? selectedFolder;

  void pickAndScanFolder() async {
    String? folderPath = await pickFolder();
    if (folderPath != null) {
      List<File> files = await scanForMusicFiles(folderPath);
      setState(() {
        selectedFolder = folderPath;
        musicFiles = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: pickAndScanFolder,
          child: const Text('Pick A Folder'),
        ),
        selectedFolder != null
            ? Expanded(
                child: ListView.separated(
                  itemCount: musicFiles.length,
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemBuilder: (context, index) {
                    return SongCard(
                      song: musicFiles[index],
                    );
                  },
                ),
              )
            : const Center(child: Text('No folder selected')),
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
