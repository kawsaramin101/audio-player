import 'dart:convert';
import 'dart:io';

class MediaInfo {
  final String trackName;
  final List<String> trackArtistNames;
  final String albumName;
  final String albumArtistName;
  final int trackNumber;
  final int albumLength;
  final int year;
  final String genre;
  final String authorName;
  final String writerName;
  final int discNumber;
  final String mimeType;
  final int trackDuration;
  final int bitrate;

  MediaInfo({
    required this.trackName,
    required this.trackArtistNames,
    required this.albumName,
    required this.albumArtistName,
    required this.trackNumber,
    required this.albumLength,
    required this.year,
    required this.genre,
    required this.authorName,
    required this.writerName,
    required this.discNumber,
    required this.mimeType,
    required this.trackDuration,
    required this.bitrate,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      trackName: json['trackName'] as String? ?? '',
      trackArtistNames: List<String>.from(json['trackArtistNames'] ?? []),
      albumName: json['albumName'] as String? ?? '',
      albumArtistName: json['albumArtistName'] as String? ?? '',
      trackNumber: int.tryParse(json['trackNumber'] as String? ?? '') ?? 0,
      albumLength: int.tryParse(json['albumLength'] as String? ?? '') ?? 0,
      year: int.tryParse(json['year'] as String? ?? '') ?? 0,
      genre: json['genre'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      writerName: json['writerName'] as String? ?? '',
      discNumber: int.tryParse(json['discNumber'] as String? ?? '') ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      trackDuration: int.tryParse(json['trackDuration'] as String? ?? '') ?? 0,
      bitrate: int.tryParse(json['bitrate'] as String? ?? '') ?? 0,
    );
  }
}

Future<MediaInfo> getMediaInfo(String filePath) async {
  final result = await Process.run('mediainfo', ['--Output=JSON', filePath]);

  if (result.exitCode != 0) {
    throw Exception('Failed to retrieve media info: ${result.stderr}');
  }

  final output = json.decode(result.stdout);
  final mediaInfoJson = output['media']['track'][0];

  return MediaInfo.fromJson(mediaInfoJson);
}
