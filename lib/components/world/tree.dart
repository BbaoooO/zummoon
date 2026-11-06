import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../../core/mixins/damageable.dart';
import '../../core/mixins/solid.dart';
import 'resource_drop.dart';

class Tree extends PositionComponent with Damageable, Solid {
  Tree({required Vector2 position, required Random random})
      : _variant = random.nextInt(3),
        super(
          position: position,
          size: Vector2.all(86 + random.nextDouble() * 28),
          anchor: Anchor.center,
          priority: 6,
        ) {
    initHp(kTreeHp);
  }

  final int _variant;

  static const _palettes = [
    [Color(0xFF1F6B2B), Color(0xFF2E8B3A), Color(0xFF5BBF5E)],
    [Color(0xFF1B5E3A), Color(0xFF2A7F55), Color(0xFF4FB38A)],
    [Color(0xFF2F6B1F), Color(0xFF4C9A2A), Color(0xFF8BD14F)],
  ];

  final Paint _p = Paint();
  final Paint _outline = Paint()
    ..color = const Color(0xFF123A1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _shadow = Paint()..color = const Color(0x44000000);

  @override
  double get hitRadius => size.x * 0.38;

  @override
  double get solidRadius => size.x * 0.16; // chỉ phần thân cây là cản

  @override
  Future<void> onLoad() async {
    popIn();
  }

  @override
  void onDeath() {
    final n = kTreeWoodMin +
        globalRandom.nextInt(kTreeWoodMax - kTreeWoodMin + 1);
    for (var i = 0; i < n; i++) {
      parent?.add(ResourceDrop(type: ResourceType.wood, origin: position.clone()));
    }
    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.25, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final pal = _palettes[_variant];

    canvas.drawOval(
      Rect.fromCenter(
          center: c.translate(6, 10), width: size.x * 0.95, height: size.y * 0.8),
      _shadow,
    );

    _p.color = pal[0];
    canvas.drawCircle(c, size.x * 0.42, _p);
    canvas.drawCircle(c, size.x * 0.42, _outline);

    _p.color = pal[1];
    canvas.drawCircle(c.translate(-size.x * 0.05, -size.y * 0.05), size.x * 0.32, _p);

    _p.color = pal[2];
    canvas.drawCircle(c.translate(-size.x * 0.1, -size.y * 0.1), size.x * 0.16, _p);

    // thân cây nhìn từ trên xuống
    _p.color = const Color(0xFF6B4423);
    canvas.drawCircle(c.translate(size.x * 0.05, size.y * 0.05), size.x * 0.07, _p);

    if (isFlashing) {
      canvas.drawCircle(c, size.x * 0.42, Paint()..color = const Color(0x77FFFFFF));
    }
    if (hp < maxHp) {
      renderHpBar(
          canvas, Rect.fromLTWH(size.x * 0.2, -4, size.x * 0.6, 6));
    }
  }
}