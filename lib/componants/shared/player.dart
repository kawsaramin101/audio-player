import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => PlayerState();
}

enum RepeatMode {
  noRepeat,
  repeatOne,
  repeatAll,
}

class PlayerState extends State<Player> {
  late AudioPlayer _audioPlayer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration> _durationSubscription;
  RepeatMode repeatMode = RepeatMode.noRepeat;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    retrieveSongInfoFromLocalStorage();

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _shouldPlayNextSong();
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioPlayerModel = Provider.of<AudioPlayerNotifier>(context);
    if (audioPlayerModel.currentSong != null) {
      setSong(audioPlayerModel.currentSong!.filePath!);
    }

    if (audioPlayerModel.isPlaying) {
      _playSong();
    } else {
      _pauseSong();
    }
  }

  void setSong(String songPath) async {
    await _audioPlayer.setSource(DeviceFileSource(songPath));
    _audioPlayer.getDuration().then(
          (value) => setState(() {
            _totalDuration = value!;
          }),
        );
  }

  void _playSong() async {
    await _audioPlayer.resume();
  }

  void _pauseSong() async {
    await _audioPlayer.pause();
  }

  void saveDuration() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("currentDuration", _currentPosition.inSeconds);
  }

  void retrieveSongInfoFromLocalStorage() async {
    final isar = Provider.of<Isar>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? currentSongId = prefs.getInt('currentSongId');
    int? playListId = prefs.getInt("currentPlaylistId");
    int? playlistSongId = prefs.getInt("currentplaylistSongId");
    int repeatModeIndex = prefs.getInt("repeatMode") ?? 0;

    setState(() {
      repeatMode = RepeatMode.values[repeatModeIndex];
    });

    Song? song = await isar.songs.get(currentSongId!);

    if (mounted && playListId != null && playlistSongId != null) {
      context
          .read<AudioPlayerNotifier>()
          .setSong(song!, playListId, playlistSongId, true);
      context.read<AudioPlayerNotifier>().pause();
    }

    int? seconds = prefs.getInt('currentDuration');

    if (seconds != null) {
      // _audioPlayer.seek(Duration(seconds: seconds));
    }
  }

  void saveSongInfoToLocalStorage(
      int songId, int playListId, int playlistSongId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('currentSongId', songId);
    prefs.setInt("currentPlaylistId", playListId);
    prefs.setInt("currentplaylistSongId", playlistSongId);
  }

  void _shouldPlayNextSong() {
    if (repeatMode == RepeatMode.noRepeat) {
      return;
    } else if (repeatMode == RepeatMode.repeatOne) {
    } else {
      _playNextSong();
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
        .playlist((q) => q.idEqualTo(audioPlayerModel.currentPlaylistId!))
        .and()
        .orderLessThan(currentPlaylistSong.order)
        .sortByOrderDesc()
        .findFirst();

    if (nextPlaylistSong == null) return;

    await nextPlaylistSong.song.load();
    final nextSong = nextPlaylistSong.song.value;
    if (nextSong == null || nextSong.filePath == null) return;

    if (mounted) {
      context.read<AudioPlayerNotifier>().setSong(
          nextSong,
          audioPlayerModel.currentPlaylistId!,
          nextPlaylistSong.id,
          context.read<AudioPlayerNotifier>().isPlaying);
    }
  }

  void _playPreviousSong() async {
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
        .playlist((q) => q.idEqualTo(audioPlayerModel.currentPlaylistId!))
        .and()
        .orderGreaterThan(currentPlaylistSong.order)
        .sortByOrder()
        .findFirst();

    if (nextPlaylistSong == null) return;

    await nextPlaylistSong.song.load();
    final nextSong = nextPlaylistSong.song.value;
    if (nextSong == null || nextSong.filePath == null) return;

    if (mounted) {
      context.read<AudioPlayerNotifier>().setSong(
          nextSong,
          audioPlayerModel.currentPlaylistId!,
          nextPlaylistSong.id,
          context.read<AudioPlayerNotifier>().isPlaying);
    }

    // await _audioPlayer.play(DeviceFileSource(nextSong.filePath!));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleRepeatMode() async {
    setState(() {
      switch (repeatMode) {
        case RepeatMode.noRepeat:
          repeatMode = RepeatMode.repeatOne;
          break;
        case RepeatMode.repeatOne:
          repeatMode = RepeatMode.repeatAll;
          break;
        case RepeatMode.repeatAll:
          repeatMode = RepeatMode.noRepeat;
          break;
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("repeatMode", repeatMode.index);
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
                      text: audioPlayerModel.currentSong!.filePath
                              ?.split('/')
                              .last ??
                          'Unknown',
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
                      Expanded(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _toggleRepeatMode,
                              icon: Icon(
                                () {
                                  switch (repeatMode) {
                                    case RepeatMode.noRepeat:
                                      return Icons.repeat;
                                    case RepeatMode.repeatOne:
                                      return Icons.repeat_one_on_rounded;
                                    case RepeatMode.repeatAll:
                                      return Icons.repeat_on_rounded;
                                    default:
                                      return Icons.repeat;
                                  }
                                }(),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures the row takes up minimal space
                        children: [
                          IconButton(
                            onPressed: _playPreviousSong,
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
                                if (context.mounted) {
                                  context.read<AudioPlayerNotifier>().pause();
                                }
                              },
                            ),
                          ] else ...[
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: audioPlayerModel.currentSong == null
                                    ? Colors.grey
                                    : null,
                              ),
                              onPressed: audioPlayerModel.currentSong == null
                                  ? null
                                  : () async {
                                      context
                                          .read<AudioPlayerNotifier>()
                                          .play();
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
                            onPressed: _playNextSong,
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
}
