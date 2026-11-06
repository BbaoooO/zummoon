import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/house_stats.dart';
import '../../core/mixins/damageable.dart';
import '../../core/mixins/solid.dart';
import '../../game/zummoon_game.dart';
import '../vfx/damage_popup.dart';
import '../vfx/shockwave_ring.dart';
import '../../core/game_state.dart';
import 'resource_drop.dart';

class House extends PositionComponent
    with Damageable, Solid, HasGameReference<ZummoonGame> {
  House()
      : super(
          size: Vector2.all(kHouseSize),
          anchor: Anchor.center,
          position: kWorldSize / 2,
          priority: 5,
        ) {
    initHp(HouseStats.maxHp(1));
  }

  int level = 1;

  // Màu theo "bậc": Lv1-3 gỗ, 4-6 đá, 7-9 gạch, 10 vàng
  static const _wallColors = [
    Color(0xFFC9A66B),
    Color(0xFFB8BCC4),
    Color(0xFFC77B5C),
    Color(0xFFF2D06B),
  ];
  static const _roofColors = [
    Color(0xFF8B3A2E),
    Color(0xFF4F5D75),
    Color(0xFF6B2E2E),
    Color(0xFFB8860B),
  ];

  final Paint _p = Paint();
  final Paint _line = Paint()
    ..color = const Color(0x55000000)
    ..strokeWidth = 3;
  final Paint _outline = Paint()
    ..color = const Color(0xFF2B1D10)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final Paint _shadow = Paint()..color = const Color(0x55000000);
  final TextPaint _lvText = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFC107),
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
  );

  @override
  bool get punchable => false; // không tự đấm nhà mình

  @override
  double get hitRadius => kHouseSize / 2;

  @override
  Vector2? pushOut(Vector2 p, double r) => pushOutOfRect(p, r);

    // ---------- Tự sản xuất Scrap ----------
  double _scrapTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || !HouseStats.producesScrap(level)) return;

    _scrapTimer += dt;
    if (_scrapTimer >= HouseStats.scrapInterval(level)) {
      _scrapTimer = 0;
      parent?.add(ResourceDrop(
        type: ResourceType.scrap,
        origin: position + Vector2(0, size.y / 2 + 6), // thả ra ở cửa nhà
      ));
    }
  }

  // ---------- Nâng cấp ----------
  void levelUp() {
    level++;
    final oldMax = maxHp;
    maxHp = HouseStats.maxHp(level);
    hp += maxHp - oldMax; // hồi phần HP tăng thêm

    // Nhà "phình" lên rồi co lại
    add(ScaleEffect.by(
      Vector2.all(1.12),
      EffectController(
          duration: 0.12, reverseDuration: 0.22, curve: Curves.easeOut),
    ));
    parent?.add(ShockwaveRing(at: position.clone(), maxRadius: 240));
    parent?.add(DamagePopup(
      'LEVEL $level!',
      at: position + Vector2(0, -size.y / 2 - 40),
      color: const Color(0xFFFFC107),
      fontSize: 30,
    ));
  }

  @override
  void onDeath() {
    game.onHouseDestroyed();
  }

  // ---------- Vẽ ----------
  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final tier = ((level - 1) ~/ 3).clamp(0, 3);

    // bóng
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(8, 10, w, h), const Radius.circular(14)),
      _shadow,
    );

    // tường
    final wall = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(14));
    _p.color = _wallColors[tier];
    canvas.drawRRect(wall, _p);

    // cửa (lộ ra ở mép dưới)
    _p.color = const Color(0xFF5A3A1E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w / 2 - 16, h - 32, 32, 32), const Radius.circular(6)),
      _p,
    );

    // mái
    final roof = Rect.fromLTWH(12, 12, w - 24, h - 46);
    _p.color = _roofColors[tier];
    canvas.drawRRect(
        RRect.fromRectAndRadius(roof, const Radius.circular(10)), _p);

    // đường gờ mái (hình chữ X)
    final inset = roof.width * 0.22;
    final cy = roof.center.dy;
    canvas.drawLine(roof.topLeft, Offset(roof.left + inset, cy), _line);
    canvas.drawLine(roof.bottomLeft, Offset(roof.left + inset, cy), _line);
    canvas.drawLine(roof.topRight, Offset(roof.right - inset, cy), _line);
    canvas.drawLine(roof.bottomRight, Offset(roof.right - inset, cy), _line);

    canvas.drawRRect(wall, _outline);

    // huy hiệu level
    _p.color = const Color(0xDD1A1A1A);
    canvas.drawCircle(Offset(w / 2, cy), 26, _p);
    _lvText.render(canvas, 'Lv.$level', Vector2(w / 2, cy),
        anchor: Anchor.center);

    // flash khi bị đánh
    if (isFlashing) {
      canvas.drawRRect(wall, Paint()..color = const Color(0x66FFFFFF));
    }

    // thanh máu
    renderHpBar(canvas, Rect.fromLTWH(0, -20, w, 10));
  }
}