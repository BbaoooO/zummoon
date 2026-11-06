import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/zummoon_game.dart';
import '../world/crate.dart';

/// Mũi tên ở rìa màn hình chỉ về các Crate đang nằm ngoài tầm nhìn.
/// Gắn vào camera.viewport nên toạ độ là toạ độ màn hình.
class CrateIndicator extends PositionComponent
    with HasGameReference<ZummoonGame> {
  CrateIndicator() : super(priority: 100);

  final Paint _fill = Paint();
  final Paint _line = Paint()
    ..color = const Color(0xFF3A2410)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeJoin = StrokeJoin.round;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final vp = game.camera.viewport.size;
    final cam = game.camera.viewfinder.position;
    const margin = 40.0;
    final halfW = vp.x / 2 - margin;
    final halfH = vp.y / 2 - margin;
    final pulse = 0.75 + 0.25 * sin(_t * 6);

    for (final crate in game.world.children.query<Crate>()) {
      if (crate.isDead) continue;
      final rel = crate.target - cam;
      if (rel.x.abs() < halfW && rel.y.abs() < halfH) continue; // đang thấy rồi

      final d = rel.normalized();
      final kx = d.x == 0 ? double.infinity : halfW / d.x.abs();
      final ky = d.y == 0 ? double.infinity : halfH / d.y.abs();
      final k = min(kx, ky);
      final pos = Offset(vp.x / 2 + d.x * k, vp.y / 2 + d.y * k);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // ô vuông "Crate" nhỏ
      _fill.color = const Color(0xFFB98B54);
      final box = Rect.fromCenter(
          center: Offset(-d.x * 16, -d.y * 16), width: 16, height: 16);
      canvas.drawRect(box, _fill);
      canvas.drawRect(box, _line);

      // mũi tên chỉ hướng
      canvas.rotate(atan2(d.y, d.x));
      final arrow = Path()
        ..moveTo(16, 0)
        ..lineTo(-4, -11)
        ..lineTo(-4, 11)
        ..close();
      _fill.color = const Color(0xFFFFC107).withAlpha((255 * pulse).round());
      canvas.drawPath(arrow, _fill);
      canvas.drawPath(arrow, _line);
      canvas.restore();
    }
  }
}