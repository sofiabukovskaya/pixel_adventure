import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/level.dart';

import 'components/player.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  late CameraComponent cam;
  late JoystickComponent joystick;
  bool showControls = true;

  Player player = Player(character: 'Mask Dude');
  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  Color backgroundColor() => Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();
    if (showControls) {
      addJoystick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
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

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        return;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {}
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );
      cam = CameraComponent.withFixedResolution(
        width: 640,
        height: 360,
        world: world,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
  }
}
