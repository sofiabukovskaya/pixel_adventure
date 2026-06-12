import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/actors/chicken.dart';
import 'package:pixel_adventure/components/actors/player.dart';
import 'package:pixel_adventure/components/items/checkpoint.dart';
import 'package:pixel_adventure/components/items/fruit.dart';
import 'package:pixel_adventure/components/traps/saw.dart';
import 'package:pixel_adventure/components/world/background_tile.dart';
import 'package:pixel_adventure/components/world/collision_block.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  Level({required this.levelName, required this.player});

  final String levelName;
  final Player player;

  static const double _tileSize = 16;

  late final TiledComponent level;
  final List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(_tileSize));
    add(level);

    _addScrollingBackground();
    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _addScrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer == null) return;

    final backgroundColor = backgroundLayer.properties.getValue<String>(
      'BackgroundColor',
    );
    add(BackgroundTile(color: backgroundColor ?? 'Gray'));
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer == null) return;

    for (final spawnPoint in spawnPointsLayer.objects) {
      final position = Vector2(spawnPoint.x, spawnPoint.y);
      final size = Vector2(spawnPoint.width, spawnPoint.height);

      switch (spawnPoint.class_) {
        case 'Player':
          player.position = position;
          player.scale.x = 1;
          add(player);
        case 'Fruit':
          add(Fruit(fruit: spawnPoint.name, position: position, size: size));
        case 'Saw':
          add(
            Saw(
              isVertical:
                  spawnPoint.properties.getValue<bool>('isVertical') ?? false,
              offNeg: spawnPoint.properties.getValue<double>('offNeg') ?? 0,
              offPos: spawnPoint.properties.getValue<double>('offPos') ?? 0,
              position: position,
              size: size,
            ),
          );
        case 'Chicken':
          add(
            Chicken(
              offNeg: spawnPoint.properties.getValue<double>('offNeg') ?? 0,
              offPos: spawnPoint.properties.getValue<double>('offPos') ?? 0,
              position: position,
              size: size,
            ),
          );
        case 'Checkpoint':
          add(Checkpoint(position: position, size: size));
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer =
        level.tileMap.getLayer<ObjectGroup>('Collisions') ??
        level.tileMap.getLayer<ObjectGroup>('Collusions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
          isPlatform: collision.class_ == 'Platform',
        );
        collisionBlocks.add(block);
        add(block);
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
