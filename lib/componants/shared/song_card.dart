import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.song != null) {
          context.read<AudioPlayerNotifier>().setSong(
                widget.song!,
                widget.playListId!,
                widget.playlistSongId!,
                true,
              );
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
          color: context.watch<AudioPlayerNotifier>().currentSong!.id ==
                  widget.song!.id
              ? const Color(0xFF2A2A2A)
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
            child: Row(
              children: <Widget>[
                Icon(
                  context.watch<AudioPlayerNotifier>().currentSong!.id ==
                              widget.song!.id &&
                          context.watch<AudioPlayerNotifier>().isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 30.0,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        child: isHovered
                            ? Marquee(
                                text: widget.song!.filePath?.split('/').last ??
                                    'Unknown',
                                style: const TextStyle(fontSize: 13),
                                scrollAxis: Axis.horizontal,
                                velocity: 100.0,
                                blankSpace: 80.0,
                                startAfter: const Duration(milliseconds: 600),
                              )
                            : Text(
                                widget.song!.filePath?.split('/').last ??
                                    'Unknown',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                      ),
                      const Text(
                        'Artist Placeholder', // Placeholder text for the artist's name
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // Handle favorite toggle logic
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle more options logic
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
