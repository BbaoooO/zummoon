import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/mixins/damageable.dart';
import '../../game/zummoon_game.dart';
import '../vfx/debris_burst.dart';

/// Kẻ địch TẠM để test Turret: đi chậm về phía House, không gây sát thương.
/// Module 5 sẽ thay bằng Zombie thật (cũng chỉ cần isEnemy => true).
class DebugDummy extends PositionComponent
    with Damageable, HasGameReference<ZummoonGame> {
  DebugDummy({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(40),
          anchor: Anchor.center,
          priority: 8,
        ) {
    initHp(30);
  }

  final Paint _body = Paint()..color = const Color(0xFF7BAA5A);
  final Paint _outline = Paint()
    ..color = const Color(0xFF263A18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _eye = Paint()..color = const Color(0xFFFF3B30);
  final Paint _flashPaint = Paint()..color = const Color(0x88FFFFFF);

  @override
  bool get isEnemy => true;

  @override
  bool get canKnockback => true;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    final to = game.house.position - position;
    if (to.length > kHouseSize / 2 + 30) {
      position.addScaled(to.normalized(), 55 * dt);
    }
  }

  @override
  void onDeath() {
    parent?.add(DebrisBurst(
      at: position.clone(),
      colors: const [Color(0xFF7BAA5A), Color(0xFF4F7A36)],
      count: 12,
      speed: 160,
    ));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, size.x / 2, _body);
    canvas.drawCircle(c, size.x / 2, _outline);
    canvas.drawCircle(c.translate(-8, -4), 4, _eye);
    canvas.drawCircle(c.translate(8, -4), 4, _eye);
    if (isFlashing) canvas.drawCircle(c, size.x / 2, _flashPaint);
    renderHpBar(canvas, Rect.fromLTWH(4, -12, size.x - 8, 6));
  }
}