# Zummoon 🌙🧟

Game sinh tồn 2D (top-down) viết bằng **Flutter + Flame**. Bạn bảo vệ ngôi nhà giữa một
khu rừng, chặt cây / đập đá để lấy tài nguyên, nhặt vũ khí từ thùng tiếp tế rơi xuống,
xây công trình phòng thủ và chống lại từng đợt zombie ngày càng mạnh.

> Trạng thái: **Module 1–5 hoàn thành**, Module 6 (shop / bảng tổng kết) còn đang phát triển.

---

## Tính năng đã có

### Chiến đấu & di chuyển
- Joystick ảo (góc dưới trái) + bàn phím WASD / mũi tên.
- Đấm bằng tay không (2 tay luân phiên) hoặc vung vũ khí, có hiệu ứng `SlashArc`.
- Knockback, rung màn hình (shake), nhấp nháy khi trúng đòn, thanh máu trên đầu.
- Hồi máu khi đang trong thời gian hòa bình.

### Tài nguyên
- **Gỗ** — chặt cây (5 HP, 3 bảng màu ngẫu nhiên).
- **Đá** — đập đá (8 HP, đa giác 8 cạnh ngẫu nhiên).
- **Scrap** — từ thùng tiếp tế, nhà (từ Lv5) và nhà nông.
- **Coin** — thưởng cuối mỗi wave, nhân theo cấp nhà.
- Tài nguyên rơi ra sẽ tản mát, nảy lên rồi bị hút về phía người chơi.

### Vũ khí (4 ô)
| Vũ khí | Sát thương | Hồi | Đặc điểm |
|---|---|---|---|
| Nắm đấm | 1 | 0.35s | Mặc định, không thể bỏ |
| Gậy bóng chày | 3 | 0.40s | Cân bằng |
| Rìu | 4 | 0.50s | ×2 sát thương lên cây |
| Búa | 6 | 0.75s | ×2 sát thương lên đá |
| Kiếm | 5 | 0.35s | Đánh trúng 3 mục tiêu |

Độ hiếm: Thường / Hiếm / Cực hiếm / Huyền thoại (màu viền khác nhau). Nhặt trùng vũ khí → +3 scrap.

### Thùng tiếp tế (Crate)
- Rơi từ trên cao với dù, có bóng mờ + vòng cảnh báo dưới đất.
- Chỉ đấm được sau khi chạm đất (kèm hiệu ứng squash + sóng xung kích + mảnh vỡ).
- 45% ra vũ khí, còn lại 3–6 scrap.
- Mũi tên chỉ hướng ở mép màn hình khi thùng nằm ngoài khung nhìn.

### Xây dựng
| Công trình | Giá | HP | Chức năng |
|---|---|---|---|
| Tháp súng | 12 scrap | 150 | Tự ngắm và bắn zombie trong tầm 280 |
| Hàng rào | 2 scrap | 160 | Chắn đường, xoay được ngang/dọc |
| Nhà nông | 15 scrap | 100 | Định kỳ sinh gỗ + đá |

Có "bóng ma" xem trước khi đặt: bám lưới 10px, xanh = hợp lệ, đỏ = chồng lấn.

### Nhà chính & nâng cấp
- 10 cấp, mỗi cấp +250 HP và +25% coin.
- Từ cấp 5 tự sản xuất scrap (chu kỳ giảm dần 22s → 8s).
- Màu tường/mái đổi theo nhóm cấp. Nâng cấp có sóng xung kích.
- Nhà bị phá → **Game Over**.

### Wave & Zombie
| Loại | HP | Tốc độ | Sát thương | Ghi chú |
|---|---|---|---|---|
| Thường | 20 | 70 | 8 | Cân bằng |
| Nhanh | 9 | 155 | 5 | Bị đẩy lùi mạnh |
| Tank | 130 | 38 | 22 | ×3 sát thương lên công trình |
| Bắn xa | 14 | 60 | 9 | Bắn đạn spit tầm 270 |

- Thời gian hòa bình 30s (lần đầu) / 25s, có thể bấm "BẮT ĐẦU SỚM".
- Số lượng và độ mạnh tăng dần theo wave (HP ×1.12, damage ×1.06, speed ×1.02 mỗi wave).
- Zombie tự chọn mục tiêu: người chơi (nếu gần) → công trình chắn đường → nhà.
- Có steering tránh vật cản và tách nhau ra để không chồng lên nhau.

### Giao diện (tiếng Việt)
- HUD tài nguyên góc trái trên.
- Panel wave góc phải trên: wave, đếm ngược, thanh máu người chơi & nhà.
- Banner thông báo giữa màn hình.
- Panel nâng cấp nhà (hiện khi lại gần).
- Thanh vũ khí 4 ô dưới màn hình.
- Panel chế tạo công trình + thanh đặt/xoay/hủy.

---

## Điều khiển

| Phím / thao tác | Chức năng |
|---|---|
| Joystick / `WASD` / mũi tên | Di chuyển |
| `Space` / nút ĐẤM | Tấn công |
| `B` | Mở panel chế tạo |
| `1`–`4` / `Q` | Đổi vũ khí |
| `Enter` | Xác nhận đặt công trình |
| `E` | Xoay hàng rào |
| `Esc` | Hủy đặt |
| `R` | Chơi lại (khi game over) |

Phím debug (sẽ bị gỡ ở Module 6): `G` +20 scrap, `N` bắt đầu wave, `X` diệt hết zombie,
`H` trừ 40 HP nhà, `C` thả thùng tiếp tế.

---

## Cấu trúc dự án

```
lib/
├── main.dart                     # Entry point, đăng ký overlay
├── core/
│   ├── constants.dart            # Toàn bộ hằng số cân bằng game
│   ├── game_state.dart           # ValueNotifier dùng chung Flame ↔ Flutter
│   ├── weapon.dart               # Vũ khí, độ hiếm, vẽ vector
│   ├── zombie_type.dart          # Loại zombie + thành phần wave
│   ├── building.dart             # Loại công trình + hình học đặt
│   ├── house_stats.dart          # Đường cong nâng cấp nhà
│   └── mixins/
│       ├── damageable.dart       # HP, sát thương, knockback, hiệu ứng
│       └── solid.dart            # Va chạm vật lý
├── game/
│   └── zummoon_game.dart         # Lớp game trung tâm
├── components/
│   ├── player/                   # Player, Hand, WeaponVisual
│   ├── enemies/                  # Zombie, ZombieSpit, DebugDummy
│   ├── world/                    # House, Crate, Tree, Rock, Baseplate, drops
│   ├── buildings/                # Turret, Fence, FarmingHouse, BuildGhost, painters
│   ├── ui/                       # CrateIndicator, HudButton
│   └── vfx/                      # DamagePopup, DebrisBurst, ShockwaveRing, SlashArc, CrateShadow
├── systems/
│   ├── wave_manager.dart         # Vòng lặp wave
│   ├── build_manager.dart        # Trạng thái chế độ xây dựng
│   ├── weapon_manager.dart       # Túi đồ vũ khí
│   ├── crate_spawner.dart        # Hẹn giờ thả thùng
│   └── resource_spawner.dart     # Sinh cây/đá + hồi sinh
└── overlays/                     # 7 widget Flutter HUD
```

---

## Chạy dự án

```bash
flutter pub get
flutter run -d windows    # hoặc: chrome / android
```

Yêu cầu: Flutter SDK (Dart `^3.13.5`), phụ thuộc duy nhất `flame ^1.38.2`.

---

## Roadmap

- [x] Module 1 — Nền tảng: game loop, người chơi, joystick, thế giới
- [x] Module 2 — Tài nguyên: cây, đá, rơi/nhặt, HUD
- [x] Module 3 — Chiến đấu: vũ khí, thùng tiếp tế, hiệu ứng
- [x] Module 4 — Xây dựng: tháp súng, hàng rào, nhà nông
- [x] Module 5 — Wave & zombie, nâng cấp nhà
- [ ] Module 6 — Shop giữa các wave, bảng tổng kết khi thua, buff, gỡ phím debug
