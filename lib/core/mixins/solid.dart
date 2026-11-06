import 'dart:math';

import 'package:flame/components.dart';

import '../../game/zummoon_game.dart';

/// Vật cản: Player (và sau này Zombie) không đi xuyên qua.
/// QUY ƯỚC: anchor = center.
mixin Solid on PositionComponent {
  double get solidRadius => size.x * 0.4;

  ZummoonGame? _solidGame;

  @override
  void onMount() {
    super.onMount();
    _solidGame = findGame() as ZummoonGame?;
    _solidGame?.solids.add(this);
  }

  @override
  void onRemove() {
    _solidGame?.solids.remove(this);
    super.onRemove();
  }

  /// Trả về vector cần cộng vào [p] để vòng tròn bán kính [r] thoát khỏi vật cản.
  /// Trả về null nếu không va chạm. Mặc định là vật cản hình tròn.
  Vector2? pushOut(Vector2 p, double r) {
    final d = p - position;
    final dist = d.length;
    final minDist = solidRadius + r;
    if (dist >= minDist) return null;
    if (dist == 0) return Vector2(minDist, 0);
    return d / dist * (minDist - dist);
  }

  /// Dùng cho vật cản hình chữ nhật (House)
  Vector2? pushOutOfRect(Vector2 p, double r) {
    final half = size / 2;
    final cx = min(max(p.x, position.x - half.x), position.x + half.x);
    final cy = min(max(p.y, position.y - half.y), position.y + half.y);
    final d = Vector2(p.x - cx, p.y - cy);
    final dist = d.length;
    if (dist >= r) return null;
    if (dist == 0) return Vector2(0, half.y + r); // tâm nằm trong hộp: đẩy xuống
    return d / dist * (r - dist);
  }
}