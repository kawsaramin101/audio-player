import 'package:isar/isar.dart';
import 'package:music/data/song_model.dart';

part 'playlist_model.g.dart';

@Collection()
class Playlist {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late PlaylistType type;

  final songs = IsarLinks<Song>();
}

enum PlaylistType {
  main,
  local,
  youtube,
}
