import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music/notifiers/audio_player_notifier.dart';
import 'package:music/notifiers/search_notifier.dart';
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

  Playlist? favoritePlaylist;
  Stream<void>? playlistStream;
  StreamSubscription<void>? subscription;
  TextEditingController searchController = TextEditingController();

  final ItemScrollController itemScrollController = ItemScrollController();

  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    setupWatcher();
    fetchSongs();

    final audioPlayerNotifier =
        Provider.of<AudioPlayerNotifier>(context, listen: false);
    audioPlayerNotifier.songNotifer.addListener(_listenSongChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final searchNotifierProvider = Provider.of<SearchNotifierProvider>(context);
    final valueNotifier = searchNotifierProvider.valueNotifier;

    valueNotifier.addListener(() {
      if (valueNotifier.value != null && valueNotifier.value != "") {
        _onSearchChanged(valueNotifier.value!);
        setState(() {
          _searchTerm = valueNotifier.value!;
        });
      } else {
        setState(() {
          _searchTerm = "";
        });
      }
    });
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
    if (query.isNotEmpty) {
      debugPrint("Ran");

      final queryParts = query.toLowerCase().split(' ');
      final searchResults = playlistSongs.where((playlistSong) {
        final song = playlistSong.song.value;
        if (song != null) {
          return queryParts.every((part) => song.filePathWords
              .any((word) => word.toLowerCase().contains(part.toLowerCase())));
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
  }

  void _listenSongChange() {
    if (mounted) {
      final audioPlayerNotifier =
          Provider.of<AudioPlayerNotifier>(context, listen: false);

      int index = playlistSongs.indexWhere((playlistSong) =>
          playlistSong.id == audioPlayerNotifier.currentPlaylistSongId!);
      if (searchController.text.isEmpty && index != -1) {
        itemScrollController.scrollTo(
            index: index,
            alignment: 0.4,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsToDisplay =
        _searchTerm.isNotEmpty ? filteredPlaylistSongs : playlistSongs;

    return Column(
      children: [
        Row(
          children: [widget.child ?? Container()],
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
                    key:
                        PageStorageKey<String>('songlist-${widget.playlistId}'),
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
