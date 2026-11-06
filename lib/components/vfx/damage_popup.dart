import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// Text sát thương: nảy lên + phình to rồi mờ dần và tự xoá.
class DamagePopup extends PositionComponent {
  DamagePopup(
    this.text, {
    required Vector2 at,
    this.color = Colors.white,
    this.fontSize = 22,
  }) : super(position: at, anchor: Anchor.center, priority: 1000);

  final String text;
  final Color color;
  final double fontSize;

  late final TextPainter _fill;
  late final TextPainter _stroke;
  double _age = 0;
  static const double _life = 0.9;

  @override
  Future<void> onLoad() async {
    _fill = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _stroke = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    size = Vector2(_fill.width, _fill.height);

    final dx = (globalRandom.nextDouble() - 0.5) * 40;
    add(MoveEffect.by(
      Vector2(dx, -55),
      EffectController(duration: 0.45, curve: Curves.easeOutBack),
    ));
    add(ScaleEffect.by(
      Vector2.all(1.5),
      EffectController(
          duration: 0.12, reverseDuration: 0.2, curve: Curves.easeOut),
    ));
    add(RemoveEffect(delay: _life));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _life).clamp(0.0, 1.0).toDouble();
    final alpha = t < 0.6 ? 1.0 : 1.0 - (t - 0.6) / 0.4;

    canvas.saveLayer(
      Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20),
      Paint()..color = Color.fromRGBO(255, 255, 255, alpha),
    );
    _stroke.paint(canvas, Offset.zero);
    _fill.paint(canvas, Offset.zero);
    canvas.restore();
  }
}