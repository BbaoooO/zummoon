import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/building.dart';
import '../../core/mixins/damageable.dart';
import '../../core/mixins/solid.dart';
import '../../game/zummoon_game.dart';
import '../vfx/debris_burst.dart';

/// Lớp cha của mọi công trình. Tự có HP, rung, popup (Damageable) và cản đường (Solid).
abstract class Building extends PositionComponent
    with Damageable, Solid, HasGameReference<ZummoonGame> {
  Building(this.type, {required Vector2 position, bool rotated = false})
      : super(
          position: position,
          size: type.sizeFor(rotated),
          anchor: Anchor.center,
          priority: 6,
        ) {
    initHp(type.hp);
  }

  final BuildingType type;

  final Paint _flashPaint = Paint()..color = const Color(0x66FFFFFF);

  @override
  bool get punchable => false; // không tự đấm công trình của mình

  @override
  double get hitRadius => max(size.x, size.y) * 0.5;

  @override
  Vector2? pushOut(Vector2 p, double r) => pushOutOfRect(p, r);

  @override
  Future<void> onLoad() async {
    popIn(); // xuất hiện kiểu nảy
  }

  @override
  void onDeath() {
    parent?.add(DebrisBurst(
      at: position.clone(),
      colors: const [
        Color(0xFFB98B54),
        Color(0xFF6B4423),
        Color(0xFF8A929E),
      ],
      count: 16,
      speed: 200,
    ));
    removeFromParent();
  }

  /// Subclass vẽ thân công trình
  void renderBody(Canvas canvas);

  @override
  void render(Canvas canvas) {
    renderBody(canvas);

    if (isFlashing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8)),
        _flashPaint,
      );
    }
    if (hp < maxHp) {
      renderHpBar(canvas, Rect.fromLTWH(size.x * 0.1, -14, size.x * 0.8, 6));
    }
  }
}