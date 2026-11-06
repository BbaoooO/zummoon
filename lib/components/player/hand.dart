import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'weapon_visual.dart';

/// Một bàn tay: hình tròn, đấm bằng MoveEffect đưa ra rồi kéo về.
/// Tay phải còn giữ [weaponVisual] để cầm vũ khí.
class Hand extends CircleComponent {
  Hand({required Vector2 idlePosition})
      : super(
          radius: kHandRadius,
          position: idlePosition,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFFD2A6),
        );

  bool isPunching = false;
  final WeaponVisual weaponVisual = WeaponVisual();

  final Paint _outline = Paint()
    ..color = const Color(0xFF5A3A1E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  Future<void> onLoad() async {
    add(weaponVisual);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(radius, radius), radius, _outline);
  }

  /// [reach]: quãng đường vươn về phía trước (trục +x cục bộ của Player)
  void punch(double reach) {
    if (isPunching) return;
    isPunching = true;

    add(
      MoveEffect.by(
        Vector2(reach, 0),
        EffectController(
          duration: 0.07,
          reverseDuration: 0.12,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
        onComplete: () => isPunching = false,
      ),
    );
  }
}