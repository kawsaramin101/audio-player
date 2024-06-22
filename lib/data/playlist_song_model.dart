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
    // Check if the PlaylistSong already exists
    final existingPlaylistSong = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlist.id))
        .and()
        .song((q) => q.idEqualTo(song.id))
        .findFirst();

    // If the PlaylistSong already exists, do nothing
    if (existingPlaylistSong != null) {
      return;
    }

    // Fetch the highest order value in the playlist
    final maxOrderPlaylistSong = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlist.id))
        .sortByOrderDesc()
        .findFirst();

    final newOrder = (maxOrderPlaylistSong?.order ?? -1) + 1;

    // If the PlaylistSong does not exist, create a new one
    final newPlaylistSong = PlaylistSong()
      ..playlist.value = playlist
      ..song.value = song
      ..order = newOrder;

    await isar.playlistSongs.put(newPlaylistSong);
    await newPlaylistSong.playlist.save();
    await newPlaylistSong.song.save();
  });
}

Future<void> deletePlaylistSong(Isar isar, Song song, int playlistId) async {
  await isar.writeTxn(() async {
    final playlistSong = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlistId))
        .and()
        .song((q) => q.idEqualTo(song.id))
        .findFirst();

    if (playlistSong != null) {
      await isar.playlistSongs.delete(playlistSong.id);
      await playlistSong.playlist.save();
    }
  });
}
