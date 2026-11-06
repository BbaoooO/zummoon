import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/building.dart';
import '../../core/constants.dart';
import '../../core/mixins/damageable.dart';
import '../../game/zummoon_game.dart';
import 'building_painters.dart';

/// Bóng xem trước công trình, luôn nằm trước mặt Player.
/// Xanh = đặt được, đỏ = bị chặn.
class BuildGhost extends PositionComponent with HasGameReference<ZummoonGame> {
  BuildGhost() : super(anchor: Anchor.center, priority: 40);

  bool valid = false;

  final Paint _alpha = Paint()..color = const Color(0xA6FFFFFF);
  final Paint _tint = Paint();
  final Paint _edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _rangeFill = Paint()..color = const Color(0x14FFFFFF);
  final Paint _rangeLine = Paint()
    ..color = const Color(0x66FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static double _snap(double v) => (v / kBuildSnap).round() * kBuildSnap;

  @override
  void update(double dt) {
    super.update(dt);

    final bm = game.buildManager;
    final t = bm.selected.value;
    if (t == null) return;

    size = t.sizeFor(bm.rotated.value);

    final p = game.player;
    final dir = Vector2(cos(p.angle), sin(p.angle));
    final dist = kPlayerSize / 2 + max(size.x, size.y) / 2 + 16;
    final target = p.position + dir * dist;
    position = Vector2(_snap(target.x), _snap(target.y));

    valid = _check();
    bm.canPlace.value = valid;
  }

  bool _check() {
    final half = size / 2;
    const margin = 20.0;
    if (position.x - half.x < margin ||
        position.y - half.y < margin ||
        position.x + half.x > kWorldSize.x - margin ||
        position.y + half.y > kWorldSize.y - margin) {
      return false;
    }
    
    final probes = placementProbes(position, size);
    final r = placementRadius(size);
    for (final s in game.solids) {
      if (isDeadObject(s)) continue;
      for (final pr in probes) {
        if (s.pushOut(pr, r) != null) return false;
      }
    }

    // không đè lên Player
    if (circleHitsRect(game.player.position, kPlayerSize * 0.5, position, size)) {
      return false;
    }
    return true;
  }

  @override
  void render(Canvas canvas) {
    final t = game.buildManager.selected.value;
    if (t == null) return;

    final center = Offset(size.x / 2, size.y / 2);
    if (t == BuildingType.turret) {
      canvas.drawCircle(center, kTurretRange, _rangeFill);
      canvas.drawCircle(center, kTurretRange, _rangeLine);
    }

    canvas.saveLayer(Rect.fromLTWH(-8, -8, size.x + 16, size.y + 16), _alpha);
    paintBuildingByType(canvas, t, Size(size.x, size.y));
    canvas.restore();

    final color = valid ? const Color(0xFF4CD964) : const Color(0xFFFF3B30);
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8));
    _tint.color = color.withAlpha(0x55);
    _edge.color = color;
    canvas.drawRRect(rrect, _tint);
    canvas.drawRRect(rrect, _edge);
  }
}