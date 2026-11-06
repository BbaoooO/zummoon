import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/building.dart';
import '../../core/constants.dart';
import '../../core/mixins/damageable.dart';
import '../../game/zummoon_game.dart';
import '../vfx/debris_burst.dart';
import 'building.dart';
import 'building_painters.dart';

class Turret extends Building {
  Turret({required Vector2 position})
      : super(BuildingType.turret, position: position);

  double _aim = -pi / 2;
  double _cooldown = 0;
  double _recoil = 0;
  double _muzzle = 0;
  double _retarget = 0;
  Damageable? _target;

  static double _angleDiff(double a, double b) {
    var d = (b - a) % (2 * pi);
    if (d > pi) d -= 2 * pi;
    return d;
  }

  bool _valid(Damageable? t) =>
      t != null &&
      !t.isDead &&
      t.isMounted &&
      t.position.distanceTo(position) <= kTurretRange * 1.05;

  Damageable? _findTarget() {
    Damageable? best;
    var bestDist = double.infinity;
    for (final d in game.damageables) {
      if (!d.isEnemy || d.isDead) continue;
      final dist = d.position.distanceTo(position);
      if (dist <= kTurretRange && dist < bestDist) {
        best = d;
        bestDist = dist;
      }
    }
    return best;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    _cooldown = max(0, _cooldown - dt);
    _recoil = max(0, _recoil - dt * 6);
    _muzzle = max(0, _muzzle - dt);

    // Tìm mục tiêu định kỳ (không cần mỗi frame)
    _retarget -= dt;
    if (_retarget <= 0 || !_valid(_target)) {
      _retarget = 0.15;
      _target = _findTarget();
    }

    final t = _target;
    if (t == null) {
      _aim += dt * 0.7; // rảnh thì quét vòng
      return;
    }

    // Xoay nòng mượt về phía mục tiêu
    final to = t.position - position;
    final diff = _angleDiff(_aim, atan2(to.y, to.x));
    final step = 9 * dt;
    _aim += diff.abs() <= step ? diff : step * diff.sign;

    // Chỉ bắn khi nòng đã ngắm đúng
    if (_cooldown <= 0 && diff.abs() < 0.12) _fire();
  }

  void _fire() {
    _cooldown = kTurretFireInterval;
    _recoil = 1;
    _muzzle = 0.06;

    final dir = Vector2(cos(_aim), sin(_aim));
    parent?.add(Bullet(
      at: position + dir * 34,
      direction: dir,
      damage: kTurretDamage,
      origin: position.clone(),
    ));
  }

  @override
  void renderBody(Canvas canvas) => paintTurret(
        canvas,
        Size(size.x, size.y),
        aim: _aim,
        recoil: _recoil,
        muzzle: _muzzle,
      );
}

/// Viên đạn: bay thẳng, trúng kẻ địch đầu tiên thì gây sát thương + đẩy lùi.
class Bullet extends PositionComponent with HasGameReference<ZummoonGame> {
  Bullet({
    required Vector2 at,
    required Vector2 direction,
    required this.damage,
    required this.origin,
  })  : _dir = direction.normalized(),
        super(
          position: at,
          size: Vector2(16, 6),
          anchor: Anchor.center,
          angle: atan2(direction.y, direction.x),
          priority: 25,
        );

  final double damage;
  final Vector2 origin;
  final Vector2 _dir;
  double _travelled = 0;

  final Paint _glow = Paint()..color = const Color(0x66FFD54F);
  final Paint _core = Paint()..color = const Color(0xFFFFF3B0);

  @override
  void update(double dt) {
    super.update(dt);

    final step = kBulletSpeed * dt;
    position.addScaled(_dir, step);
    _travelled += step;
    if (_travelled > kTurretRange * 1.4) {
      removeFromParent();
      return;
    }

    for (final d in game.damageables) {
      if (!d.isEnemy || d.isDead) continue;
      if (d.position.distanceTo(position) <= d.hitRadius + 4) {
        d.takeDamage(damage, from: origin);
        parent?.add(DebrisBurst(
          at: position.clone(),
          colors: const [Color(0xFFFFE066), Color(0xFFFF9800)],
          count: 6,
          speed: 90,
        ));
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-3, -3, size.x + 6, size.y + 6), const Radius.circular(6)),
      _glow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(3)),
      _core,
    );
  }
}