import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/building.dart';
import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../world/resource_drop.dart';
import 'building.dart';
import 'building_painters.dart';

class FarmingHouse extends Building {
  FarmingHouse({required Vector2 position})
      : super(BuildingType.farm, position: position);

  double _timer = 0;

  final Paint _ringBack = Paint()..color = const Color(0xAA000000);
  final Paint _ring = Paint()
    ..color = const Color(0xFFFFC107)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    _timer += dt * game.farmSpeed; // Module 6: Buff tăng tốc farm
    if (_timer >= kFarmInterval) {
      _timer = 0;
      _produce();
    }
  }

  void _produce() {
    final door = position + Vector2(0, size.y / 2 + 4);
    for (var i = 0; i < kFarmWood; i++) {
      parent?.add(ResourceDrop(type: ResourceType.wood, origin: door.clone()));
    }
    for (var i = 0; i < kFarmStone; i++) {
      parent?.add(ResourceDrop(type: ResourceType.stone, origin: door.clone()));
    }
    add(ScaleEffect.by(
      Vector2.all(1.1),
      EffectController(duration: 0.1, reverseDuration: 0.15),
    ));
  }

  @override
  void renderBody(Canvas canvas) {
    paintFarm(canvas, Size(size.x, size.y));

    // vòng tiến độ phía trên
    final p = (_timer / kFarmInterval).clamp(0.0, 1.0).toDouble();
    if (p > 0.02) {
      final c = Offset(size.x / 2, -22);
      canvas.drawCircle(c, 11, _ringBack);
      canvas.drawArc(Rect.fromCircle(center: c, radius: 8), -pi / 2,
          2 * pi * p, false, _ring);
    }
  }
}