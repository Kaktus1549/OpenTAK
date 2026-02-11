import 'package:audioplayers/audioplayers.dart';

final _player = AudioPlayer();

Future<void> playNotif() async {
  await _player.play(AssetSource('sounds/nokia.mp3'));
}