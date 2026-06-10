import 'package:flame/components.dart';

class CollisionBloc extends PositionComponent {
  bool isPlatform;
  CollisionBloc({super.position, super.size, this.isPlatform = false});
}
