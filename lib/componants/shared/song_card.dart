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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.song != null) {
          // Assuming song path is the song file path
          context.read<AudioPlayerNotifier>().setSong(
                widget.song!.id,
                widget.playListId!,
                widget.playlistSongId!,
                widget.song!.filePath!,
              );
        }
      },
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (event) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
          child: SizedBox(
            height: 20,
            child: _isHovered
                ? Marquee(
                    text: widget.song!.filePath!.split('/').last,
                    style: const TextStyle(fontSize: 13),
                    scrollAxis: Axis.horizontal,
                    velocity: 100.0,
                    blankSpace: 80.0,
                    startAfter: const Duration(milliseconds: 600),
                  )
                : Text(
                    widget.song!.filePath!.split('/').last,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
        ),
      ),
    );
  }
}
