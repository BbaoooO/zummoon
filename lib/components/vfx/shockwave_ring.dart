import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Vòng sóng xung kích loe rộng rồi mờ dần (dùng khi nâng cấp House)
class ShockwaveRing extends PositionComponent {
  ShockwaveRing({
    required Vector2 at,
    this.maxRadius = 220,
    this.color = const Color(0xFFFFC107),
  }) : super(position: at, anchor: Anchor.center, priority: 50);

  final double maxRadius;
  final Color color;
  double _t = 0;
  static const double _life = 0.6;

  final Paint _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= _life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / _life).clamp(0.0, 1.0).toDouble();
    final eased = Curves.easeOut.transform(p);
    _paint
      ..color = color.withAlpha(((1 - p) * 255).round())
      ..strokeWidth = 10 * (1 - p) + 1;
    canvas.drawCircle(Offset.zero, maxRadius * eased, _paint);
  }
}