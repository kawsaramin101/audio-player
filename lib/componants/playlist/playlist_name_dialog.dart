import 'package:flutter/material.dart';

import 'package:isar/isar.dart';
import 'package:music/routes/route_arguments/playlist_arguments.dart';
import 'package:provider/provider.dart';
import 'package:music/data/playlist_model.dart';

class PlaylistNameDialog extends StatefulWidget {
  const PlaylistNameDialog({super.key});

  @override
  State<PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<PlaylistNameDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  Future<void> _createPlaylist(BuildContext context) async {
    final isar = Provider.of<Isar>(context, listen: false);
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the playlist.')),
      );
      return;
    }

    int playlistId = 0;
    await isar.writeTxn(() async {
      final playlistWithHighestOrder =
          await isar.playlists.where().sortByOrderDesc().findFirst();

      final newPlaylist = Playlist()
        ..name = name
        ..order = (playlistWithHighestOrder?.order ?? 0) + 1
        ..type = PlaylistType.local;

      playlistId = await isar.playlists.put(newPlaylist);
    });

    if (context.mounted) {
      Navigator.of(context).pop();

      await Navigator.pushNamed(
        context,
        "/playlist",
        arguments: PlaylistArguments(playlistId),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create a Playlist',
        style: TextStyle(fontSize: 18.0),
      ),
      content: SizedBox(
        width: 350.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ListBody(
            children: <Widget>[
              const SizedBox(height: 6.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Next'),
          onPressed: () {
            _createPlaylist(context);
          },
        ),
      ],
    );
  }
}
