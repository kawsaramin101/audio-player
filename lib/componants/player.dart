import 'package:flutter/material.dart';
import 'package:music/notfiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerModel>(
      builder: (context, audioPlayerModel, child) {
        return Column(children: <Widget>[
          Text(audioPlayerModel.currentSong != null
              ? "Playing: ${audioPlayerModel.currentSong!.split('/').last}"
              : "No song playing"),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.fast_rewind_rounded,
                    size: 26.0,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_left_rounded,
                    size: 40.0,
                  ),
                ),
                if (audioPlayerModel.isPlaying) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.pause,
                      size: 26.0,
                    ),
                    onPressed: audioPlayerModel.pause,
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 26.0,
                    ),
                    onPressed: audioPlayerModel.resume,
                  ),
                ],
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_right_rounded,
                    size: 40.0,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.fast_forward_rounded,
                    size: 26.0,
                  ),
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }
}
