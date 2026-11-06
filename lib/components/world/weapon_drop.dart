import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../../core/weapon.dart';
import '../../game/zummoon_game.dart';
import '../../systems/weapon_manager.dart';
import '../vfx/damage_popup.dart';
import '../vfx/shockwave_ring.dart';

/// Vũ khí rơi ra từ Crate: lơ lửng, tỏa sáng theo độ hiếm, tự nhặt khi lại gần.
class WeaponDrop extends PositionComponent with HasGameReference<ZummoonGame> {
  WeaponDrop({required this.weapon, required Vector2 origin})
      : super(
          position: origin,
          size: Vector2.all(44),
          anchor: Anchor.center,
          priority: 4,
        );

  final WeaponType weapon;
  double _age = 0;
  bool _taken = false;
  late final TextPainter _label;

  final Paint _glow = Paint();
  final Paint _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  Future<void> onLoad() async {
    _label = TextPainter(
      text: TextSpan(
        text: weapon.displayName,
        style: TextStyle(
          color: weapon.rarity.color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // văng ra + phình to nảy
    final a = globalRandom.nextDouble() * 2 * pi;
    add(MoveEffect.by(
      Vector2(cos(a), sin(a)) * (40 + globalRandom.nextDouble() * 30),
      EffectController(duration: 0.4, curve: Curves.easeOutCubic),
    ));
    scale = Vector2.zero();
    add(ScaleEffect.to(
      Vector2.all(1),
      EffectController(duration: 0.5, curve: Curves.elasticOut),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age < 0.6 || _taken) return;

    if (game.player.position.distanceTo(position) < kWeaponPickupRadius) {
      _pickup();
    }
  }

  void _pickup() {
    _taken = true;
    final result = game.weapons.add(weapon);
    final popupAt = game.player.position + Vector2(0, -52);

    switch (result) {
      case WeaponAddResult.added:
      case WeaponAddResult.replaced:
        parent?.add(DamagePopup(
          'Trang bị: ${weapon.displayName}!',
          at: popupAt,
          color: weapon.rarity.color,
          fontSize: 20,
        ));
      case WeaponAddResult.duplicate:
        game.state.add(ResourceType.scrap, 3);
        parent?.add(DamagePopup(
          'Trùng! +3 Scrap',
          at: popupAt,
          color: const Color(0xFF6EC6FF),
          fontSize: 18,
        ));
    }

    parent?.add(ShockwaveRing(
      at: game.player.position.clone(),
      maxRadius: 90,
      color: weapon.rarity.color,
    ));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final color = weapon.rarity.color;
    final pulse = 0.6 + 0.4 * sin(_age * 4);
    final bob = sin(_age * 3) * 3;
    final c = Offset(size.x / 2, size.y / 2 + bob);

    _glow.color = color.withAlpha((90 * pulse).round());
    canvas.drawCircle(c, 26 + 3 * pulse, _glow);
    _ring.color = color.withAlpha(200);
    canvas.drawCircle(c, 24, _ring);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(pi / 4);
    canvas.translate(0, weapon.length / 2);
    paintWeapon(canvas, weapon);
    canvas.restore();

    _label.paint(canvas, Offset((size.x - _label.width) / 2, size.y + 6));
  }
}