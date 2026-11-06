import 'dart:math';

import 'package:flutter/material.dart';

import '../components/buildings/building_painters.dart';
import '../core/building.dart';
import '../game/zummoon_game.dart';

class CraftingPanel extends StatelessWidget {
  const CraftingPanel({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    final s = game.state;
    final maxW = min(MediaQuery.of(context).size.width - 24, 600.0);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: s.scrap,
            builder: (context, _) {
              return Container(
                width: maxW,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xEE101820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6EC6FF), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'CHẾ TẠO & XÂY DỰNG',
                          style: TextStyle(
                            color: Color(0xFF6EC6FF),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.settings,
                            color: Color(0xFF6EC6FF), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Scrap: ${s.scrap.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => game.overlays
                              .remove(ZummoonGame.overlayCrafting),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final t in BuildingType.values)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _BuildCard(
                                type: t,
                                have: s.scrap.value,
                                onBuild: () => game.buildManager.start(t),
                              ),
                            ),
                          ),
                      ],
                    ),
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

class _BuildCard extends StatelessWidget {
  const _BuildCard({
    required this.type,
    required this.have,
    required this.onBuild,
  });

  final BuildingType type;
  final int have;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    final afford = have >= type.scrapCost;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x331E6FBF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CustomPaint(painter: BuildingIconPainter(type)),
          ),
          const SizedBox(height: 6),
          Text(
            type.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            type.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            type.stats,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings, size: 16, color: Color(0xFF6EC6FF)),
              const SizedBox(width: 4),
              Text(
                '$have / ${type.scrapCost}',
                style: TextStyle(
                  color: afford
                      ? const Color(0xFF4CD964)
                      : const Color(0xFFFF6B6B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: afford ? onBuild : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EC6FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('XÂY',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}