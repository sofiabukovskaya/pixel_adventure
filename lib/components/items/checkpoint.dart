import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/core/sprite_animation_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  static const String _assetPath = 'Items/Checkpoints/Checkpoint';

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive,
      ),
    );
    animation = game.spriteAnimationFrom(
      '$_assetPath/Checkpoint (No Flag).png',
      amount: 1,
      textureSize: Vector2.all(64),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) _raiseFlag();
    super.onCollisionStart(intersectionPoints, other);
  }

  Future<void> _raiseFlag() async {
    animation = game.spriteAnimationFrom(
      '$_assetPath/Checkpoint (Flag Out) (64x64).png',
      amount: 26,
      textureSize: Vector2.all(64),
      loop: false,
    );

    await animationTicker?.completed;

    animation = game.spriteAnimationFrom(
      '$_assetPath/Checkpoint (Flag Idle)(64x64).png',
      amount: 10,
      textureSize: Vector2.all(64),
    );
  }
}
