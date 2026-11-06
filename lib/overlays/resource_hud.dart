import 'package:flutter/material.dart';

import '../core/game_state.dart';

class ResourceHud extends StatelessWidget {
  const ResourceHud({super.key, required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Chip(
                icon: Icons.forest,
                color: const Color(0xFFE0B070),
                label: 'Gỗ',
                value: state.wood,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.terrain,
                color: const Color(0xFFD0D4DC),
                label: 'Đá',
                value: state.stone,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.settings,
                color: const Color(0xFF6EC6FF),
                label: 'Scrap',
                value: state.scrap,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.home,
                color: const Color(0xFFFFC107),
                label: 'Nhà Lv',
                value: state.houseLevel,
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.monetization_on,
                color: const Color(0xFFFFD700),
                label: 'Coin',
                value: state.coin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final ValueNotifier<int> value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          ValueListenableBuilder<int>(
            valueListenable: value,
            builder: (_, v, __) => Text(
              '$label: $v',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}