import 'package:flutter/material.dart';
import 'package:music/componants/playlist/playlist_name_dialog.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const PlaylistNameDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
