import 'dart:math';

import 'package:flame/components.dart';

/// Kích thước toàn bản đồ (pixel thế giới)
final Vector2 kWorldSize = Vector2(3000, 3000);

/// Random dùng cho hiệu ứng (không cần seed)
final Random globalRandom = Random();

// ---------- Player ----------
const double kPlayerSize = 48;
const double kPlayerSpeed = 220;
const double kPunchCooldown = 0.35;
const double kPunchReach = 20;
const double kPunchHitRadius = 30;
const double kPunchDamage = 1;
const double kHandRadius = 9;

// ---------- House ----------
const double kHouseSize = 150;
const double kHouseInteractRadius = 230; // lại gần cỡ này sẽ hiện bảng nâng cấp

// ---------- Map / Spawn ----------
const double kSafeRadius = 320; // vùng quanh House không mọc Cây/Đá
const double kObjectSpacing = 110; // khoảng cách tối thiểu giữa các vật thể
const int kInitialTrees = 70;
const int kInitialRocks = 40;
const int kMaxTrees = 80;
const int kMaxRocks = 45;
const double kRespawnInterval = 8; // giây / lần bù Cây & Đá

// ---------- Resource ----------
const double kTreeHp = 5;
const double kRockHp = 8;
const int kTreeWoodMin = 2;
const int kTreeWoodMax = 4;
const int kRockStoneMin = 2;
const int kRockStoneMax = 3;
const double kPickupRadius = 90;

// ---------- Crate / Weapon ----------
const double kFirstCrateDelay = 10; // giây đến Crate đầu tiên
const double kCrateInterval = 25; // cứ X giây thả 1 Crate
const int kMaxCrates = 4; // tối đa cùng lúc trên map
const double kCrateSize = 56;
const double kCrateHp = 4;
const double kCrateFallHeight = 800; // độ cao xuất phát (pixel)
const double kCrateFallTime = 2.4; // thời gian rơi (giây)
const double kCrateWeaponChance = 0.45; // còn lại là Scrap
const int kCrateScrapMin = 3;
const int kCrateScrapMax = 6;
const double kWeaponPickupRadius = 55;

// ---------- Buildings ----------
const double kBuildSnap = 10; // lưới căn chỉnh khi đặt
const double kTurretRange = 280;
const double kTurretFireInterval = 0.5;
const double kTurretDamage = 4;
const double kBulletSpeed = 650;
const double kFarmInterval = 15; // giây / lần sản xuất
const int kFarmWood = 2;
const int kFarmStone = 1;

// ---------- Player HP ----------
const double kPlayerMaxHp = 100;
const double kPlayerRegenPeace = 3; // HP/giây khi đang Peace

// ---------- Wave ----------
const double kFirstPeaceTime = 30; // giây chuẩn bị trước Wave 1
const double kPeaceTime = 25; // giây chuẩn bị giữa các Wave
const int kMaxAliveZombies = 25; // tối đa cùng lúc trên map
const double kSpawnMargin = 40; // cách mép map bao xa khi spawn
const int kWaveBaseReward = 20;
const int kWaveRewardPerLevel = 12;