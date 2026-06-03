import 'package:flame/components.dart';

class CollisionBloc extends PositionComponent {
  bool isPlatform;
  CollisionBloc({position, size, this.isPlatform = false})
    : super(position: position, size: size);
}
