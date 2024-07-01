import 'package:flutter/foundation.dart';
import 'package:music/data/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerNotifier extends ChangeNotifier {
  Song? _currentSong;
  int? _currentPlaylistSongId;
  int? _currentPlaylistId;
  bool _isPlaying = false;
  final ValueNotifier<Song?> _songNotifier = ValueNotifier<Song?>(null);

  Song? get currentSong => _currentSong;
  int? get currentPlaylistSongId => _currentPlaylistSongId;
  int? get currentPlaylistId => _currentPlaylistId;
  bool get isPlaying => _isPlaying;
  ValueNotifier get songNotifer => _songNotifier;

  void setSong(Song song, int playlistId, int playlistSongId, bool isPlaying) {
    _currentSong = song;
    _currentPlaylistId = playlistId;
    _currentPlaylistSongId = playlistSongId;
    _isPlaying = isPlaying;
    _songNotifier.value = song;
    notifyListeners();
    saveSongInfoToLocalStorage(song.id, playlistId, playlistSongId);
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

void saveSongInfoToLocalStorage(
    int songId, int playlistId, int playlistSongId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('currentSongId', songId);
  prefs.setInt("currentPlaylistId", playlistId);
  prefs.setInt("currentplaylistSongId", playlistSongId);
}
