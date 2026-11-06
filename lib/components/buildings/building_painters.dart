import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/building.dart';

final Paint _fill = Paint();
final Paint _stroke = Paint()
  ..style = PaintingStyle.stroke
  ..strokeJoin = StrokeJoin.round;
final Paint _shadow = Paint()..color = const Color(0x44000000);

void _fillRRect(Canvas c, RRect r, Color fill, Color line, double w) {
  _fill.color = fill;
  c.drawRRect(r, _fill);
  _stroke
    ..color = line
    ..strokeWidth = w;
  c.drawRRect(r, _stroke);
}

// ---------------------------------------------------------------------------
// TURRET: aim = góc nòng (0 = chĩa +x), recoil 0..1, muzzle > 0 = đang lóe lửa
// ---------------------------------------------------------------------------
void paintTurret(
  Canvas canvas,
  Size s, {
  double aim = -pi / 2,
  double recoil = 0,
  double muzzle = 0,
}) {
  final c = Offset(s.width / 2, s.height / 2);
  final r = s.width * 0.46;

  canvas.drawCircle(c.translate(4, 6), r, _shadow);

  // đế
  _fill.color = const Color(0xFF59606B);
  canvas.drawCircle(c, r, _fill);
  _stroke
    ..color = const Color(0xFF22262C)
    ..strokeWidth = 3;
  canvas.drawCircle(c, r, _stroke);

  // đinh tán
  _fill.color = const Color(0xFF8A929E);
  for (var i = 0; i < 6; i++) {
    final a = i * pi / 3;
    canvas.drawCircle(c + Offset(cos(a), sin(a)) * (r - 6), 2.5, _fill);
  }

  // nòng súng (xoay theo aim)
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(aim);
  final back = recoil * 6;
  _fillRRect(
    canvas,
    RRect.fromRectAndRadius(
        Rect.fromLTRB(2 - back, -6, 30 - back, 6), const Radius.circular(3)),
    const Color(0xFF2F343B),
    const Color(0xFF14171B),
    2,
  );
  if (muzzle > 0) {
    _fill.color = const Color(0xFFFFE066);
    canvas.drawPath(
      Path()
        ..moveTo(30 - back, -8)
        ..lineTo(48 - back, 0)
        ..lineTo(30 - back, 8)
        ..close(),
      _fill,
    );
  }
  canvas.restore();

  // đầu súng
  _fill.color = const Color(0xFF4A90E2);
  canvas.drawCircle(c, r * 0.5, _fill);
  _stroke
    ..color = const Color(0xFF1B3A66)
    ..strokeWidth = 2.5;
  canvas.drawCircle(c, r * 0.5, _stroke);
  _fill.color = const Color(0x66FFFFFF);
  canvas.drawCircle(c.translate(-4, -4), r * 0.16, _fill);
}

// ---------------------------------------------------------------------------
// FENCE: tự nhận ngang/dọc theo kích thước
// ---------------------------------------------------------------------------
void paintFence(Canvas canvas, Size s) {
  final horizontal = s.width >= s.height;
  final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s.width, s.height), const Radius.circular(6));

  canvas.drawRRect(body.shift(const Offset(3, 5)), _shadow);
  _fillRRect(canvas, body, const Color(0xFFB98B54), const Color(0xFF3A2410), 2.5);

  // đường ván
  final plank = Paint()
    ..color = const Color(0x66000000)
    ..strokeWidth = 2;
  final long = horizontal ? s.width : s.height;
  for (var d = 20.0; d < long - 6; d += 20) {
    if (horizontal) {
      canvas.drawLine(Offset(d, 3), Offset(d, s.height - 3), plank);
    } else {
      canvas.drawLine(Offset(3, d), Offset(s.width - 3, d), plank);
    }
  }

  // 2 cột ở hai đầu
  final posts = horizontal
      ? [
          Rect.fromLTWH(0, 0, 10, s.height),
          Rect.fromLTWH(s.width - 10, 0, 10, s.height),
        ]
      : [
          Rect.fromLTWH(0, 0, s.width, 10),
          Rect.fromLTWH(0, s.height - 10, s.width, 10),
        ];
  for (final p in posts) {
    _fillRRect(canvas, RRect.fromRectAndRadius(p, const Radius.circular(3)),
        const Color(0xFF6B4423), const Color(0xFF3A2410), 2);
  }
}

// ---------------------------------------------------------------------------
// FARMING HOUSE
// ---------------------------------------------------------------------------
void paintFarm(Canvas canvas, Size s) {
  final w = s.width;
  final h = s.height;
  final wall = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h), const Radius.circular(10));

  canvas.drawRRect(wall.shift(const Offset(4, 6)), _shadow);
  _fillRRect(canvas, wall, const Color(0xFFD2B48C), const Color(0xFF4A3520), 3);

  // mái
  final roof = Rect.fromLTWH(7, 7, w - 14, h - 24);
  _fillRRect(canvas, RRect.fromRectAndRadius(roof, const Radius.circular(7)),
      const Color(0xFF4E8F3A), const Color(0xFF244A1A), 2.5);
  canvas.drawLine(
    Offset(roof.left + 4, roof.center.dy),
    Offset(roof.right - 4, roof.center.dy),
    Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 3,
  );

  // khúc gỗ + cục đá trước cửa
  _fillRRect(
    canvas,
    RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h - 15, 20, 9), const Radius.circular(3)),
    const Color(0xFF8B5A2B),
    const Color(0xFF2B1D10),
    2,
  );
  _fill.color = const Color(0xFF9EA2AB);
  canvas.drawCircle(Offset(w * 0.7, h - 11), 6, _fill);
  _stroke
    ..color = const Color(0xFF2E3036)
    ..strokeWidth = 2;
  canvas.drawCircle(Offset(w * 0.7, h - 11), 6, _stroke);
}

void paintBuildingByType(Canvas canvas, BuildingType t, Size s) {
  switch (t) {
    case BuildingType.turret:
      paintTurret(canvas, s);
    case BuildingType.fence:
      paintFence(canvas, s);
    case BuildingType.farm:
      paintFarm(canvas, s);
  }
}

/// Icon cho UI (CustomPaint)
class BuildingIconPainter extends CustomPainter {
  BuildingIconPainter(this.type);
  final BuildingType type;

  @override
  void paint(Canvas canvas, Size box) {
    final w = type.width;
    final h = type.height;
    final k = min(box.width / w, box.height / h) * 0.92;
    canvas.translate(box.width / 2, box.height / 2);
    canvas.scale(k);
    canvas.translate(-w / 2, -h / 2);
    paintBuildingByType(canvas, type, Size(w, h));
  }

  @override
  bool shouldRepaint(covariant BuildingIconPainter old) => old.type != type;
}