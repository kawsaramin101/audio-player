import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'dart:async';

class Player extends StatefulWidget {
  // const Player({super.key});
  const Player({super.key});

  @override
  State<Player> createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late AudioPlayer _audioPlayer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration> _durationSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to the current position of the audio
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to the total duration of the audio
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
                      const Expanded(
                        child: Text(
                          "placeholder",
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures the row takes up minimal space
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              var newPosition =
                                  _currentPosition - const Duration(seconds: 7);
                              if (newPosition < Duration.zero) {
                                newPosition = Duration.zero;
                              }
                              _audioPlayer.seek(newPosition);
                            },
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
                            onPressed: () {
                              var newPosition =
                                  _currentPosition + const Duration(seconds: 7);
                              if (newPosition > _totalDuration) {
                                newPosition = _totalDuration;
                              }
                              _audioPlayer.seek(newPosition);
                            },
                            icon: const Icon(Icons.fast_forward_rounded),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${_formatDuration(_currentPosition)}/${_formatDuration(_totalDuration)}",
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
