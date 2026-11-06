import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../../core/mixins/damageable.dart';
import '../../core/mixins/solid.dart';
import '../../core/weapon.dart';
import '../../game/zummoon_game.dart';
import '../vfx/crate_shadow.dart';
import '../vfx/debris_burst.dart';
import '../vfx/shockwave_ring.dart';
import 'resource_drop.dart';
import 'weapon_drop.dart';

class Crate extends PositionComponent
    with Damageable, Solid, HasGameReference<ZummoonGame> {
  Crate({required this.target})
      : super(
          position: target + Vector2(0, -kCrateFallHeight),
          size: Vector2.all(kCrateSize),
          scale: Vector2.all(1.35), // trên cao nên trông to hơn
          anchor: Anchor.center,
          priority: 7,
        ) {
    initHp(kCrateHp);
  }

  /// Vị trí sẽ đáp xuống
  final Vector2 target;

  bool _landed = false;
  double _age = 0;
  double _chute = 1; // 1 = dù mở, 0 = đã xẹp
  late final CrateShadow _shadow;

  bool get landed => _landed;

  final Paint _p = Paint();
  final Paint _line = Paint()
    ..color = const Color(0x55000000)
    ..strokeWidth = 2;
  final Paint _outline = Paint()
    ..color = const Color(0xFF3A2410)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _shadowPaint = Paint()..color = const Color(0x55000000);

  static const _woodColors = [Color(0xFFC8A06A), Color(0xFF8B5A2B)];

  // Chưa đáp thì không đấm được, không cản đường
  @override
  bool get punchable => _landed && !isDead;

  @override
  double get hitRadius => size.x * 0.55;

  @override
  double get solidRadius => size.x * 0.42;

  @override
  Vector2? pushOut(Vector2 p, double r) {
    if (!_landed) return null;
    return super.pushOut(p, r);
  }

  @override
  Future<void> onLoad() async {
    _shadow = CrateShadow(at: target.clone(), duration: kCrateFallTime);
    parent?.add(_shadow);

    add(MoveEffect.to(
      target.clone(),
      EffectController(duration: kCrateFallTime, curve: Curves.easeIn),
      onComplete: _land,
    ));
  }

  void _land() {
    _landed = true;
    position.setFrom(target);
    scale.setValues(1, 1);
    _shadow.removeFromParent();

    // ép dẹt khi chạm đất
    add(ScaleEffect.by(
      Vector2(1.25, 0.8),
      EffectController(
          duration: 0.08, reverseDuration: 0.14, curve: Curves.easeOut),
    ));
    parent?.add(ShockwaveRing(
      at: target.clone(),
      maxRadius: 100,
      color: const Color(0xFFD7B98E),
    ));
    parent?.add(DebrisBurst(
      at: target.clone(),
      colors: const [Color(0xFFD7C3A0), Color(0xFFB59A70)],
      count: 12,
      speed: 130,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (!_landed) {
      final p = (_age / kCrateFallTime).clamp(0.0, 1.0).toDouble();
      final k = 1 + 0.35 * (1 - Curves.easeIn.transform(p));
      scale.setValues(k, k);
    } else if (_chute > 0) {
      _chute = max(0.0, _chute - dt / 0.35);
    }
  }

  // ---------- Vỡ -> rớt đồ ----------
  @override
  void onDeath() {
    if (globalRandom.nextDouble() < kCrateWeaponChance) {
      parent?.add(WeaponDrop(
        weapon: WeaponType.randomDrop(globalRandom),
        origin: position.clone(),
      ));
    } else {
      final n = kCrateScrapMin +
          globalRandom.nextInt(kCrateScrapMax - kCrateScrapMin + 1);
      for (var i = 0; i < n; i++) {
        parent?.add(
            ResourceDrop(type: ResourceType.scrap, origin: position.clone()));
      }
    }

    parent?.add(DebrisBurst(
      at: position.clone(),
      colors: _woodColors,
      count: 18,
      speed: 230,
    ));

    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.12),
      onComplete: removeFromParent,
    ));
  }

  // ---------- Vẽ ----------
  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    if (_chute > 0) _renderChute(canvas);

    if (_landed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(5, 7, w, h), const Radius.circular(8)),
        _shadowPaint,
      );
    }

    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(8));
    _p.color = const Color(0xFFB98B54);
    canvas.drawRRect(body, _p);

    // ván gỗ
    for (var i = 1; i < 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(4, y), Offset(w - 4, y), _line);
    }

    // khung trong + thanh chéo
    final inner = Rect.fromLTWH(9, 9, w - 18, h - 18);
    _p.color = const Color(0xFFD7AE72);
    canvas.drawRect(inner, _p);
    canvas.drawRect(
        inner,
        Paint()
          ..color = const Color(0xFF6B4423)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawLine(inner.topLeft, inner.bottomRight, _line..strokeWidth = 4);
    canvas.drawLine(inner.topRight, inner.bottomLeft, _line);
    _line.strokeWidth = 2;

    // huy hiệu giữa hộp
    _p.color = const Color(0xFFFFC107);
    canvas.drawCircle(Offset(w / 2, h / 2), 9, _p);
    canvas.drawCircle(
        Offset(w / 2, h / 2),
        9,
        Paint()
          ..color = const Color(0xFF3A2410)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // đinh tán 4 góc
    _p.color = const Color(0xFF5B5F66);
    for (final o in [
      const Offset(5, 5),
      Offset(w - 5, 5),
      Offset(5, h - 5),
      Offset(w - 5, h - 5),
    ]) {
      canvas.drawCircle(o, 3, _p);
    }

    canvas.drawRRect(body, _outline);

    if (isFlashing) {
      canvas.drawRRect(body, Paint()..color = const Color(0x77FFFFFF));
    }
    if (hp < maxHp && _landed) {
      renderHpBar(canvas, Rect.fromLTWH(w * 0.1, -14, w * 0.8, 7));
    }
  }

  void _renderChute(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final sway = _landed ? 0.0 : sin(_age * 3) * 0.08;
    const radius = 50.0;
    const cy = -62.0;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(sway);
    canvas.translate(0, (1 - _chute) * 50); // xẹp xuống về phía hộp
    canvas.scale(_chute, _chute);

    // dây dù
    final rope = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(-radius, cy), Offset(-w / 2, -h / 2), rope);
    canvas.drawLine(const Offset(radius, cy), Offset(w / 2, -h / 2), rope);
    canvas.drawLine(const Offset(0, cy), Offset(0, -h / 2), rope);

    // tán dù: 6 múi đỏ/trắng xen kẽ
    final rect = Rect.fromCircle(center: const Offset(0, cy), radius: radius);
    final seg = Paint();
    for (var i = 0; i < 6; i++) {
      seg.color = i.isEven ? const Color(0xFFE74C3C) : const Color(0xFFF5F5F5);
      canvas.drawArc(rect, pi + i * pi / 6, pi / 6, true, seg);
    }
    canvas.drawArc(
      rect,
      pi,
      pi,
      true,
      Paint()
        ..color = const Color(0xFF3A1A14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
  }
}