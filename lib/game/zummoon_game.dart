import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

import '../components/enemies/zombie.dart';
import '../components/player/player.dart';
import '../components/ui/crate_indicator.dart';
import '../components/ui/hud_controls.dart';
import '../components/world/baseplate.dart';
import '../components/world/house.dart';
import '../components/world/rock.dart';
import '../components/world/tree.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/house_stats.dart';
import '../core/mixins/damageable.dart';
import '../core/mixins/solid.dart';
import '../systems/build_manager.dart';
import '../systems/crate_spawner.dart';
import '../systems/resource_spawner.dart';
import '../systems/wave_manager.dart';
import '../systems/weapon_manager.dart';

class ZummoonGame extends FlameGame with HasKeyboardHandlerComponents {
  static const overlayHud = 'hud';
  static const overlayUpgrade = 'upgrade';
  static const overlayWeapons = 'weapons';
  static const overlayCraftButton = 'craftBtn';
  static const overlayCrafting = 'crafting';
  static const overlayBuildBar = 'buildBar';
  static const overlayWave = 'wave';

  final GameState state = GameState();
  final WeaponManager weapons = WeaponManager();
  late final BuildManager buildManager = BuildManager(this);

  /// Hệ số tốc độ farm của Farming House (Module 6: Buff sẽ chỉnh số này)
  double farmSpeed = 1.0;

  /// Danh sách đăng ký tự động bởi mixin Solid / Damageable / Zombie
  final List<Solid> solids = [];
  final List<Damageable> damageables = [];
  final List<Zombie> zombies = [];

  late final JoystickComponent joystick;
  late Player player;
  late House house;
  late CrateSpawner crateSpawner;
  late WaveManager waves;

  bool _ready = false;
  bool _upgradeVisible = false;

  @override
  Color backgroundColor() => const Color(0xFF101010);

  @override
  Future<void> onLoad() async {
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 24,
        paint: Paint()..color = const Color(0xCCFFFFFF),
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = const Color(0x44FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
    camera.viewport.add(createPunchButton(onPressed: () => player.punch()));
    camera.viewport.add(CrateIndicator());

    camera.viewfinder.anchor = Anchor.center;


    _buildWorld();
    _ready = true;
  }

  // ---------------- Dựng / Reset thế giới ----------------

  void _buildWorld() {
    final seed = DateTime.now().millisecondsSinceEpoch;

    world.add(Baseplate(seed: seed));

    house = House();
    world.add(house);

    player = Player(joystick: joystick)..onPunch = _handlePunch;
    world.add(player);

    world.add(ResourceSpawner(random: Random(seed)));

    crateSpawner = CrateSpawner(random: Random(seed + 7));
    world.add(crateSpawner);

    waves = WaveManager(random: Random(seed + 13));
    world.add(waves);

    camera.follow(player);
  }

  /// Randomize lại toàn bộ map và reset mọi thứ (Module 6 gọi khi Game Over)
  void startNewGame() {
    world.removeAll(world.children.toList());
    solids.clear();
    damageables.clear();
    zombies.clear();
    state.reset();
    weapons.reset();
    buildManager.reset();
    farmSpeed = 1.0;
    overlays.remove(overlayCrafting);
    overlays.remove(overlayBuildBar);
    _buildWorld();
  }

  // ---------------- Game Over ----------------

  void _gameOver(String reason) {
    if (state.gameOver.value) return;
    state.gameOver.value = true;
    buildManager.cancel();
    overlays.remove(overlayCrafting);
    waves.showBanner('$reason\nGAME OVER', 99999);
    // TODO Module 6: hiện bảng tổng kết (wave, kills, coin...)
    debugPrint('GAME OVER: $reason');
  }

  void onHouseDestroyed() => _gameOver('NHÀ ĐÃ BỊ PHÁ HỦY!');
  void onPlayerDied() => _gameOver('BẠN ĐÃ CHẾT!');

  /// WaveManager gọi khi clear Wave
  void onWaveCleared(int clearedWave, int reward) {
    // TODO Module 6: mở Shop -> overlays.add('shop'); waves.paused = true;
  }

  // ---------------- Crafting ----------------

  /// Mở / đóng bảng Crafting (đang đặt công trình thì hủy chế độ xây trước)
  void toggleCrafting() {
    if (buildManager.isBuilding) buildManager.cancel();
    if (overlays.isActive(overlayCrafting)) {
      overlays.remove(overlayCrafting);
    } else {
      overlays.add(overlayCrafting);
    }
  }

  // ---------------- Đánh ----------------

  void _handlePunch(Vector2 point, double radius) {
    final weapon = weapons.current;

    final hits = <(Damageable, double)>[];
    for (final d in damageables) {
      if (!d.punchable || d.isDead) continue;
      final dist = d.position.distanceTo(point);
      if (dist <= radius + d.hitRadius) hits.add((d, dist));
    }
    hits.sort((a, b) => a.$2.compareTo(b.$2));

    for (final h in hits.take(weapon.maxTargets)) {
      final target = h.$1;
      var dmg = weapon.damage;
      if (target is Tree) {
        dmg *= weapon.treeMult;
      } else if (target is Rock) {
        dmg *= weapon.rockMult;
      }
      target.takeDamage(dmg, from: player.position);
    }
  }

  // ---------------- Nâng cấp House ----------------

  bool upgradeHouse() {
    final lvl = house.level;
    if (lvl >= HouseStats.maxLevel) return false;
    if (!state.trySpend(HouseStats.woodCost(lvl), HouseStats.stoneCost(lvl))) {
      return false;
    }
    house.levelUp();
    state.houseLevel.value = house.level;
    return true;
  }

  // ---------------- Update ----------------

  @override
  void update(double dt) {
    super.update(dt);
    if (!_ready) return;

    // Đồng bộ HP cho HUD
    state.playerHp.value = player.hp.ceil();
    state.playerMaxHp.value = player.maxHp.round();
    state.houseHp.value = house.hp.ceil();
    state.houseMaxHp.value = house.maxHp.round();

    // Tự hiện / ẩn bảng nâng cấp khi lại gần House
    final near = !state.gameOver.value &&
        !house.isDead &&
        player.position.distanceTo(house.position) <= kHouseInteractRadius;
    if (near != _upgradeVisible) {
      _upgradeVisible = near;
      if (near) {
        overlays.add(overlayUpgrade);
      } else {
        overlays.remove(overlayUpgrade);
      }
    }
  }
}