import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/patrol_range.dart';
import 'package:pixel_adventure/core/sprite_animation_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  Saw({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    super.position,
    super.size,
  });

  final bool isVertical;
  final double offNeg;
  final double offPos;

  static const double _stepTime = 0.04;
  static const double _moveSpeed = 50;

  double _moveDirection = 1;
  late final PatrolRange _range;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    _range = PatrolRange(
      origin: isVertical ? position.y : position.x,
      offNeg: offNeg,
      offPos: offPos,
    );
    animation = game.spriteAnimationFrom(
      'Traps/Saw/On (38x38).png',
      amount: 8,
      stepTime: _stepTime,
      textureSize: Vector2.all(38),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }

    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= _range.max) {
      _moveDirection = -1;
    } else if (position.y <= _range.min) {
      _moveDirection = 1;
    }
    position.y += _moveDirection * _moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= _range.max) {
      _moveDirection = -1;
    } else if (position.x <= _range.min) {
      _moveDirection = 1;
    }
    position.x += _moveDirection * _moveSpeed * dt;
  }
}
