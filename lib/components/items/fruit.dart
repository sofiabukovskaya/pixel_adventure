import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/audio.dart';
import 'package:pixel_adventure/core/custom_hitbox.dart';
import 'package:pixel_adventure/core/sprite_animation_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Fruit({
    this.fruit = 'Apple',
    super.position,
    super.size,
    super.resetOnRemove = true,
  });

  final String fruit;

  static const CustomHitbox _hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  bool _collected = false;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    add(
      RectangleHitbox(
        position: _hitbox.position,
        size: _hitbox.size,
        collisionType: CollisionType.passive,
      ),
    );
    animation = game.spriteAnimationFrom(
      'Items/Fruits/$fruit.png',
      amount: 17,
      textureSize: Vector2.all(32),
    );
    return super.onLoad();
  }

  Future<void> collect() async {
    if (_collected) return;
    _collected = true;

    game.playSfx(Sfx.collectFruit);
    animation = game.spriteAnimationFrom(
      'Items/Fruits/Collected.png',
      amount: 6,
      textureSize: Vector2.all(32),
      loop: false,
    );

    await animationTicker?.completed;
    removeFromParent();
  }
}
