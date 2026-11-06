import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../../core/mixins/damageable.dart';
import '../../core/mixins/solid.dart';
import 'resource_drop.dart';

class Rock extends PositionComponent with Damageable, Solid {
  Rock({required Vector2 position, required Random random})
      : _jitter = List.generate(8, (_) => 0.8 + random.nextDouble() * 0.25),
        super(
          position: position,
          size: Vector2.all(64 + random.nextDouble() * 30),
          anchor: Anchor.center,
          priority: 6,
        ) {
    initHp(kRockHp);
  }

  final List<double> _jitter;
  late final Path _body;
  late final Path _highlight;

  final Paint _p = Paint();
  final Paint _outline = Paint()
    ..color = const Color(0xFF2E3036)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()..color = const Color(0x44000000);

  @override
  double get hitRadius => size.x * 0.46;

  @override
  double get solidRadius => size.x * 0.38;

  Path _polygon(double scale, Offset shift) {
    final c = Offset(size.x / 2, size.y / 2) + shift;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = 2 * pi * i / 8;
      final r = size.x * 0.46 * _jitter[i] * scale;
      final pt = Offset(c.dx + cos(a) * r, c.dy + sin(a) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  @override
  Future<void> onLoad() async {
    _body = _polygon(1, Offset.zero);
    _highlight = _polygon(0.55, const Offset(-5, -5));
    popIn();
  }

  @override
  void onDeath() {
    final n = kRockStoneMin +
        globalRandom.nextInt(kRockStoneMax - kRockStoneMin + 1);
    for (var i = 0; i < n; i++) {
      parent?.add(ResourceDrop(type: ResourceType.stone, origin: position.clone()));
    }
    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.25, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(6, 8);
    canvas.drawPath(_body, _shadow);
    canvas.restore();

    _p.color = const Color(0xFF7D7F86);
    canvas.drawPath(_body, _p);
    _p.color = const Color(0xFFA6A9B2);
    canvas.drawPath(_highlight, _p);
    canvas.drawPath(_body, _outline);

    if (isFlashing) {
      canvas.drawPath(_body, Paint()..color = const Color(0x77FFFFFF));
    }
    if (hp < maxHp) {
      renderHpBar(
          canvas, Rect.fromLTWH(size.x * 0.2, -4, size.x * 0.6, 6));
    }
  }
}