import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

/// Nút ĐẤM ở góc phải dưới màn hình
HudButtonComponent createPunchButton({required VoidCallback onPressed}) {
  const double radius = 42;

  CircleComponent makeCircle(Color color) {
    final circle = CircleComponent(
      radius: radius,
      paint: Paint()..color = color,
    );
    circle.add(
      TextComponent(
        text: 'ĐẤM',
        anchor: Anchor.center,
        position: Vector2.all(radius),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    return circle;
  }

  return HudButtonComponent(
    button: makeCircle(const Color(0xAAD64040)),
    buttonDown: makeCircle(const Color(0xFFFF6060)),
    margin: const EdgeInsets.only(right: 50, bottom: 50),
    onPressed: onPressed,
  );
}