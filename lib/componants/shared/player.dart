import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late AudioPlayer audioPlayer;
  List<Song> songs = [];
  List<int> shuffledPlaylistSongIds = [];

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  late StreamSubscription<Duration> positionSubscription;
  late StreamSubscription<Duration> durationSubscription;

  RepeatMode repeatMode = RepeatMode.repeatAll;
  bool shuffle = false;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    retrieveSongInfoFromLocalStorage();

    positionSubscription = audioPlayer.onPositionChanged.listen((position) {
      onPositionChanged(position);
    });

    durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      shouldPlayNextSong();
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    positionSubscription.cancel();
    durationSubscription.cancel();
    audioPlayer.dispose();
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
      playSong();
    } else {
      pauseSong();
    }

    if (audioPlayerModel.currentPlaylistId != null) {
      setSuffledIndices(audioPlayerModel.currentPlaylistId!);
    }
  }

  void onPositionChanged(Duration position) {
    setState(() {
      currentPosition = position;
    });

    if (debounce == null || !debounce!.isActive) {
      debounce = Timer(const Duration(seconds: 1), () {
        saveDuration();
        debounce = null;
      });
    }
  }

  void setSong(String songPath) async {
    await audioPlayer.setSource(DeviceFileSource(songPath));
    audioPlayer.getDuration().then(
          (value) => setState(() {
            totalDuration = value!;
          }),
        );
  }

  void playSong() async {
    await audioPlayer.resume();
  }

  void pauseSong() async {
    await audioPlayer.pause();
  }

  void shouldPlayNextSong() {
    if (shuffle) {
      playNextSong(checkShuffle: true);
    } else {
      if (repeatMode == RepeatMode.noRepeat) {
        return;
      } else if (repeatMode == RepeatMode.repeatOne) {
        // Play again from begining
        audioPlayer.seek(Duration.zero);
        audioPlayer.resume();
      } else {
        playNextSong();
      }
    }
  }

  void playNextSong({bool checkShuffle = false}) async {
    final audioPlayerModel =
        Provider.of<AudioPlayerNotifier>(context, listen: false);
    if (audioPlayerModel.currentPlaylistId == null ||
        audioPlayerModel.currentPlaylistSongId == null) return;

    final isar = Provider.of<Isar>(context, listen: false);

    final currentPlaylistSong =
        await isar.playlistSongs.get(audioPlayerModel.currentPlaylistSongId!);

    if (currentPlaylistSong == null) return;

    int nextPlaylistSongIdFromShuffleList = 0;

    if (checkShuffle) {
      int currentPlaylistSongIdIndexFromShuffleList =
          shuffledPlaylistSongIds.indexOf(currentPlaylistSong.id);
      if (currentPlaylistSongIdIndexFromShuffleList >=
          shuffledPlaylistSongIds.length) {
        nextPlaylistSongIdFromShuffleList = shuffledPlaylistSongIds[0];
      } else {
        nextPlaylistSongIdFromShuffleList = shuffledPlaylistSongIds[
            currentPlaylistSongIdIndexFromShuffleList + 1];
      }
    }

    var nextPlaylistSong = checkShuffle
        ? await isar.playlistSongs.get(nextPlaylistSongIdFromShuffleList)
        : await isar.playlistSongs
            .filter()
            .playlist((q) => q.idEqualTo(audioPlayerModel.currentPlaylistId!))
            .and()
            .orderLessThan(currentPlaylistSong.order)
            .sortByOrderDesc()
            .findFirst();

    // Get the first song if nextsong is not found
    nextPlaylistSong ??= await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(audioPlayerModel.currentPlaylistId!))
        .sortByOrderDesc()
        .findFirst();

    await nextPlaylistSong!.song.load();
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

  void playPreviousSong() async {
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
  }

  void saveDuration() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("currentDuration", currentPosition.inSeconds);
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

    if (mounted &&
        song != null &&
        playListId != null &&
        playlistSongId != null) {
      context
          .read<AudioPlayerNotifier>()
          .setSong(song, playListId, playlistSongId, true);
      int? seconds = prefs.getInt('currentDuration');

      if (seconds != null) {
        // audioPlayer.seek(Duration(seconds: seconds));
      }
      context.read<AudioPlayerNotifier>().pause();
    }
  }

  void saveSongInfoToLocalStorage(
      int songId, int playListId, int playlistSongId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('currentSongId', songId);
    prefs.setInt("currentPlaylistId", playListId);
    prefs.setInt("currentplaylistSongId", playlistSongId);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void toggleShuffleMode() async {
    setState(() {
      shuffle = !shuffle;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("shuffleMode", shuffle);
  }

  void toggleRepeatMode() async {
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

  void setSuffledIndices(int playlistId) async {
    final isar = Provider.of<Isar>(context, listen: false);

    final playlistSongs = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlistId))
        .findAll();

    for (var playlistSong in playlistSongs) {
      shuffledPlaylistSongIds.add(playlistSong.id);
    }

    var random = Random();

    for (int i = shuffledPlaylistSongIds.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);

      var temp = shuffledPlaylistSongIds[i];
      shuffledPlaylistSongIds[i] = shuffledPlaylistSongIds[j];
      shuffledPlaylistSongIds[j] = temp;
    }
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
                              onPressed: toggleShuffleMode,
                              icon: shuffle
                                  ? const Icon(Icons.shuffle_on_rounded)
                                  : const Icon(Icons.shuffle_rounded),
                            ),
                            IconButton(
                              onPressed: toggleRepeatMode,
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
                            onPressed: playPreviousSong,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              var newPosition =
                                  currentPosition - const Duration(seconds: 7);
                              if (newPosition < Duration.zero) {
                                newPosition = Duration.zero;
                              }
                              audioPlayer.seek(newPosition);
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
                                  currentPosition + const Duration(seconds: 7);
                              if (newPosition > totalDuration) {
                                newPosition = totalDuration;
                              }
                              audioPlayer.seek(newPosition);
                            },
                            icon: const Icon(Icons.fast_forward_rounded),
                          ),
                          IconButton(
                            onPressed: playNextSong,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${formatDuration(currentPosition)}/${formatDuration(totalDuration)}",
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

enum RepeatMode {
  noRepeat,
  repeatOne,
  repeatAll,
}
