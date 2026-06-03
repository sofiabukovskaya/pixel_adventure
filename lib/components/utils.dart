import 'package:pixel_adventure/components/collision_bloc.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionBloc block) {
  final hitbox = player.playerHitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;

  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;

  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX &&
      fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY);
}
