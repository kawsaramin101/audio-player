import 'package:isar/isar.dart';
import 'playlist_model.dart';

part 'song_model.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;

  late String? filePath;
  late String? url;
  late int length;

  final playlist = IsarLink<Playlist>();
}
