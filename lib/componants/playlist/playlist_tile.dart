import 'package:flutter/material.dart';
import 'package:music/data/playlist_model.dart';
import 'package:yaru/yaru.dart';

class PlaylistTile extends StatelessWidget {
  final bool selected;
  final Playlist playlist;

  const PlaylistTile(
      {super.key, required this.selected, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return YaruMasterTile(
      selected: selected,
      leading: const Icon(
        Icons.playlist_play_rounded,
        size: 30,
      ),
      title: Text(playlist.name),
      subtitle: FutureBuilder<int>(
        future: playlist.songs.count(),
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
                // _deletePlaylist(playlist.id);
              },
              leadingIcon: const Icon(Icons.delete_rounded),
              child: const Text('Delete'),
            ),
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
              onPressed: () => {},
              leadingIcon: const Icon(Icons.close_rounded),
              child: const Text('Close'),
            ),
          ]),
    );
  }
}
