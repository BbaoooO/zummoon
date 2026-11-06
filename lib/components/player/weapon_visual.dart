import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/weapon.dart';

/// Vũ khí cầm trên tay (con của Hand phải). Gốc xoay tại tâm bàn tay.
class WeaponVisual extends PositionComponent {
  WeaponVisual()
      : super(position: Vector2.all(kHandRadius), angle: restAngle, priority: 1);

  /// Góc nghỉ: vũ khí giơ chếch ra trước (pi/2 = chĩa thẳng về phía trước)
  static const double restAngle = pi / 2 - 0.9;

  WeaponType _weapon = WeaponType.fist;
  bool _swinging = false;

  void setWeapon(WeaponType w) {
    _weapon = w;
    if (isMounted && w != WeaponType.fist) {
      add(ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.1, reverseDuration: 0.15),
      ));
    }
  }

  void swing() {
    if (_swinging || _weapon == WeaponType.fist) return;
    _swinging = true;
    add(RotateEffect.by(
      1.9,
      EffectController(
        duration: 0.08,
        reverseDuration: 0.16,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      onComplete: () => _swinging = false,
    ));
  }

  @override
  void render(Canvas canvas) {
    if (_weapon == WeaponType.fist) return;
    paintWeapon(canvas, _weapon);
  }
}