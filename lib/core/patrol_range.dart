class PatrolRange {
  PatrolRange({
    required double origin,
    required double offNeg,
    required double offPos,
  }) : min = origin - offNeg * tileSize,
       max = origin + offPos * tileSize;

  static const double tileSize = 16;

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;
}
