import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Vệt chém hình cung khi vung vũ khí
class SlashArc extends PositionComponent {
  SlashArc({
    required Vector2 at,
    required double facing,
    required this.radius,
    required this.color,
  }) : super(position: at, angle: facing, priority: 20);

  final double radius;
  final Color color;
  double _t = 0;
  static const double _life = 0.18;

  final Paint _outer = Paint()..style = PaintingStyle.stroke;
  final Paint _inner = Paint()..style = PaintingStyle.stroke;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= _life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / _life).clamp(0.0, 1.0).toDouble();
    final r = radius * (0.8 + 0.25 * p);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);

    _outer
      ..color = color.withAlpha(((1 - p) * 200).round())
      ..strokeWidth = 14 * (1 - p) + 2;
    _inner
      ..color = Colors.white.withAlpha(((1 - p) * 230).round())
      ..strokeWidth = 5 * (1 - p) + 1;

    canvas.drawArc(rect, -0.95, 1.9, false, _outer);
    canvas.drawArc(rect, -0.95, 1.9, false, _inner);
  }
}