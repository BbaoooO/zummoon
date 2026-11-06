import 'package:flutter/foundation.dart';

enum ResourceType { wood, stone, scrap }

enum WavePhase { peace, wave }

/// State dùng chung. ValueNotifier để Flutter overlay tự cập nhật.
class GameState {
  // Tài nguyên
  final ValueNotifier<int> wood = ValueNotifier(0);
  final ValueNotifier<int> stone = ValueNotifier(0);
  final ValueNotifier<int> scrap = ValueNotifier(0);
  final ValueNotifier<int> coin = ValueNotifier(0);
  final ValueNotifier<int> houseLevel = ValueNotifier(1);

  // Wave
  final ValueNotifier<int> wave = ValueNotifier(1); // Wave đang / sắp đánh
  final ValueNotifier<WavePhase> phase = ValueNotifier(WavePhase.peace);
  final ValueNotifier<int> countdown = ValueNotifier(0); // giây còn lại ở Peace
  final ValueNotifier<int> zombiesLeft = ValueNotifier(0);
  final ValueNotifier<int> kills = ValueNotifier(0);
  final ValueNotifier<String?> banner = ValueNotifier(null);
  final ValueNotifier<bool> gameOver = ValueNotifier(false);

  // HP (game đồng bộ mỗi frame để HUD hiển thị)
  final ValueNotifier<int> playerHp = ValueNotifier(100);
  final ValueNotifier<int> playerMaxHp = ValueNotifier(100);
  final ValueNotifier<int> houseHp = ValueNotifier(500);
  final ValueNotifier<int> houseMaxHp = ValueNotifier(500);

  void add(ResourceType type, int amount) {
    switch (type) {
      case ResourceType.wood:
        wood.value += amount;
      case ResourceType.stone:
        stone.value += amount;
      case ResourceType.scrap:
        scrap.value += amount;
    }
  }

  bool canAfford(int woodCost, int stoneCost, {int scrapCost = 0}) =>
      wood.value >= woodCost &&
      stone.value >= stoneCost &&
      scrap.value >= scrapCost;

  bool trySpend(int woodCost, int stoneCost, {int scrapCost = 0}) {
    if (!canAfford(woodCost, stoneCost, scrapCost: scrapCost)) return false;
    wood.value -= woodCost;
    stone.value -= stoneCost;
    scrap.value -= scrapCost;
    return true;
  }

  /// Module 6 (Shop) sẽ dùng
  bool trySpendCoin(int amount) {
    if (coin.value < amount) return false;
    coin.value -= amount;
    return true;
  }

  void reset() {
    wood.value = 0;
    stone.value = 0;
    scrap.value = 0;
    coin.value = 0;
    houseLevel.value = 1;
    wave.value = 1;
    phase.value = WavePhase.peace;
    countdown.value = 0;
    zombiesLeft.value = 0;
    kills.value = 0;
    banner.value = null;
    gameOver.value = false;
  }
}