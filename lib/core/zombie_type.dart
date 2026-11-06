import 'dart:math';

import 'package:flutter/painting.dart';

enum ZombieType {
  normal('Zombie thường',
      hp: 20, speed: 70, damage: 8, attackInterval: 1.0, size: 38,
      body: Color(0xFF7BAA5A), dark: Color(0xFF263A18)),
  fast('Zombie nhanh',
      hp: 9, speed: 155, damage: 5, attackInterval: 0.6, size: 30,
      knockbackMult: 1.4,
      body: Color(0xFFD6C94A), dark: Color(0xFF4D4710)),
  tank('Zombie Tank',
      hp: 130, speed: 38, damage: 22, attackInterval: 1.5, size: 66,
      buildingMult: 3, knockbackMult: 0.2,
      body: Color(0xFF8C4A4A), dark: Color(0xFF3A1414)),
  ranged('Zombie xạ thủ',
      hp: 14, speed: 60, damage: 9, attackInterval: 1.8, size: 36,
      range: 270,
      body: Color(0xFF9A6FD1), dark: Color(0xFF2E1A4D));

  const ZombieType(
    this.displayName, {
    required this.hp,
    required this.speed,
    required this.damage,
    required this.attackInterval,
    required this.size,
    required this.body,
    required this.dark,
    this.range = 0,
    this.buildingMult = 1,
    this.knockbackMult = 1,
  });

  final String displayName;
  final double hp;
  final double speed;
  final double damage;
  final double attackInterval;
  final double size;
  final Color body;
  final Color dark;
  final double range; // > 0 = bắn xa
  final double buildingMult; // hệ số sát thương lên công trình
  final double knockbackMult; // hệ số bị đẩy lùi

  bool get isRanged => range > 0;
}

/// Đội hình của một Wave (đã xáo trộn). Wave sau luôn đông và đa dạng hơn.
List<ZombieType> buildWaveQueue(int wave, Random r) {
  final list = <ZombieType>[
    ...List.filled(3 + wave * 2, ZombieType.normal),
    if (wave >= 2) ...List.filled(wave - 1, ZombieType.fast),
    if (wave >= 3) ...List.filled(wave - 2, ZombieType.ranged),
    if (wave >= 4) ...List.filled((wave - 2) ~/ 2, ZombieType.tank),
  ];
  list.shuffle(r);
  return list;
}