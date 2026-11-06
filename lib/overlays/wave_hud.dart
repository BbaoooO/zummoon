import 'package:flutter/material.dart';

import '../core/game_state.dart';
import '../game/zummoon_game.dart';

/// Góc phải trên: Wave + đếm ngược + HP. Giữa màn hình: banner thông báo.
class WaveHud extends StatelessWidget {
  const WaveHud({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _Panel(game: game),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.35),
            child: IgnorePointer(child: _Banner(game: game)),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.game});
  final ZummoonGame game;

  static String _mmss(int sec) =>
      '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = game.state;
    return ListenableBuilder(
      listenable: Listenable.merge([
        s.wave, s.phase, s.countdown, s.zombiesLeft, s.gameOver,
        s.playerHp, s.playerMaxHp, s.houseHp, s.houseMaxHp,
      ]),
      builder: (context, _) {
        final peace = s.phase.value == WavePhase.peace;
        final over = s.gameOver.value;

        return Container(
          width: 230,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xAA000000),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: over
                  ? const Color(0xFFFF3B30)
                  : peace
                      ? const Color(0xFF4CD964)
                      : const Color(0xFFFF9500),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'WAVE ${s.wave.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              if (over) ...[
                const Text(
                  'GAME OVER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Text(
                  'Bấm R để chơi lại (Module 6 sẽ có bảng tổng kết)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    decoration: TextDecoration.none,
                  ),
                ),
              ] else if (peace) ...[
                Text(
                  'Chuẩn bị  •  ${_mmss(s.countdown.value)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4CD964),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: game.waves.startNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('BẮT ĐẦU SỚM',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ] else
                Text(
                  'Zombie còn lại: ${s.zombiesLeft.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFF9500),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              const SizedBox(height: 8),
              _Bar(
                label: 'Bạn',
                value: s.playerHp.value,
                max: s.playerMaxHp.value,
                color: const Color(0xFFFF5A5A),
              ),
              const SizedBox(height: 4),
              _Bar(
                label: 'Nhà',
                value: s.houseHp.value,
                max: s.houseMaxHp.value,
                color: const Color(0xFFFFC107),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio.toDouble(),
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Text(
                '$value / $max',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: game.state.banner,
      builder: (context, text, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: text == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : Text(
                  text,
                  key: ValueKey(text),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE066),
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(blurRadius: 8, color: Colors.black),
                      Shadow(blurRadius: 2, color: Colors.black),
                    ],
                  ),
                ),
        );
      },
    );
  }
}