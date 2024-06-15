import 'package:flutter/foundation.dart';

class AudioPlayerNotifier extends ChangeNotifier {
  String? _currentSong;
  int? _currentSongId;
  int? _currentPlaylistSongId;
  int? _currentPlaylistId;
  bool _isPlaying = false;

  String? get currentSong => _currentSong;
  int? get currentSongId => _currentSongId;
  int? get currentPlaylistSongId => _currentPlaylistSongId;
  int? get currentPlaylistId => _currentPlaylistId;
  bool get isPlaying => _isPlaying;

  void setSong(
      int songId, int playlistId, int playlistSongId, String songPath) {
    _currentSongId = songId;
    _currentPlaylistId = playlistId;
    _currentPlaylistSongId = playlistSongId;
    _currentSong = songPath;
    _isPlaying = true;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }
}
