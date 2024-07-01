import 'dart:async';
import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _focusNode = FocusNode();

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
  bool isSeekingByProgressBar = false;
  bool hasSetPostionFromLocalStorage = false;

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
    _focusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioPlayerNotifier = Provider.of<AudioPlayerNotifier>(context);
    if (audioPlayerNotifier.currentSong != null) {
      setSong(audioPlayerNotifier.currentSong!.filePath!);
    }

    if (audioPlayerNotifier.isPlaying) {
      playSong();
    } else {
      pauseSong();
    }

    if (audioPlayerNotifier.currentPlaylistId != null) {
      setSuffledIndices(audioPlayerNotifier.currentPlaylistId!);
    }
  }

  void onPositionChanged(Duration position) {
    if (!isSeekingByProgressBar) {
      setState(() {
        currentPosition = position;
      });
    }

    if (debounce == null || !debounce!.isActive) {
      debounce = Timer(const Duration(seconds: 1), () {
        saveDuration();
        debounce = null;
      });
    }
  }

  void setSong(String songPath) async {
    await audioPlayer.setSource(DeviceFileSource(songPath));

    if (!hasSetPostionFromLocalStorage) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? seconds = prefs.getInt('currentDuration');

      if (seconds != null) {
        try {
          audioPlayer.seek(Duration(seconds: seconds));
        } on TimeoutException {
          // Do nothing
        } catch (e) {
          // Do nothing
        }
      }
      hasSetPostionFromLocalStorage = true;
    }

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
    final audioPlayerNotifier =
        Provider.of<AudioPlayerNotifier>(context, listen: false);
    if (audioPlayerNotifier.currentPlaylistId == null ||
        audioPlayerNotifier.currentPlaylistSongId == null) return;

    final isar = Provider.of<Isar>(context, listen: false);

    final currentPlaylistSong = await isar.playlistSongs
        .get(audioPlayerNotifier.currentPlaylistSongId!);

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
            .playlist(
                (q) => q.idEqualTo(audioPlayerNotifier.currentPlaylistId!))
            .and()
            .orderLessThan(currentPlaylistSong.order)
            .sortByOrderDesc()
            .findFirst();

    // Get the first song if nextsong is not found
    nextPlaylistSong ??= await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(audioPlayerNotifier.currentPlaylistId!))
        .sortByOrderDesc()
        .findFirst();

    await nextPlaylistSong!.song.load();
    final nextSong = nextPlaylistSong.song.value;
    if (nextSong == null || nextSong.filePath == null) return;

    if (mounted) {
      context.read<AudioPlayerNotifier>().setSong(
          nextSong,
          audioPlayerNotifier.currentPlaylistId!,
          nextPlaylistSong.id,
          context.read<AudioPlayerNotifier>().isPlaying);
    }
  }

  void playPreviousSong() async {
    final audioPlayerNotifier =
        Provider.of<AudioPlayerNotifier>(context, listen: false);
    if (audioPlayerNotifier.currentPlaylistId == null ||
        audioPlayerNotifier.currentPlaylistSongId == null) return;

    final isar = Provider.of<Isar>(context, listen: false);

    final currentPlaylistSong = await isar.playlistSongs
        .get(audioPlayerNotifier.currentPlaylistSongId!);

    if (currentPlaylistSong == null) return;

    final nextPlaylistSong = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(audioPlayerNotifier.currentPlaylistId!))
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
          audioPlayerNotifier.currentPlaylistId!,
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
    bool shuffleMode = prefs.getBool("shuffleMode") ?? false;

    setState(() {
      repeatMode = RepeatMode.values[repeatModeIndex];
      shuffle = shuffleMode;
    });

    Song? song = await isar.songs.get(currentSongId!);

    if (mounted &&
        song != null &&
        playListId != null &&
        playlistSongId != null) {
      context
          .read<AudioPlayerNotifier>()
          .setSong(song, playListId, playlistSongId, false);
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

  void _handleKeyPress(KeyEvent event) {
    debugPrint("RUn");
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        debugPrint('Space bar pressed');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        debugPrint('Left arrow pressed');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        debugPrint('Right arrow pressed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerNotifier>(
      builder: (context, audioPlayerNotifier, child) {
        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Spacer widget to take up the empty space at the top
              const Spacer(),
              SizedBox(
                height: 20.0,
                child: audioPlayerNotifier.currentSong != null
                    ? Marquee(
                        text: audioPlayerNotifier.currentSong!.filePath
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
              const SizedBox(
                height: 20.0,
              ),
              ProgressBar(
                progress: currentPosition,
                total: totalDuration,
                barHeight: 3.0,
                thumbRadius: 8.0,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: const TextStyle(fontSize: 13.0),
                thumbGlowRadius: 12.0,
                onSeek: (duration) {
                  isSeekingByProgressBar = true;
                  currentPosition = duration;
                  audioPlayer.seek(
                    duration,
                  );
                  isSeekingByProgressBar = false;
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                        if (audioPlayerNotifier.isPlaying) ...[
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
                              color: audioPlayerNotifier.currentSong == null
                                  ? Colors.grey
                                  : null,
                            ),
                            onPressed: audioPlayerNotifier.currentSong == null
                                ? null
                                : () async {
                                    context.read<AudioPlayerNotifier>().play();
                                  },
                          ),
                        ],
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Go to settings page
                                },
                                icon: const Icon(Icons.settings_rounded),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Go to info page
                                },
                                icon: const Icon(Icons.info),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
