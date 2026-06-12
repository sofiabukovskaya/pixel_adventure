import 'package:flame/components.dart';
import 'package:flame/game.dart';

extension SpriteAnimationFactory on FlameGame {
  SpriteAnimation spriteAnimationFrom(
    String asset, {
    required int amount,
    required Vector2 textureSize,
    double stepTime = 0.05,
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      images.fromCache(asset),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
        loop: loop,
      ),
    );
  }
}
