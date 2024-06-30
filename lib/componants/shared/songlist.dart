import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:music/data/playlist_model.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:music/componants/shared/song_card.dart';
import 'package:provider/provider.dart';

final pageBucket = PageStorageBucket();

class SongList extends StatefulWidget {
  final Widget? child;
  final int? playlistId;

  const SongList({super.key, this.playlistId, this.child});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List<PlaylistSong> playlistSongs = [];
  List<PlaylistSong> filteredPlaylistSongs = [];
  Playlist? playlist;
  Stream<void>? playlistStream;
  StreamSubscription<void>? subscription;
  TextEditingController searchController = TextEditingController();

  final ItemScrollController itemScrollController = ItemScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    setupWatcher();
    fetchSongs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioPlayerModel = Provider.of<AudioPlayerNotifier>(context);
    if (audioPlayerModel.currentSong != null &&
        audioPlayerModel.currentPlaylistId != null &&
        audioPlayerModel.currentPlaylistId == playlist?.id) {
      _listenSongChange(audioPlayerModel.currentPlaylistSongId!);
    }
  }

  void setupWatcher() {
    final isar = Provider.of<Isar>(context, listen: false);
    playlistStream = isar.playlistSongs.watchLazy();

    subscription = playlistStream?.listen((_) {
      fetchSongs();
    });
  }

  void fetchSongs() async {
    final isar = Provider.of<Isar>(context, listen: false);

    if (widget.playlistId != null) {
      playlist = await isar.playlists.get(widget.playlistId!);
    } else {
      playlist = await isar.playlists.filter().nameEqualTo('main').findFirst();
    }

    if (playlist != null) {
      // Query playlist songs and order by 'order' property
      final loadedPlaylistSongs = await isar.playlistSongs
          .filter()
          .playlist((q) => q.idEqualTo(playlist!.id))
          .sortByOrderDesc()
          .findAll();

      // Load song details for each playlist song
      for (var playlistSong in loadedPlaylistSongs) {
        await playlistSong.song.load();
      }

      setState(() {
        playlistSongs = loadedPlaylistSongs;
        if (searchController.text.isEmpty) {
          filteredPlaylistSongs = [];
        } else {
          _onSearchChanged(searchController.text);
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        final queryParts = query.toLowerCase().split(' ');
        final searchResults = playlistSongs.where((playlistSong) {
          final song = playlistSong.song.value;
          if (song != null) {
            return queryParts.every((part) => song.filePathWords.any(
                (word) => word.toLowerCase().contains(part.toLowerCase())));
          }
          return false;
        }).toList();

        setState(() {
          filteredPlaylistSongs = searchResults;
        });
      } else {
        setState(() {
          filteredPlaylistSongs = [];
        });
      }
    });
  }

  void _listenSongChange(int playlistSongId) {
    int index = playlistSongs
        .indexWhere((playlistSong) => playlistSong.id == playlistSongId);
    if (index != -1) {
      itemScrollController.scrollTo(
          index: index,
          alignment: 0.5,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsToDisplay = searchController.text.isNotEmpty
        ? filteredPlaylistSongs
        : playlistSongs;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 40.0,
                  child: TextField(
                    autocorrect: false,
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(fontSize: 14.0),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
              ),
            ),
            widget.child ?? Container()
          ],
        ),
        Expanded(
          child: songsToDisplay.isEmpty
              ? Center(
                  child: Text(searchController.text.isNotEmpty
                      ? 'No matches found'
                      : "No song"),
                )
              : PageStorage(
                  bucket: pageBucket,
                  child: ScrollablePositionedList.separated(
                    itemCount: songsToDisplay.length,
                    itemScrollController: itemScrollController,
                    separatorBuilder: (context, index) => const Divider(
                      height: 0.0,
                      thickness: 2.0,
                    ),
                    itemBuilder: (context, index) {
                      final playlistSong = songsToDisplay[index];
                      final song = playlistSong.song.value;
                      if (song != null) {
                        return SongCard(
                          song: song,
                          playListId: playlist!.id,
                          playlistSongId: playlistSong.id,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    subscription?.cancel();

    super.dispose();
  }
}
