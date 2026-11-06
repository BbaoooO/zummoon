import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

class Baseplate extends PositionComponent {
  Baseplate({required this.seed}) : super(size: kWorldSize, priority: -100);

  final int seed;
  late final ui.Picture _picture;

  @override
  Future<void> onLoad() async {
    final rnd = Random(seed);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // 1) Nền cỏ: các ô 100x100 lệch màu nhẹ
    const cell = 100.0;
    const greens = [Color(0xFF4C8C4A), Color(0xFF478646), Color(0xFF529250)];
    for (var gx = 0; gx < size.x / cell; gx++) {
      for (var gy = 0; gy < size.y / cell; gy++) {
        paint.color = greens[rnd.nextInt(greens.length)];
        canvas.drawRect(
            Rect.fromLTWH(gx * cell, gy * cell, cell, cell), paint);
      }
    }

    // 2) Cọng cỏ + hoa nhỏ
    final tuft = Paint()
      ..color = const Color(0x5524501F)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 1800; i++) {
      final x = rnd.nextDouble() * size.x;
      final y = rnd.nextDouble() * size.y;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y - 8), tuft);
      canvas.drawLine(Offset(x, y), Offset(x + 3, y - 9), tuft);
    }
    const flowerColors = [
      Color(0xFFFFEB3B),
      Color(0xFFFFFFFF),
      Color(0xFFFF8AD0),
    ];
    for (var i = 0; i < 140; i++) {
      paint.color = flowerColors[rnd.nextInt(flowerColors.length)];
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.x, rnd.nextDouble() * size.y),
        3,
        paint,
      );
    }

    // 3) Khu đất quanh House
    final center = Offset(size.x / 2, size.y / 2);
    paint.color = const Color(0xFF8A6D45);
    canvas.drawCircle(center, kSafeRadius * 0.85, paint);
    paint.color = const Color(0xFF9C7E52);
    canvas.drawCircle(center, kSafeRadius * 0.65, paint);

    // 4) Viền map
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = const Color(0xFFB03030)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );

    _picture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPicture(_picture);
  }
}