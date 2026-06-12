import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/core/audio.dart';
import 'package:pixel_adventure/core/patrol_range.dart';
import 'package:pixel_adventure/core/sprite_animation_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum ChickenState { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Chicken({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  final double offNeg;
  final double offPos;

  static const double _runSpeed = 80;
  static const double _bounceHeight = 260;

  final Vector2 velocity = Vector2.zero();
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;

  late final Player _player;
  late final PatrolRange _range;

  @override
  FutureOr<void> onLoad() {
    _player = game.player;
    _range = PatrolRange(origin: position.x, offNeg: offNeg, offPos: offPos);

    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _move(dt);
    }

    super.update(dt);
  }

  Future<void> resolvePlayerCollision() async {
    final stomped =
        _player.velocity.y > 0 && _player.y + _player.height > position.y;

    if (stomped) {
      game.playSfx(Sfx.bounce);
      gotStomped = true;
      current = ChickenState.hit;
      _player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      _player.collidedWithEnemy();
    }
  }

  void _loadAllAnimations() {
    animations = {
      ChickenState.idle: _animation('Idle', 13),
      ChickenState.run: _animation('Run', 14),
      ChickenState.hit: _animation('Hit', 15, loop: false),
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _animation(String state, int amount, {bool loop = true}) {
    return game.spriteAnimationFrom(
      'Enemies/Chicken/$state (32x34).png',
      amount: amount,
      textureSize: Vector2(32, 34),
      loop: loop,
    );
  }

  void _move(double dt) {
    velocity.x = 0;

    if (_playerInRange()) {
      final playerOffset = (_player.scale.x > 0) ? 0.0 : -_player.width;
      final chickenOffset = (scale.x > 0) ? 0.0 : -width;

      targetDirection = (_player.x + playerOffset < position.x + chickenOffset)
          ? -1
          : 1;
      velocity.x = targetDirection * _runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool _playerInRange() {
    final playerOffset = (_player.scale.x > 0) ? 0.0 : -_player.width;

    return _range.contains(_player.x + playerOffset) &&
        _player.y + _player.height > position.y &&
        _player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }
}
