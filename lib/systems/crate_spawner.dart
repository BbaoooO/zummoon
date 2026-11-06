import 'dart:math';

import 'package:flame/components.dart';

import '../components/world/crate.dart';
import '../core/constants.dart';
import '../game/zummoon_game.dart';

/// Cứ mỗi [kCrateInterval] giây thả 1 Crate xuống vị trí ngẫu nhiên.
class CrateSpawner extends Component with HasGameReference<ZummoonGame> {
  CrateSpawner({required this.random});

  final Random random;

  /// Module 5 có thể tắt/bật theo Wave
  bool enabled = true;

  double _timer = kFirstCrateDelay;

  @override
  void update(double dt) {
    super.update(dt);
    if (!enabled) return;

    _timer -= dt;
    if (_timer > 0) return;
    _timer = kCrateInterval;

    if (game.world.children.query<Crate>().length < kMaxCrates) {
      dropRandomCrate();
    }
  }

  void dropRandomCrate() {
    final p = _findSpot();
    if (p != null) game.world.add(Crate(target: p));
  }

  /// Thả Crate tại vị trí chỉ định (dùng để debug)
  void dropCrateAt(Vector2 p) {
    final target = Vector2(
      p.x.clamp(80.0, kWorldSize.x - 80).toDouble(),
      p.y.clamp(80.0, kWorldSize.y - 80).toDouble(),
    );
    game.world.add(Crate(target: target));
  }

  Vector2? _findSpot() {
    final center = kWorldSize / 2;
    const margin = 120.0;

    for (var i = 0; i < 40; i++) {
      final p = Vector2(
        margin + random.nextDouble() * (kWorldSize.x - margin * 2),
        margin + random.nextDouble() * (kWorldSize.y - margin * 2),
      );
      if (p.distanceTo(center) < 260) continue; // chừa House
      if (p.distanceTo(game.player.position) < 150) continue;
      if (game.solids.any((s) => s.position.distanceTo(p) < 100)) continue;
      if (game.world.children
          .query<Crate>()
          .any((c) => c.target.distanceTo(p) < 150)) {
        continue;
      }
      return p;
    }
    return null;
  }
}