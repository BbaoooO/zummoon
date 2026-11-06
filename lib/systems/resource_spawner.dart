import 'dart:math';

import 'package:flame/components.dart';

import '../components/world/rock.dart';
import '../components/world/tree.dart';
import '../core/constants.dart';
import '../game/zummoon_game.dart';

/// Rải Cây/Đá ngẫu nhiên khi vào game và định kỳ bù lại phần đã bị khai thác.
class ResourceSpawner extends Component with HasGameReference<ZummoonGame> {
  ResourceSpawner({required this.random});

  final Random random;
  double _timer = 0;

  @override
  Future<void> onLoad() async {
    // [placed] giữ vị trí các vật vừa đặt (chúng chưa kịp mount nên chưa nằm trong game.solids)
    final placed = <Vector2>[];
    for (var i = 0; i < kInitialTrees; i++) {
      final p = _findSpot(placed);
      if (p == null) continue;
      placed.add(p);
      game.world.add(Tree(position: p, random: random));
    }
    for (var i = 0; i < kInitialRocks; i++) {
      final p = _findSpot(placed);
      if (p == null) continue;
      placed.add(p);
      game.world.add(Rock(position: p, random: random));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer < kRespawnInterval) return;
    _timer = 0;

    if (game.world.children.query<Tree>().length < kMaxTrees) {
      final p = _findSpot(const []);
      if (p != null) game.world.add(Tree(position: p, random: random));
    }
    if (game.world.children.query<Rock>().length < kMaxRocks) {
      final p = _findSpot(const []);
      if (p != null) game.world.add(Rock(position: p, random: random));
    }
  }

  Vector2? _findSpot(List<Vector2> placed) {
    final center = kWorldSize / 2;
    const margin = 80.0;

    for (var i = 0; i < 40; i++) {
      final p = Vector2(
        margin + random.nextDouble() * (kWorldSize.x - margin * 2),
        margin + random.nextDouble() * (kWorldSize.y - margin * 2),
      );
      if (p.distanceTo(center) < kSafeRadius) continue; // chừa chỗ cho House
      if (p.distanceTo(game.player.position) < 160) continue;
      if (placed.any((q) => q.distanceTo(p) < kObjectSpacing)) continue;
      if (game.solids.any((s) => s.position.distanceTo(p) < kObjectSpacing)) {
        continue;
      }
      return p;
    }
    return null;
  }
}