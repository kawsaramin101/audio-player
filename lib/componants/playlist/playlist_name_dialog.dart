import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
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
  bool isFavouriteAvailable = false;
  bool isFavouriteChecked = false;

  @override
  void initState() {
    super.initState();
    _checkFavouritePlaylist();
  }

  Future<void> _checkFavouritePlaylist() async {
    final isar = Provider.of<Isar>(context, listen: false);
    final favouritePlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.favorite)
        .findFirst();

    if (favouritePlaylist == null) {
      setState(() {
        isFavouriteAvailable = true;
      });
    }
  }

  Future<void> _createPlaylist(BuildContext context) async {
    final isar = Provider.of<Isar>(context, listen: false);
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the playlist.')),
      );
      return;
    }

    await isar.writeTxn(() async {
      final playlistWithHighestOrder =
          await isar.playlists.where().sortByOrderDesc().findFirst();

      final newPlaylist = Playlist()
        ..name = name
        ..order = (playlistWithHighestOrder?.order ?? 0) + 1
        ..type =
            isFavouriteChecked ? PlaylistType.favorite : PlaylistType.local;

      await isar.playlists.put(newPlaylist);
    });

    if (context.mounted) {
      Navigator.of(context).pop();
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
              if (isFavouriteAvailable)
                CheckboxListTile(
                  title: const Text('Favourite'),
                  value: isFavouriteChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isFavouriteChecked = value ?? false;
                    });
                  },
                ),
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
