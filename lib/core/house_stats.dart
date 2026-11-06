class HouseStats {
  static const int maxLevel = 10;
  static const int scrapUnlockLevel = 5; // Module 3+: từ level này tự sản xuất Scrap

  static double maxHp(int level) => 500.0 + 250.0 * (level - 1);

  /// Hệ số nhân Coin sau mỗi Wave (Module 5)
  static double coinMultiplier(int level) => 1.0 + 0.25 * (level - 1);

  static bool producesScrap(int level) => level >= scrapUnlockLevel;

  /// Chi phí để nâng từ [level] lên [level] + 1
  static int woodCost(int level) => 15 * level;
  static int stoneCost(int level) => 8 * level;

    /// Số giây giữa 2 lần House tự sinh 1 Scrap (chỉ từ scrapUnlockLevel)
  static double scrapInterval(int level) =>
      (22.0 - 2.0 * (level - scrapUnlockLevel)).clamp(8.0, 22.0).toDouble();
}