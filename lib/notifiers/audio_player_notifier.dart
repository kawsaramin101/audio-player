import 'package:flutter/foundation.dart';
import 'package:music/data/song_model.dart';

class AudioPlayerNotifier extends ChangeNotifier {
  Song? _currentSong;
  int? _currentPlaylistSongId;
  int? _currentPlaylistId;
  bool _isPlaying = false;

  Song? get currentSong => _currentSong;
  int? get currentPlaylistSongId => _currentPlaylistSongId;
  int? get currentPlaylistId => _currentPlaylistId;
  bool get isPlaying => _isPlaying;

  void setSong(Song song, int playlistId, int playlistSongId) {
    _currentSong = song;
    _currentPlaylistId = playlistId;
    _currentPlaylistSongId = playlistSongId;
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
