import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';

part 'playlist_model.g.dart';

@Collection()
class Playlist {
  Id id = Isar.autoIncrement;

  late String name;
  late int order;

  @enumerated
  late PlaylistType type;

  @Backlink(to: 'playlist')
  final songs = IsarLinks<PlaylistSong>();
}

enum PlaylistType {
  main,
  local,
  favorite,
}

void deletePlaylist(Isar isar, int playlistId) async {
  await isar.writeTxn(() async {
    final playlistSongs = await isar.playlistSongs
        .filter()
        .playlist((q) => q.idEqualTo(playlistId))
        .findAll();

    for (final playlistSong in playlistSongs) {
      await isar.playlistSongs.delete(playlistSong.id);
    }
    await isar.playlists.delete(playlistId);
  });
}
