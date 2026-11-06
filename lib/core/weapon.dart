import 'dart:math';

import 'package:flutter/material.dart';

enum Rarity {
  common('Thường', Color(0xFFB0B7C3)),
  uncommon('Hiếm', Color(0xFF4CD964)),
  rare('Quý', Color(0xFF3FA9F5)),
  epic('Huyền thoại', Color(0xFFB65CFF));

  const Rarity(this.label, this.color);
  final String label;
  final Color color;
}

enum WeaponType {
  fist('Tay không',
      damage: 1, cooldown: 0.35, reach: 20, hitRadius: 30,
      rarity: Rarity.common, dropWeight: 0, length: 0),
  bat('Gậy bóng chày',
      damage: 3, cooldown: 0.40, reach: 28, hitRadius: 34,
      rarity: Rarity.common, dropWeight: 40, length: 36),
  axe('Rìu',
      damage: 4, cooldown: 0.50, reach: 30, hitRadius: 36, treeMult: 2,
      rarity: Rarity.uncommon, dropWeight: 30, length: 34),
  hammer('Búa tạ',
      damage: 6, cooldown: 0.75, reach: 32, hitRadius: 40, rockMult: 2,
      rarity: Rarity.rare, dropWeight: 20, length: 34),
  sword('Kiếm',
      damage: 5, cooldown: 0.35, reach: 40, hitRadius: 46, maxTargets: 3,
      rarity: Rarity.epic, dropWeight: 10, length: 44);

  const WeaponType(
    this.displayName, {
    required this.damage,
    required this.cooldown,
    required this.reach,
    required this.hitRadius,
    this.treeMult = 1,
    this.rockMult = 1,
    this.maxTargets = 1,
    required this.rarity,
    required this.dropWeight,
    required this.length,
  });

  final String displayName;
  final double damage;
  final double cooldown;
  final double reach; // tay/vũ khí vươn ra bao xa
  final double hitRadius; // bán kính vùng trúng đòn
  final double treeMult; // hệ số sát thương lên Cây
  final double rockMult; // hệ số sát thương lên Đá
  final int maxTargets; // số mục tiêu tối đa mỗi đòn
  final Rarity rarity;
  final int dropWeight; // trọng số rơi từ Crate (0 = không rơi)
  final double length; // chiều dài khi vẽ

  String get perk {
    final parts = <String>[];
    if (treeMult > 1) parts.add('Cây x${treeMult.toStringAsFixed(0)}');
    if (rockMult > 1) parts.add('Đá x${rockMult.toStringAsFixed(0)}');
    if (maxTargets > 1) parts.add('Chém lan $maxTargets mục tiêu');
    return parts.join(' • ');
  }

  /// Random vũ khí rơi từ Crate theo trọng số
  static WeaponType randomDrop(Random r) {
    final pool = values.where((w) => w.dropWeight > 0).toList();
    final total = pool.fold<int>(0, (s, w) => s + w.dropWeight);
    var roll = r.nextInt(total);
    for (final w in pool) {
      if (roll < w.dropWeight) return w;
      roll -= w.dropWeight;
    }
    return pool.first;
  }
}

// ---------------------------------------------------------------------------
// VẼ VŨ KHÍ: gốc cán nằm ở (0,0), vũ khí chĩa về phía -y (hướng lên)
// ---------------------------------------------------------------------------
void paintWeapon(Canvas canvas, WeaponType w, {double scale = 1}) {
  final fill = Paint();
  final line = Paint()
    ..color = const Color(0xFF1E1408)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round;

  void shape(Path p, Color c) {
    fill.color = c;
    canvas.drawPath(p, fill);
    canvas.drawPath(p, line);
  }

  Path rect(double l, double t, double r, double b) =>
      Path()..addRect(Rect.fromLTRB(l, t, r, b));

  const wood = Color(0xFF9A6A36);
  const steel = Color(0xFFC5CAD3);
  const darkSteel = Color(0xFF6D7380);
  const gold = Color(0xFFE6B422);

  canvas.save();
  canvas.scale(scale);
  final len = w.length;

  switch (w) {
    case WeaponType.fist:
      fill.color = const Color(0xFFFFD2A6);
      canvas.drawCircle(const Offset(0, -12), 9, fill);
      canvas.drawCircle(const Offset(0, -12), 9, line);
    case WeaponType.bat:
      shape(
        Path()
          ..moveTo(-2.5, 0)
          ..lineTo(2.5, 0)
          ..lineTo(5.5, -len)
          ..lineTo(-5.5, -len)
          ..close(),
        wood,
      );
    case WeaponType.axe:
      shape(rect(-2.5, -len, 2.5, 0), wood);
      shape(
        Path()
          ..moveTo(2.5, -len)
          ..lineTo(15, -len - 4)
          ..lineTo(15, -len + 16)
          ..lineTo(2.5, -len + 10)
          ..close(),
        steel,
      );
    case WeaponType.hammer:
      shape(rect(-2.5, -len, 2.5, 0), wood);
      shape(rect(-12, -len - 4, 12, -len + 12), darkSteel);
    case WeaponType.sword:
      shape(rect(-2, -11, 2, 0), const Color(0xFF6B4423)); // cán
      shape(rect(-9, -15, 9, -11), gold); // tay cầm chắn
      shape(
        Path()
          ..moveTo(-4, -15)
          ..lineTo(4, -15)
          ..lineTo(4, -len + 8)
          ..lineTo(0, -len)
          ..lineTo(-4, -len + 8)
          ..close(),
        steel,
      );
  }
  canvas.restore();
}