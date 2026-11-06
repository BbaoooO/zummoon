import 'dart:math';

import 'package:flutter/material.dart';

import '../core/weapon.dart';
import '../game/zummoon_game.dart';
import '../systems/weapon_manager.dart';

/// Thanh 4 ô vũ khí ở giữa dưới màn hình. Chạm vào ô để trang bị.
class WeaponBar extends StatelessWidget {
  const WeaponBar({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    final wm = game.weapons;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ListenableBuilder(
            listenable: Listenable.merge([wm.inventory, wm.equippedIndex]),
            builder: (context, _) {
              final inv = wm.inventory.value;
              final cur = wm.current;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InfoLabel(weapon: cur),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < WeaponManager.maxSlots; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _Slot(
                            index: i,
                            weapon: i < inv.length ? inv[i] : null,
                            selected: i == wm.equippedIndex.value,
                            onTap: () => wm.equip(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({required this.weapon});
  final WeaponType weapon;

  @override
  Widget build(BuildContext context) {
    final perk = weapon.perk;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${weapon.displayName}  •  ST ${weapon.damage.toStringAsFixed(0)}'
        '  •  ${(1 / weapon.cooldown).toStringAsFixed(1)} đòn/s'
        '${perk.isEmpty ? '' : '  •  $perk'}',
        style: TextStyle(
          color: weapon.rarity.color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.index,
    required this.weapon,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final WeaponType? weapon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = weapon?.rarity.color ?? Colors.white24;

    return GestureDetector(
      onTap: weapon == null ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 58,
        height: 58,
        transform: Matrix4.identity()..scale(selected ? 1.12 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xCC1E2630) : const Color(0x99000000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: selected ? 3.5 : 1.5),
        ),
        child: Stack(
          children: [
            if (weapon != null)
              Positioned.fill(
                child: CustomPaint(painter: _WeaponIconPainter(weapon!)),
              ),
            Positioned(
              left: 5,
              top: 2,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeaponIconPainter extends CustomPainter {
  _WeaponIconPainter(this.weapon);
  final WeaponType weapon;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi / 4);
    canvas.translate(0, weapon.length / 2);
    paintWeapon(canvas, weapon);
  }

  @override
  bool shouldRepaint(covariant _WeaponIconPainter old) => old.weapon != weapon;
}