import 'package:flutter/material.dart';

import '../core/house_stats.dart';
import '../game/zummoon_game.dart';

class HouseUpgradePanel extends StatelessWidget {
  const HouseUpgradePanel({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    final s = game.state;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 56),
          child: ListenableBuilder(
            listenable: Listenable.merge([s.wood, s.stone, s.houseLevel]),
            builder: (context, _) {
              final lvl = s.houseLevel.value;
              final isMax = lvl >= HouseStats.maxLevel;
              final wc = HouseStats.woodCost(lvl);
              final sc = HouseStats.stoneCost(lvl);
              final canUpgrade = !isMax && s.canAfford(wc, sc);

              return Container(
                width: 280,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xE6101820),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFC107), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'NHÀ  •  Lv.$lvl',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isMax)
                      const _Line('Đã đạt cấp tối đa!', '')
                    else ...[
                      _Line(
                        'Máu tối đa',
                        '${HouseStats.maxHp(lvl).round()} → ${HouseStats.maxHp(lvl + 1).round()}',
                      ),
                      _Line(
                        'Hệ số Coin',
                        'x${HouseStats.coinMultiplier(lvl).toStringAsFixed(2)} → x${HouseStats.coinMultiplier(lvl + 1).toStringAsFixed(2)}',
                      ),
                      if (lvl + 1 == HouseStats.scrapUnlockLevel)
                        const _Line('Mở khóa', 'Tự sản xuất Scrap'),
                      const Divider(color: Colors.white24, height: 16),
                      _Cost(
                          icon: Icons.forest,
                          label: 'Gỗ',
                          have: s.wood.value,
                          need: wc),
                      _Cost(
                          icon: Icons.terrain,
                          label: 'Đá',
                          have: s.stone.value,
                          need: sc),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: canUpgrade ? game.upgradeHouse : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('NÂNG CẤP',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.left, this.right);
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        color: Colors.white, fontSize: 14, decoration: TextDecoration.none);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left, style: style), Text(right, style: style)],
      ),
    );
  }
}

class _Cost extends StatelessWidget {
  const _Cost({
    required this.icon,
    required this.label,
    required this.have,
    required this.need,
  });
  final IconData icon;
  final String label;
  final int have;
  final int need;

  @override
  Widget build(BuildContext context) {
    final enough = have >= need;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none)),
          const Spacer(),
          Text(
            '$have / $need',
            style: TextStyle(
              color: enough ? const Color(0xFF4CD964) : const Color(0xFFFF6B6B),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}