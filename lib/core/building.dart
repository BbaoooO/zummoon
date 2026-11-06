import 'dart:math';

import 'package:flame/components.dart';

import 'constants.dart';

enum BuildingType {
  turret('Tháp súng', 'Tự động ngắm bắn Zombie trong tầm',
      scrapCost: 12, width: 56, height: 56, hp: 150),
  fence('Hàng rào', 'Cản đường, chịu đòn thay Nhà',
      scrapCost: 2, width: 100, height: 30, hp: 160),
  farm('Trạm khai thác', 'Tự tạo Gỗ & Đá theo thời gian',
      scrapCost: 15, width: 64, height: 64, hp: 100);

  const BuildingType(
    this.displayName,
    this.desc, {
    required this.scrapCost,
    required this.width,
    required this.height,
    required this.hp,
  });

  final String displayName;
  final String desc;
  final int scrapCost;
  final double width;
  final double height;
  final double hp;

  /// [rotated] chỉ có ý nghĩa với Hàng rào (đổi ngang <-> dọc)
  Vector2 sizeFor(bool rotated) =>
      rotated ? Vector2(height, width) : Vector2(width, height);

  String get stats => switch (this) {
        BuildingType.turret =>
          'Tầm ${kTurretRange.round()} • ST ${kTurretDamage.round()} • ${(1 / kTurretFireInterval).toStringAsFixed(1)} phát/s',
        BuildingType.fence => 'Máu ${hp.round()}',
        BuildingType.farm =>
          '+$kFarmWood Gỗ +$kFarmStone Đá / ${kFarmInterval.round()}s',
      };
}

// ---------------------------------------------------------------------------
// KIỂM TRA CHỖ ĐẶT
// Công trình dài (hàng rào) được xấp xỉ bằng nhiều vòng tròn nhỏ rải dọc thân,
// để xếp rào sát nhau mà vẫn bắt chính xác va chạm.
// ---------------------------------------------------------------------------

/// Bán kính mỗi điểm kiểm tra
double placementRadius(Vector2 size) => min(size.x, size.y) / 2 * 0.95;

/// Các điểm kiểm tra rải dọc trục dài của công trình
List<Vector2> placementProbes(Vector2 p, Vector2 size) {
  final r = placementRadius(size);
  final longHalf = max(size.x, size.y) / 2;
  final span = longHalf - min(size.x, size.y) / 2;
  if (span <= 0) return [p.clone()];

  final n = (span * 2 / (r * 1.6)).ceil() + 1;
  final horizontal = size.x >= size.y;
  return [
    for (var i = 0; i < n; i++)
      () {
        final off = -span + 2 * span * i / (n - 1);
        return horizontal ? Vector2(p.x + off, p.y) : Vector2(p.x, p.y + off);
      }(),
  ];
}

/// Hình tròn (c, r) có chạm hình chữ nhật (center, size) không
bool circleHitsRect(Vector2 c, double r, Vector2 center, Vector2 size) {
  final half = size / 2;
  final cx = c.x.clamp(center.x - half.x, center.x + half.x).toDouble();
  final cy = c.y.clamp(center.y - half.y, center.y + half.y).toDouble();
  return Vector2(c.x - cx, c.y - cy).length < r;
}