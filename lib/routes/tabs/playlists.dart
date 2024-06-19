import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:music/componants/playlist/playlist_name_dialog.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/routes/route_arguments/playlist_arguments.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  late Stream<List<Playlist>> playlistStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    setupPlaylistStream();
  }

  void setupPlaylistStream() {
    final isar = Provider.of<Isar>(context, listen: false);

    playlistStream = isar.playlists
        .where(sort: Sort.desc)
        .anyId()
        .filter()
        .typeEqualTo(PlaylistType.local)
        .or()
        .typeEqualTo(PlaylistType.youtube)
        .watch(fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Playlist>>(
        stream: playlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No playlists available'));
          } else {
            final playlists = snapshot.data!;
            return ListView.separated(
              itemCount: playlists.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  subtitle: Text(
                      'Type: ${playlist.type == PlaylistType.local ? "Local" : "Youtube"}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/playlist',
                      arguments: PlaylistArguments(playlist.id),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
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
