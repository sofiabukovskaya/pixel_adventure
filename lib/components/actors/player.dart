import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/actors/chicken.dart';
import 'package:pixel_adventure/components/items/checkpoint.dart';
import 'package:pixel_adventure/components/items/fruit.dart';
import 'package:pixel_adventure/components/traps/saw.dart';
import 'package:pixel_adventure/components/world/collision_block.dart';
import 'package:pixel_adventure/core/audio.dart';
import 'package:pixel_adventure/core/custom_hitbox.dart';
import 'package:pixel_adventure/core/sprite_animation_factory.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({super.position, this.character = 'Ninja Frog'});

  final String character;

  static const double _gravity = 9.8;
  static const double _jumpForce = 260;
  static const double _terminalVelocity = 300;
  static const double _moveSpeed = 100;
  static const double _fixedDeltaTime = 1 / 60;
  static const CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();

  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  List<CollisionBlock> collisionBlocks = [];
  double _accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = position.clone();
    add(RectangleHitbox(position: hitbox.position, size: hitbox.size));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _accumulatedTime += dt;

    while (_accumulatedTime >= _fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(_fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(_fixedDeltaTime);
        _checkVerticalCollisions();
      }

      _accumulatedTime -= _fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement = 0;
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!reachedCheckpoint) {
      switch (other) {
        case final Fruit fruit:
          fruit.collect();
        case Saw _:
          _respawn();
        case final Chicken chicken:
          chicken.resolvePlayerCollision();
        case Checkpoint _:
          _reachCheckpoint();
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void collidedWithEnemy() => _respawn();

  void _loadAllAnimations() {
    animations = {
      PlayerState.idle: _characterAnimation('Idle', 11),
      PlayerState.running: _characterAnimation('Run', 12),
      PlayerState.jumping: _characterAnimation('Jump', 1),
      PlayerState.falling: _characterAnimation('Fall', 1),
      PlayerState.hit: _characterAnimation('Hit', 7, loop: false),
      PlayerState.appearing: _effectAnimation('Appearing', 7),
      PlayerState.disappearing: _effectAnimation('Desappearing', 7),
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _characterAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return game.spriteAnimationFrom(
      'Main Characters/$character/$state (32x32).png',
      amount: amount,
      textureSize: Vector2.all(32),
      loop: loop,
    );
  }

  SpriteAnimation _effectAnimation(String state, int amount) {
    return game.spriteAnimationFrom(
      'Main Characters/$state (96x96).png',
      amount: amount,
      textureSize: Vector2.all(96),
      loop: false,
    );
  }

  void _updatePlayerState() {
    if ((velocity.x < 0 && scale.x > 0) || (velocity.x > 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }

    current = switch (velocity) {
      Vector2(y: < 0) => PlayerState.jumping,
      Vector2(y: > 0) => PlayerState.falling,
      Vector2(x: != 0) => PlayerState.running,
      _ => PlayerState.idle,
    };
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * _moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    game.playSfx(Sfx.jump);
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform || !_collidesWith(block)) continue;

      if (velocity.x > 0) {
        velocity.x = 0;
        position.x = block.x - hitbox.offsetX - hitbox.width;
        break;
      }
      if (velocity.x < 0) {
        velocity.x = 0;
        position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
        break;
      }
    }
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (!_collidesWith(block)) continue;

      if (velocity.y > 0) {
        velocity.y = 0;
        position.y = block.y - hitbox.height - hitbox.offsetY;
        isOnGround = true;
        break;
      }
      if (velocity.y < 0 && !block.isPlatform) {
        velocity.y = 0;
        position.y = block.y + block.height - hitbox.offsetY;
        break;
      }
    }
  }

  bool _collidesWith(CollisionBlock block) {
    final playerX = position.x + hitbox.offsetX;
    final playerY = position.y + hitbox.offsetY;

    final fixedX = scale.x < 0
        ? playerX - (hitbox.offsetX * 2) - hitbox.width
        : playerX;
    final fixedY = block.isPlatform ? playerY + hitbox.height : playerY;

    return fixedX < block.x + block.width &&
        fixedX + hitbox.width > block.x &&
        fixedY < block.y + block.height &&
        playerY + hitbox.height > block.y;
  }

  Future<void> _respawn() async {
    game.playSfx(Sfx.hit);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(const Duration(milliseconds: 400), () => gotHit = false);
  }

  Future<void> _reachCheckpoint() async {
    reachedCheckpoint = true;
    game.playSfx(Sfx.disappear);

    if (scale.x > 0) {
      position -= Vector2.all(32);
    } else if (scale.x < 0) {
      position += Vector2(32, -32);
    }
    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint = false;
    position = Vector2.all(-640);

    Future.delayed(const Duration(seconds: 3), game.loadNextLevel);
  }
}
