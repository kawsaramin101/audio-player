import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';

part 'song_model.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;

  late String? filePath;
  late String? url;
  late int length;

  @Backlink(to: 'song')
  final playlists = IsarLinks<PlaylistSong>();
}
