import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';

class Player extends StatefulWidget {
  // const Player({super.key});
  const Player({super.key});

  @override
  State<Player> createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      _playNextSong();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioPlayerModel = Provider.of<AudioPlayerNotifier>(context);
    if (audioPlayerModel.currentSong != null && audioPlayerModel.isPlaying) {
      _playSong(audioPlayerModel.currentSong!);
    }
  }

  void _playSong(String songPath) async {
    await _audioPlayer.play(DeviceFileSource(songPath));
    if (mounted) {
      context.read<AudioPlayerNotifier>().play();
    }
  }

  void _playNextSong() async {
    final audioPlayerModel =
        Provider.of<AudioPlayerNotifier>(context, listen: false);
    if (audioPlayerModel.currentPlaylistId == null ||
        audioPlayerModel.currentPlaylistSongId == null) return;

    final isar = Provider.of<Isar>(context, listen: false);

    final currentPlaylistSong =
        await isar.playlistSongs.get(audioPlayerModel.currentPlaylistSongId!);
    if (currentPlaylistSong == null) return;

    final nextPlaylistSong = await isar.playlistSongs
        .filter()
        .idEqualTo(audioPlayerModel.currentPlaylistId!)
        .and()
        .orderEqualTo(currentPlaylistSong.order + 1)
        .findFirst();

    if (nextPlaylistSong == null) return;

    await nextPlaylistSong.song.load();
    final nextSong = nextPlaylistSong.song.value;
    if (nextSong == null) return;

    if (mounted) {
      context.read<AudioPlayerNotifier>().setSong(
            nextSong.id,
            audioPlayerModel.currentPlaylistId!,
            nextPlaylistSong.id,
            nextSong.filePath!,
          );
    }

    await _audioPlayer.play(DeviceFileSource(nextSong.filePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerNotifier>(
      builder: (context, audioPlayerModel, child) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
              child: audioPlayerModel.currentSong != null
                  ? Marquee(
                      text: audioPlayerModel.currentSong!.split('/').last,
                      style: const TextStyle(fontSize: 13),
                      scrollAxis: Axis.horizontal,
                      velocity: 100.0,
                      blankSpace: 80.0,
                      startAfter: const Duration(milliseconds: 500),
                    )
                  : const Text(""),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fast_rewind_rounded),
                    ),
                    if (audioPlayerModel.isPlaying) ...[
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () async {
                          await _audioPlayer.pause();
                          if (context.mounted) {
                            context.read<AudioPlayerNotifier>().pause();
                          }
                        },
                      ),
                    ] else if (audioPlayerModel.currentSong != null) ...[
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          _playSong(audioPlayerModel.currentSong!);
                        },
                      ),
                    ],
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fast_forward_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
