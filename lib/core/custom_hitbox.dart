import 'package:flame/components.dart';

class CustomHitbox {
  const CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  Vector2 get position => Vector2(offsetX, offsetY);
  Vector2 get size => Vector2(width, height);
}
