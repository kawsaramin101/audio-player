import 'package:flutter/material.dart';
import 'package:music/notfiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

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
          SizedBox(
              height: 20.0,
              child: audioPlayerModel.currentSong != null
                  ? Marquee(
                      text: audioPlayerModel.currentSong!.split('/').last,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                      scrollAxis: Axis.horizontal,
                      velocity: 100.0,
                      blankSpace: 80.0,
                      startAfter: const Duration(milliseconds: 500),
                    )
                  : const Text("")),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.fast_rewind_rounded,
                    ),
                  ),
                  if (audioPlayerModel.isPlaying) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.pause,
                      ),
                      onPressed: audioPlayerModel.pause,
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      onPressed: audioPlayerModel.resume,
                    ),
                  ],
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.fast_forward_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.skip_next_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
      },
    );
  }
}
