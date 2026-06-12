import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/hud/jump_button.dart';
import 'package:pixel_adventure/components/world/level.dart';
import 'package:pixel_adventure/core/audio.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks,
        SoundEffects {
  static const _resolution = (width: 640.0, height: 360.0);
  static const _levelTransitionDelay = Duration(seconds: 1);

  late CameraComponent cam;
  late JoystickComponent joystick;

  bool showControls = true;

  final Player player = Player(character: 'Mask Dude');
  final List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();

    if (showControls) {
      _addJoystick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) _readJoystick();
    super.update(dt);
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    currentLevelIndex = (currentLevelIndex < levelNames.length - 1)
        ? currentLevelIndex + 1
        : 0;
    _loadLevel();
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void _readJoystick() {
    player.horizontalMovement = switch (joystick.direction) {
      JoystickDirection.left ||
      JoystickDirection.upLeft ||
      JoystickDirection.downLeft => -1,
      JoystickDirection.right ||
      JoystickDirection.upRight ||
      JoystickDirection.downRight => 1,
      _ => player.horizontalMovement,
    };
  }

  void _loadLevel() {
    Future.delayed(_levelTransitionDelay, () {
      final world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );
      cam = CameraComponent.withFixedResolution(
        width: _resolution.width,
        height: _resolution.height,
        world: world,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
  }
}
