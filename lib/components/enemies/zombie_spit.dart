import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/mixins/damageable.dart';
import '../../game/zummoon_game.dart';
import '../buildings/building.dart';
import '../player/player.dart';
import '../vfx/debris_burst.dart';
import '../world/house.dart';

/// Cục nhổ của Ranged Zombie: bay thẳng, trúng Player / House / công trình đầu tiên.
class ZombieSpit extends PositionComponent with HasGameReference<ZummoonGame> {
  ZombieSpit({
    required Vector2 at,
    required Vector2 direction,
    required this.damage,
    required this.maxDistance,
  })  : _dir = direction.normalized(),
        super(
          position: at,
          size: Vector2.all(14),
          anchor: Anchor.center,
          priority: 25,
        );

  final double damage;
  final double maxDistance;
  final Vector2 _dir;
  double _travelled = 0;
  double _t = 0;

  static const double _speed = 330;

  final Paint _glow = Paint()..color = const Color(0x5584E04A);
  final Paint _core = Paint()..color = const Color(0xFFA6F05C);
  final Paint _edge = Paint()
    ..color = const Color(0xFF2E5A12)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;

    final step = _speed * dt;
    position.addScaled(_dir, step);
    _travelled += step;
    if (_travelled > maxDistance) {
      removeFromParent();
      return;
    }

    for (final d in game.damageables) {
      if (d.isDead) continue;
      if (!(d is Player || d is House || d is Building)) continue;
      if (d.position.distanceTo(position) <= d.hitRadius * 0.85 + 6) {
        d.takeDamage(damage, from: position);
        parent?.add(DebrisBurst(
          at: position.clone(),
          colors: const [Color(0xFFA6F05C), Color(0xFF4F8A1E)],
          count: 8,
          speed: 100,
        ));
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final pulse = 1 + 0.15 * sin(_t * 20);
    canvas.drawCircle(c, 11 * pulse, _glow);
    canvas.drawCircle(c, 6.5 * pulse, _core);
    canvas.drawCircle(c, 6.5 * pulse, _edge);
  }
}