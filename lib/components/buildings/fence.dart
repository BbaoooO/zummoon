import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/building.dart';
import 'building.dart';
import 'building_painters.dart';

class Fence extends Building {
  Fence({required Vector2 position, bool rotated = false})
      : super(BuildingType.fence, position: position, rotated: rotated);

  @override
  void renderBody(Canvas canvas) => paintFence(canvas, Size(size.x, size.y));
}