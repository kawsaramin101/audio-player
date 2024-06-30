import 'package:isar/isar.dart';
import 'package:music/data/playlist_song_model.dart';
import 'package:path/path.dart' as path;

part 'song_model.g.dart';

@Collection()
class Song {
  Id id = Isar.autoIncrement;

  late String? filePath;

  // late String? albumname;
  // late String? artistname;
  late DateTime? createdAt;

  late int length;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get filePathWords {
    if (filePath == null) return [];

    String fileNameWithoutExtension = path.basenameWithoutExtension(filePath!);
    return fileNameWithoutExtension.split(RegExp(r'[ _]'));
  }

  @Backlink(to: 'song')
  final playlists = IsarLinks<PlaylistSong>();
}
