import 'package:flutter/material.dart';

import '../core/building.dart';
import '../game/zummoon_game.dart';

/// Thanh điều khiển khi đang đặt công trình: ĐẶT / XOAY / HỦY
class BuildBar extends StatelessWidget {
  const BuildBar({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    final bm = game.buildManager;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 130),
          child: ListenableBuilder(
            listenable: Listenable.merge(
                [bm.selected, bm.canPlace, bm.rotated, game.state.scrap]),
            builder: (context, _) {
              final t = bm.selected.value;
              if (t == null) return const SizedBox.shrink();

              final ok = bm.canPlace.value;
              final have = game.state.scrap.value;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xDD101820),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ok
                        ? const Color(0xFF4CD964)
                        : const Color(0xFFFF6B6B),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${t.displayName}  •  Scrap $have/${t.scrapCost}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      ok
                          ? 'Di chuyển để chọn vị trí'
                          : 'Vị trí bị chặn - hãy di chuyển',
                      style: TextStyle(
                        color: ok
                            ? const Color(0xFF4CD964)
                            : const Color(0xFFFF6B6B),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t == BuildingType.fence) ...[
                          OutlinedButton.icon(
                            onPressed: bm.toggleRotate,
                            icon: const Icon(Icons.rotate_90_degrees_cw,
                                size: 18),
                            label: const Text('XOAY'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: ok ? bm.confirm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CD964),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('ĐẶT',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: bm.cancel,
                          child: const Text('HỦY',
                              style: TextStyle(color: Color(0xFFFF6B6B))),
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