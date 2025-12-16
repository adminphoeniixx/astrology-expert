// import 'package:audioplayers/audioplayers.dart';

// class RingtoneService {
//   static final AudioPlayer _player = AudioPlayer();
//   static bool _isPlaying = false;

//   /// ▶️ PLAY (loop)
//   static Future<void> play() async {
//     if (_isPlaying) return;
//     _isPlaying = true;

//     await _player.setReleaseMode(ReleaseMode.loop);
//     await _player.play(AssetSource('audio/incoming_call.mp3'), volume: 1.0);
//   }

//   /// ⏹ STOP
//   static Future<void> stop() async {
//     if (!_isPlaying) return;
//     _isPlaying = false;
//     await _player.stop();
//   }
// }
