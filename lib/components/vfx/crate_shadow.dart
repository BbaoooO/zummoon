import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Bóng trên mặt đất: to dần + đậm dần khi Crate đến gần, kèm vòng cảnh báo thu nhỏ.
class CrateShadow extends PositionComponent {
  CrateShadow({required Vector2 at, required this.duration})
      : super(position: at, priority: 3);

  final double duration;
  double _t = 0;

  final Paint _shadow = Paint();
  final Paint _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / duration).clamp(0.0, 1.0).toDouble();
    final e = Curves.easeIn.transform(p);

    final s = 0.35 + 0.65 * e;
    _shadow.color = Color.fromRGBO(0, 0, 0, 0.12 + 0.38 * e);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 78 * s, height: 56 * s),
      _shadow,
    );

    // vòng cảnh báo thu nhỏ dần về vị trí đáp
    _ring.color = const Color(0xFFFFC107).withAlpha((60 + 150 * e).round());
    canvas.drawCircle(Offset.zero, 52 * (1.8 - 0.8 * e), _ring);
  }
}