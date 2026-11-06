import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

class _Bit {
  _Bit(this.dir, this.dist, this.size, this.spin, this.color);
  final Vector2 dir;
  final double dist;
  final double size;
  final double spin;
  final Color color;
}

/// Mảnh vỡ văng ra rồi mờ dần (Crate vỡ, bụi khi Crate đáp xuống)
class DebrisBurst extends PositionComponent {
  DebrisBurst({
    required Vector2 at,
    required List<Color> colors,
    int count = 14,
    double speed = 180,
  }) : super(position: at, priority: 30) {
    for (var i = 0; i < count; i++) {
      final a = globalRandom.nextDouble() * 2 * pi;
      _bits.add(_Bit(
        Vector2(cos(a), sin(a)),
        speed * (0.4 + globalRandom.nextDouble() * 0.6),
        4 + globalRandom.nextDouble() * 7,
        (globalRandom.nextDouble() - 0.5) * 20,
        colors[globalRandom.nextInt(colors.length)],
      ));
    }
  }

  final List<_Bit> _bits = [];
  final Paint _paint = Paint();
  double _t = 0;
  static const double _life = 0.55;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= _life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / _life).clamp(0.0, 1.0).toDouble();
    final e = Curves.easeOut.transform(p);

    for (final b in _bits) {
      _paint.color = b.color.withAlpha(((1 - p) * 255).round());
      canvas.save();
      canvas.translate(b.dir.x * b.dist * e, b.dir.y * b.dist * e);
      canvas.rotate(b.spin * _t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: b.size, height: b.size),
        _paint,
      );
      canvas.restore();
    }
  }
}