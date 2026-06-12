import 'package:flame_audio/flame_audio.dart';

enum Sfx {
  jump('jump.wav'),
  hit('hit.wav'),
  disappear('disappear.wav'),
  collectFruit('collect_fruit.wav'),
  bounce('bounce.wav');

  const Sfx(this.fileName);

  final String fileName;
}

mixin SoundEffects {
  bool playSound = true;
  double soundVolume = 0.3;

  void playSfx(Sfx sfx) {
    if (playSound) FlameAudio.play(sfx.fileName, volume: soundVolume);
  }
}
