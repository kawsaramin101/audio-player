import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:marquee/marquee.dart';
import 'package:music/componants/shared/details_dialog.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/data/song_model.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';

class SongCard extends StatefulWidget {
  final Song? song;
  final int? playListId;
  final int? playlistSongId;

  const SongCard({super.key, this.song, this.playListId, this.playlistSongId});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool isHovered = false;
  bool isCurrentSong = false;
  bool isPlaying = false;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();

    setFavouriteState();
  }

  void setFavouriteState() async {
    final isar = Provider.of<Isar>(context, listen: false);

    await widget.song!.playlists.load();

    var favouritePlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.favorite)
        .findFirst();

    if (favouritePlaylist != null && mounted) {
      if (widget.song!.playlists.any((playlistSong) =>
          playlistSong.playlist.value?.id == favouritePlaylist.id)) {
        setState(() {
          isFavourite = true;
        });
      }
    }
  }

  void addToFavourite() async {
    final isar = Provider.of<Isar>(context, listen: false);

    var favouritePlaylist = await isar.playlists
        .filter()
        .typeEqualTo(PlaylistType.favorite)
        .findFirst();

    if (favouritePlaylist == null) {
      final playlistWithHighestOrder =
          await isar.playlists.where().sortByOrderDesc().findFirst();

      favouritePlaylist = Playlist()
        ..name = 'Favorites'
        ..order = (playlistWithHighestOrder?.order ?? 0) + 1
        ..type = PlaylistType.favorite;
      await isar.writeTxn(() async {
        await isar.playlists.put(favouritePlaylist!);
      });
    }

    if (isFavourite) {
      // Remove from playlist
      await deletePlaylistSong(isar, widget.song!, favouritePlaylist.id);
    } else {
      await createPlaylistSong(isar, widget.song!, favouritePlaylist);
    }

    setState(() {
      isFavourite = !isFavourite;
    });
  }

  void _deletePlaylistSong(Song song, int playlistId) {
    final isar = Provider.of<Isar>(context, listen: false);
    deletePlaylistSong(isar, song, playlistId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.song != null) {
          if (context.read<AudioPlayerNotifier>().currentSong != null &&
              context.read<AudioPlayerNotifier>().currentSong!.id ==
                  widget.song!.id) {
            if (context.read<AudioPlayerNotifier>().isPlaying) {
              context.read<AudioPlayerNotifier>().pause();
            } else {
              context.read<AudioPlayerNotifier>().play();
            }
          } else {
            context.read<AudioPlayerNotifier>().setSong(
                  widget.song!,
                  widget.playListId!,
                  widget.playlistSongId!,
                  true,
                );
          }
        }
      },
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHovered = false;
          });
        },
        child: Container(
          color: context.watch<AudioPlayerNotifier>().currentSong != null &&
                  context.watch<AudioPlayerNotifier>().currentSong!.id ==
                      widget.song!.id
              ? const Color(0xFF2A2A2A)
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
            child: Row(
              children: <Widget>[
                Icon(
                  context.watch<AudioPlayerNotifier>().currentSong != null &&
                          context
                                  .watch<AudioPlayerNotifier>()
                                  .currentSong!
                                  .id ==
                              widget.song!.id &&
                          context.watch<AudioPlayerNotifier>().isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 30.0,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        child: Text(
                          widget.song!.filePath?.split('/').last ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                if (widget.playListId == 1)
                  // add favourite button only for All songs list
                  IconButton(
                    icon: isFavourite
                        ? const Icon(
                            Icons.favorite_rounded,
                            color: Colors.pink,
                          )
                        : const Icon(Icons.favorite_border),
                    onPressed: addToFavourite,
                  ),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Details',
                        child: ListTile(
                          leading: Icon(Icons.info_outline_rounded),
                          title: Text('Details'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Remove',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline_rounded),
                          title: Text('Remove'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'Close',
                        child: ListTile(
                          leading: Icon(Icons.close_rounded),
                          title: Text('Close'),
                        ),
                      ),
                    ];
                  },
                  onSelected: (String value) {
                    switch (value) {
                      case 'Remove':
                        _deletePlaylistSong(widget.song!, widget.playListId!);
                        break;
                      case 'Details':
                        showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (BuildContext context) {
                            return DetailsDialog(song: widget.song!);
                          },
                        );
                        break;
                      case 'Close':
                        break;
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
