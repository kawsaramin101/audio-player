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
