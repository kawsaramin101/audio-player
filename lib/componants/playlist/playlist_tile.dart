import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:yaru/yaru.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatefulWidget {
  final bool selected;
  final Playlist playlist;

  const PlaylistTile(
      {super.key, required this.selected, required this.playlist});

  @override
  State<PlaylistTile> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  late Isar isar;

  @override
  void initState() {
    super.initState();
    isar = Provider.of<Isar>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerNotifier = Provider.of<AudioPlayerNotifier>(context);

    return YaruMasterTile(
      selected: widget.selected,
      leading: Icon(
        audioPlayerNotifier.currentPlaylistId != null &&
                audioPlayerNotifier.currentPlaylistId! == widget.playlist.id
            ? Icons.graphic_eq_outlined
            : Icons.playlist_play_rounded,
        size: 30,
      ),
      title: Text(widget.playlist.name),
      subtitle: FutureBuilder<int>(
        future: widget.playlist.songs.count(),
        builder: (context, countSnapshot) {
          return Text("Songs: ${countSnapshot.data ?? 0}");
        },
      ),
      trailing: MenuAnchor(
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return YaruIconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert),
              tooltip: 'Show menu',
            );
          },
          menuChildren: [
            MenuItemButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              onPressed: () => {
                // _renamePlaylist(playlist.id);
              },
              leadingIcon: const Icon(Icons.edit_note_rounded),
              child: const Text('Rename'),
            ),
            MenuItemButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              onPressed: () => {deletePlaylist(isar, widget.playlist.id)},
              leadingIcon: const Icon(Icons.delete_rounded),
              child: const Text('Delete'),
            ),
            MenuItemButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              onPressed: () => {},
              leadingIcon: const Icon(Icons.close_rounded),
              child: const Text('Close'),
            ),
          ]),
    );
  }
}
