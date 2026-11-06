import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../components/enemies/zombie.dart';
import '../components/vfx/damage_popup.dart';
import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/house_stats.dart';
import '../core/zombie_type.dart';
import '../game/zummoon_game.dart';

/// Điều phối vòng lặp: Peace -> Wave -> (hết Zombie) thưởng Coin -> Peace...
class WaveManager extends Component with HasGameReference<ZummoonGame> {
  WaveManager({required this.random});

  final Random random;

  /// Module 6: đặt true khi mở Shop để tạm dừng đếm ngược Peace
  bool paused = false;

  GameState get _s => game.state;

  double _peaceTimer = kFirstPeaceTime;
  double _spawnTimer = 0;
  double _bannerTimer = 0;
  int _alive = 0;
  final List<ZombieType> _queue = [];

  @override
  Future<void> onLoad() async {
    _s.phase.value = WavePhase.peace;
    _s.countdown.value = kFirstPeaceTime.ceil();
    showBanner('Chuẩn bị phòng thủ!', 3);
  }

  void showBanner(String text, double seconds) {
    _s.banner.value = text;
    _bannerTimer = seconds;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // banner tự tắt
    if (_bannerTimer > 0) {
      _bannerTimer -= dt;
      if (_bannerTimer <= 0) _s.banner.value = null;
    }
    if (_s.gameOver.value) return;

    if (_s.phase.value == WavePhase.peace) {
      if (paused) return;
      _peaceTimer -= dt;
      _s.countdown.value = max(0, _peaceTimer.ceil());
      if (_peaceTimer <= 0) _startWave();
      return;
    }

    // ----- đang trong Wave: spawn dần -----
    _spawnTimer -= dt;
    if (_spawnTimer <= 0 && _queue.isNotEmpty && _alive < kMaxAliveZombies) {
      _spawnZombie(_queue.removeLast());
      _spawnTimer = max(0.3, 1.3 - 0.06 * _s.wave.value);
    }

    if (_queue.isEmpty && _alive <= 0) _finishWave();
  }

  /// Nút "BẮT ĐẦU SỚM"
  void startNow() {
    if (_s.phase.value != WavePhase.peace || _s.gameOver.value) return;
    _startWave();
  }

  void _startWave() {
    final wave = _s.wave.value;
    _queue
      ..clear()
      ..addAll(buildWaveQueue(wave, random));
    _alive = 0;
    _spawnTimer = 1.0;
    _s.phase.value = WavePhase.wave;
    _refreshLeft();
    showBanner('WAVE $wave', 2.5);
  }

  void _spawnZombie(ZombieType t) {
    game.world.add(Zombie(
      type: t,
      position: _edgePoint(),
      wave: _s.wave.value,
    ));
    _alive++;
    _refreshLeft();
  }

  /// Điểm ngẫu nhiên trên 1 trong 4 viền map
  Vector2 _edgePoint() {
    const m = kSpawnMargin;
    double rx() => m + random.nextDouble() * (kWorldSize.x - m * 2);
    double ry() => m + random.nextDouble() * (kWorldSize.y - m * 2);
    return switch (random.nextInt(4)) {
      0 => Vector2(rx(), m),
      1 => Vector2(rx(), kWorldSize.y - m),
      2 => Vector2(m, ry()),
      _ => Vector2(kWorldSize.x - m, ry()),
    };
  }

  /// Zombie gọi khi chết
  void onZombieDied() {
    _alive = max(0, _alive - 1);
    _s.kills.value++;
    _refreshLeft();
  }

  void _refreshLeft() => _s.zombiesLeft.value = _queue.length + _alive;

  void _finishWave() {
    final cleared = _s.wave.value;
    final mult = HouseStats.coinMultiplier(game.house.level);
    final reward =
        ((kWaveBaseReward + kWaveRewardPerLevel * cleared) * mult).round();

    _s.coin.value += reward;
    _s.wave.value = cleared + 1;
    _s.phase.value = WavePhase.peace;
    _peaceTimer = kPeaceTime;
    _s.countdown.value = kPeaceTime.ceil();

    showBanner(
      'WAVE $cleared HOÀN THÀNH!\n+$reward Coin  (x${mult.toStringAsFixed(2)})',
      3.5,
    );
    game.world.add(DamagePopup(
      '+$reward Coin',
      at: game.player.position + Vector2(0, -64),
      color: const Color(0xFFFFC107),
      fontSize: 26,
    ));

    game.onWaveCleared(cleared, reward);
  }

  /// DEBUG: giết hết Zombie đang có
  void debugKillAll() {
    for (final z in game.zombies.toList()) {
      z.takeDamage(99999);
    }
  }
}