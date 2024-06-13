import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSong;
  // String? _currentPlaylistID;
  bool _isPlaying = false;

  String? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  void playSong(String songPath) async {
    _currentSong = songPath;
    await _audioPlayer.play(DeviceFileSource(songPath));
    _isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _isPlaying = false;
    notifyListeners();
  }
}
