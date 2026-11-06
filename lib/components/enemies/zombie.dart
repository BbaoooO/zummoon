import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/mixins/damageable.dart';
import '../../core/zombie_type.dart';
import '../../game/zummoon_game.dart';
import '../buildings/building.dart';
import '../player/player.dart';
import '../vfx/debris_burst.dart';
import '../world/house.dart';
import 'zombie_spit.dart';

final Paint _zFill = Paint();
final Paint _zLine = Paint()
  ..style = PaintingStyle.stroke
  ..strokeJoin = StrokeJoin.round;
final Paint _zArm = Paint()..strokeCap = StrokeCap.round;
final Paint _zShadow = Paint()..color = const Color(0x44000000);

class Zombie extends PositionComponent
    with Damageable, HasGameReference<ZummoonGame> {
  Zombie({
    required this.type,
    required Vector2 position,
    required int wave,
  })  : _speed = type.speed * min(1.3, 1 + 0.02 * (wave - 1)),
        damage = type.damage * (1 + 0.06 * (wave - 1)),
        _turnSign = globalRandom.nextBool() ? 1.0 : -1.0,
        super(
          position: position,
          size: Vector2.all(type.size),
          anchor: Anchor.center,
          priority: 8,
        ) {
    initHp(type.hp * (1 + 0.12 * (wave - 1)));
    _cooldown = type.attackInterval * globalRandom.nextDouble();
    _retarget = globalRandom.nextDouble() * 0.3;
  }

  final ZombieType type;
  final double damage;
  final double _speed;
  final double _turnSign; // hướng lách khi gặp vật cản: trái hay phải

  Damageable? _target;
  double _cooldown = 0;
  double _retarget = 0;
  double _attackAnim = 0;
  double _time = globalRandom.nextDouble() * 10;
  bool _moving = false;

  double get radius => size.x * 0.45;

  @override
  bool get isEnemy => true;

  @override
  bool get canKnockback => true;

  @override
  double get hitRadius => size.x * 0.5;

  @override
  void knockback(Vector2 direction, double force) =>
      super.knockback(direction, force * type.knockbackMult);

  // ---------- Đăng ký danh sách Zombie ----------
  @override
  void onMount() {
    super.onMount();
    game.zombies.add(this);
  }

  @override
  void onRemove() {
    game.zombies.remove(this);
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    popIn(); // trồi lên khỏi mặt đất
  }

  // ---------------------------------------------------------------------------
  // AI
  // ---------------------------------------------------------------------------

  bool _valid(Damageable t) => !t.isDead && t.isMounted;

  /// Khoảng trống giữa mép Zombie và mép mục tiêu
  double _gapTo(Damageable t) {
    if (t is Player) {
      return position.distanceTo(t.position) - kPlayerSize / 2 - radius;
    }
    // House / Building: hình chữ nhật, anchor center
    final half = t.size / 2;
    final cx = position.x.clamp(t.position.x - half.x, t.position.x + half.x);
    final cy = position.y.clamp(t.position.y - half.y, t.position.y + half.y);
    return Vector2(position.x - cx, position.y - cy).length - radius;
  }

  Damageable? _pickTarget() {
    final player = game.player;
    final house = game.house;

    // ----- Ranged: bắn mục tiêu gần nhất trong tầm -----
    if (type.isRanged) {
      Damageable? best;
      var bestGap = type.range - 10;
      void consider(Damageable d) {
        if (d.isDead) return;
        final g = _gapTo(d);
        if (g < bestGap) {
          best = d;
          bestGap = g;
        }
      }

      consider(player);
      consider(house);
      for (final d in game.damageables) {
        if (d is Building) consider(d);
      }
      return best;
    }

    // ----- Cận chiến -----
    if (!player.isDead && position.distanceTo(player.position) < 200) {
      return player;
    }

    // Công trình chắn đường (nằm phía trước, hướng về House) thì phá nó
    final toHouse = house.position - position;
    final dirHouse = toHouse.isZero() ? Vector2(1, 0) : toHouse.normalized();
    Building? blocker;
    var bestGap = 60.0;
    for (final d in game.damageables) {
      if (d is! Building || d.isDead) continue;
      final g = _gapTo(d);
      if (g > bestGap) continue;
      final to = d.position - position;
      if (to.dot(dirHouse) < 0) continue; // nằm sau lưng
      blocker = d;
      bestGap = g;
    }
    return blocker ?? house;
  }

  /// Lách quanh Cây / Đá / Crate (nhà và công trình thì đánh chứ không lách)
  Vector2 _steer(Vector2 desired) {
    final dir = desired.clone();
    for (final s in game.solids) {
      if (s is House || s is Building) continue;
      final to = s.position - position;
      final reach = s.solidRadius + radius + 26;
      final d2 = to.length2;
      if (d2 >= reach * reach || d2 < 0.0001) continue;

      final d = sqrt(d2);
      if (to.dot(desired) / d < 0.2) continue; // không nằm phía trước
      final tangent = Vector2(-to.y, to.x) / d * _turnSign;
      dir.addScaled(tangent, (1 - d / reach) * 2.2);
    }
    return dir.isZero() ? desired : dir.normalized();
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    _time += dt;
    _cooldown = max(0, _cooldown - dt);
    _attackAnim = max(0, _attackAnim - dt);
    _moving = false;
    if (game.state.gameOver.value) return;

    // Chọn mục tiêu định kỳ
    _retarget -= dt;
    if (_retarget <= 0 || (_target != null && !_valid(_target!))) {
      _retarget = 0.3;
      _target = _pickTarget();
    }

    final Damageable t = _target ?? game.house;
    final toT = t.position - position;
    final gap = _gapTo(t);
    final inRange = type.isRanged
        ? (_target != null && gap <= type.range)
        : gap <= 6;

    if (inRange) {
      _faceTo(atan2(toT.y, toT.x), dt);
      if (_cooldown <= 0) _attack(t);
    } else if (!toT.isZero()) {
      final dir = _steer(toT.normalized());
      position.addScaled(dir, _speed * dt);
      _faceTo(atan2(dir.y, dir.x), dt);
      _moving = true;
    }

    // Đẩy nhau để không dồn thành một cục
    for (final z in game.zombies) {
      if (identical(z, this) || z.isDead) continue;
      final d = position - z.position;
      final minDist = radius + z.radius;
      final l2 = d.length2;
      if (l2 < minDist * minDist && l2 > 0.0001) {
        final l = sqrt(l2);
        position.addScaled(d / l, (minDist - l) * 0.5);
      }
    }

    // Va chạm cứng với Cây, Đá, House, công trình...
    for (final s in game.solids) {
      if (isDeadObject(s)) continue;
      final push = s.pushOut(position, radius);
      if (push != null) position.add(push);
    }

    position.clamp(Vector2.all(radius), kWorldSize - Vector2.all(radius));
  }

  void _faceTo(double target, double dt) {
    var diff = (target - angle) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    angle += diff * min(1.0, dt * 10);
  }

  void _attack(Damageable t) {
    _cooldown = type.attackInterval;
    _attackAnim = 0.25;

    final to = t.position - position;
    final dir = to.isZero() ? Vector2(1, 0) : to.normalized();

    if (type.isRanged) {
      parent?.add(ZombieSpit(
        at: position + dir * radius,
        direction: dir,
        damage: damage,
        maxDistance: type.range * 1.3,
      ));
    } else {
      var dmg = damage;
      if (t is Building) dmg *= type.buildingMult; // Tank phá công trình rất nhanh
      add(MoveEffect.by(
        dir * 10,
        EffectController(duration: 0.07, reverseDuration: 0.12),
      ));
      t.takeDamage(dmg, from: position);
    }
  }

  @override
  void onDeath() {
    game.waves.onZombieDied();
    parent?.add(DebrisBurst(
      at: position.clone(),
      colors: [type.body, type.dark, const Color(0xFF8B1A1A)],
      count: type == ZombieType.tank ? 24 : 12,
      speed: type == ZombieType.tank ? 220 : 160,
    ));
    removeFromParent();
  }

  // ---------------------------------------------------------------------------
  // RENDER (component đã xoay quanh tâm, mặt hướng +x)
  // ---------------------------------------------------------------------------

  @override
  void render(Canvas canvas) {
    final r = size.x / 2;
    final c = Offset(r, r);
    final t = type;

    canvas.drawOval(
      Rect.fromCenter(
          center: c.translate(4, 6), width: size.x, height: size.y * 0.9),
      _zShadow,
    );

    // vệt gió của Zombie nhanh
    if (t == ZombieType.fast && _moving) {
      _zArm
        ..color = const Color(0x66FFFFFF)
        ..strokeWidth = 2;
      for (final dy in [-0.5, 0.0, 0.5]) {
        canvas.drawLine(
            c.translate(-r * 1.1, dy * r), c.translate(-r * 1.9, dy * r), _zArm);
      }
    }

    // hai cánh tay duỗi ra trước, đung đưa khi đi, thúc ra khi đánh
    final bob = sin(_time * (t == ZombieType.fast ? 18 : 9));
    final thrust =
        _attackAnim > 0 ? sin(_attackAnim / 0.25 * pi) * r * 0.6 : 0.0;
    for (final side in const [-1.0, 1.0]) {
      final from = c.translate(r * 0.1, side * r * 0.5);
      final hand =
          c.translate(r * 1.0 + thrust + bob * side * r * 0.12, side * r * 0.6);
      _zArm
        ..color = t.dark
        ..strokeWidth = r * 0.28;
      canvas.drawLine(from, hand, _zArm);
      _zFill.color = t.body;
      canvas.drawCircle(hand, r * 0.24, _zFill);
      _zLine
        ..color = t.dark
        ..strokeWidth = 2;
      canvas.drawCircle(hand, r * 0.24, _zLine);
    }

    // thân
    _zFill.color = t.body;
    canvas.drawCircle(c, r * 0.92, _zFill);
    _zLine
      ..color = t.dark
      ..strokeWidth = 3;
    canvas.drawCircle(c, r * 0.92, _zLine);
    _zFill.color = t.dark.withAlpha(90);
    canvas.drawCircle(c.translate(-r * 0.25, 0), r * 0.45, _zFill); // lưng sậm màu

    // Tank: giáp vai
    if (t == ZombieType.tank) {
      _zFill.color = const Color(0xFF4A4F57);
      for (final side in const [-1.0, 1.0]) {
        final p = c.translate(-r * 0.1, side * r * 0.75);
        canvas.drawCircle(p, r * 0.3, _zFill);
        _zLine
          ..color = const Color(0xFF1C1F24)
          ..strokeWidth = 2.5;
        canvas.drawCircle(p, r * 0.3, _zLine);
      }
    }

    // Ranged: túi độc phát sáng ở miệng, sáng dần khi sắp bắn
    if (t.isRanged) {
      final charge = (1 - _cooldown / t.attackInterval).clamp(0.0, 1.0);
      _zFill.color =
          Color.fromRGBO(166, 240, 92, 0.35 + 0.65 * charge.toDouble());
      canvas.drawCircle(c.translate(r * 0.75, 0), r * (0.16 + 0.12 * charge), _zFill);
    }

    // mắt
    final eye = t.isRanged ? const Color(0xFFB6FF5C) : const Color(0xFFFF3B30);
    _zFill.color = eye;
    for (final dy in const [-0.32, 0.32]) {
      canvas.drawCircle(c.translate(r * 0.45, dy * r), r * 0.14, _zFill);
    }

    if (isFlashing) {
      _zFill.color = const Color(0x99FFFFFF);
      canvas.drawCircle(c, r * 0.92, _zFill);
    }

    // thanh máu (xoay ngược để luôn nằm ngang)
    if (hp < maxHp) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-angle);
      renderHpBar(
          canvas, Rect.fromLTWH(-size.x / 2, -size.y / 2 - 14, size.x, 5));
      canvas.restore();
    }
  }
}