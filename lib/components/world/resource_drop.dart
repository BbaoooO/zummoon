import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/game_state.dart';
import '../../game/zummoon_game.dart';
import '../vfx/damage_popup.dart';

/// Vật phẩm rơi ra: văng ra, nảy lên, rồi bị hút về Player khi lại gần.
class ResourceDrop extends PositionComponent with HasGameReference<ZummoonGame> {
  ResourceDrop({required this.type, required Vector2 origin})
      : super(
          position: origin,
          size: Vector2.all(18),
          anchor: Anchor.center,
          priority: 4,
        );

  final ResourceType type;

  double _age = 0;
  double _speed = 150;
  bool _collecting = false;
  bool _collected = false;

  final Paint _p = Paint();
  final Paint _outline = Paint()
    ..color = const Color(0xFF2B1D10)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  Future<void> onLoad() async {
    angle = globalRandom.nextDouble() * pi;

    // văng ra theo hướng ngẫu nhiên
    final a = globalRandom.nextDouble() * 2 * pi;
    final dist = 40 + globalRandom.nextDouble() * 40;
    add(MoveEffect.by(
      Vector2(cos(a), sin(a)) * dist,
      EffectController(duration: 0.4, curve: Curves.easeOutCubic),
    ));
    // nảy lên (phình to rồi co lại)
    add(ScaleEffect.by(
      Vector2.all(1.6),
      EffectController(
          duration: 0.2, reverseDuration: 0.2, curve: Curves.easeOut),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age < 0.45 || _collected) return; // chờ văng xong mới nhặt được

    final toPlayer = game.player.position - position;
    final dist = toPlayer.length;

    if (!_collecting && dist < kPickupRadius) _collecting = true;
    if (!_collecting) return;

    if (dist < 22) {
      _collect();
      return;
    }
    _speed += 900 * dt; // càng gần càng bay nhanh
    position.addScaled(toPlayer / dist, min(_speed * dt, dist));
  }

    void _collect() {
    _collected = true;
    game.state.add(type, 1);

    final (label, color) = switch (type) {
      ResourceType.wood => ('+1 Gỗ', const Color(0xFFE0B070)),
      ResourceType.stone => ('+1 Đá', const Color(0xFFD0D4DC)),
      ResourceType.scrap => ('+1 Scrap', const Color(0xFF6EC6FF)),
    };

    parent?.add(DamagePopup(
      label,
      at: game.player.position + Vector2(0, -42),
      color: color,
      fontSize: 16,
    ));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case ResourceType.wood:
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 4, size.x, size.y - 8), const Radius.circular(4));
        _p.color = const Color(0xFF8B5A2B);
        canvas.drawRRect(rect, _p);
        _p.color = const Color(0xFFD9A066); // mặt cắt khúc gỗ
        canvas.drawCircle(Offset(size.x - 4, size.y / 2), 4, _p);
        canvas.drawRRect(rect, _outline);

      case ResourceType.stone:
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final a = 2 * pi * i / 6;
          final pt = Offset(size.x / 2 + cos(a) * 9, size.y / 2 + sin(a) * 8);
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        path.close();
        _p.color = const Color(0xFF9EA2AB);
        canvas.drawPath(path, _p);
        canvas.drawPath(path, _outline);

      case ResourceType.scrap:
        // bánh răng nhỏ
        final c = Offset(size.x / 2, size.y / 2);
        final gear = Path();
        for (var i = 0; i < 16; i++) {
          final a = 2 * pi * i / 16;
          final r = (i ~/ 2).isEven ? 10.0 : 7.5;
          final pt = Offset(c.dx + cos(a) * r, c.dy + sin(a) * r);
          i == 0 ? gear.moveTo(pt.dx, pt.dy) : gear.lineTo(pt.dx, pt.dy);
        }
        gear.close();
        _p.color = const Color(0xFF5DA9D6);
        canvas.drawPath(gear, _p);
        canvas.drawPath(gear, _outline);
        _p.color = const Color(0xFF1E2A33);
        canvas.drawCircle(c, 3, _p);
    }
  }
}