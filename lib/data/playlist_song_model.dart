import 'package:isar/isar.dart';
import 'package:music/data/playlist_model.dart';
import 'package:music/data/song_model.dart';

part 'playlist_song_model.g.dart';

@Collection()
class PlaylistSong {
  Id id = Isar.autoIncrement;

  final playlist = IsarLink<Playlist>();
  final song = IsarLink<Song>();

  late int order;
}

Future<void> createPlaylistSong(Isar isar, Song song, Playlist playlist) async {
  await isar.writeTxn(() async {
    final maxOrderPlaylistSong = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlist.id))
        .sortByOrderDesc()
        .findFirst();

    final newOrder = (maxOrderPlaylistSong?.order ?? -1) + 1;

    final newPlaylistSong = PlaylistSong()
      ..playlist.value = playlist
      ..song.value = song
      ..order = newOrder;

    await isar.playlistSongs.put(newPlaylistSong);
    await newPlaylistSong.playlist.save();
    await newPlaylistSong.song.save();
  });
}
