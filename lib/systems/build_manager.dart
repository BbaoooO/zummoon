import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/buildings/build_ghost.dart';
import '../components/buildings/building.dart';
import '../components/buildings/farming_house.dart';
import '../components/buildings/fence.dart';
import '../components/buildings/turret.dart';
import '../components/vfx/damage_popup.dart';
import '../components/vfx/debris_burst.dart';
import '../components/vfx/shockwave_ring.dart';
import '../core/building.dart';
import '../game/zummoon_game.dart';

/// Quản lý chế độ xây dựng. ValueNotifier để UI tự cập nhật.
class BuildManager {
  BuildManager(this.game);
  final ZummoonGame game;

  final ValueNotifier<BuildingType?> selected = ValueNotifier(null);
  final ValueNotifier<bool> rotated = ValueNotifier(false);
  final ValueNotifier<bool> canPlace = ValueNotifier(false);

  BuildGhost? _ghost;

  bool get isBuilding => selected.value != null;

  void start(BuildingType t) {
    cancel();
    selected.value = t;
    rotated.value = false;
    _ghost = BuildGhost();
    game.world.add(_ghost!);
    game.overlays.remove(ZummoonGame.overlayCrafting);
    game.overlays.add(ZummoonGame.overlayBuildBar);
  }

  void toggleRotate() {
    if (selected.value == BuildingType.fence) rotated.value = !rotated.value;
  }

  void cancel() {
    _ghost?.removeFromParent();
    _ghost = null;
    selected.value = null;
    rotated.value = false;
    canPlace.value = false;
    game.overlays.remove(ZummoonGame.overlayBuildBar);
  }

  /// Dùng khi startNewGame (world đã bị xóa sạch nên không removeFromParent nữa)
  void reset() {
    _ghost = null;
    selected.value = null;
    rotated.value = false;
    canPlace.value = false;
  }

  bool confirm() {
    final t = selected.value;
    final g = _ghost;
    if (t == null || g == null) return false;

    if (!g.valid) {
      _warn('Vị trí bị chặn!');
      return false;
    }
    if (!game.state.trySpend(0, 0, scrapCost: t.scrapCost)) {
      _warn('Không đủ Scrap!');
      return false;
    }

    final pos = g.position.clone();
    game.world.add(_create(t, pos, rotated.value));
    game.world.add(ShockwaveRing(
      at: pos,
      maxRadius: 70,
      color: const Color(0xFF6EC6FF),
    ));
    game.world.add(DebrisBurst(
      at: pos,
      colors: const [Color(0xFFD7C3A0), Color(0xFF9AA0A8)],
      count: 10,
      speed: 110,
    ));

    g.valid = false;
    canPlace.value = false;

    // Hết Scrap thì tự thoát chế độ xây
    if (!game.state.canAfford(0, 0, scrapCost: t.scrapCost)) cancel();
    return true;
  }

  Building _create(BuildingType t, Vector2 p, bool rot) => switch (t) {
        BuildingType.turret => Turret(position: p),
        BuildingType.fence => Fence(position: p, rotated: rot),
        BuildingType.farm => FarmingHouse(position: p),
      };

  void _warn(String msg) {
    game.world.add(DamagePopup(
      msg,
      at: game.player.position + Vector2(0, -56),
      color: const Color(0xFFFF6B6B),
      fontSize: 18,
    ));
  }
}