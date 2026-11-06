import 'package:flutter/material.dart';

import '../game/zummoon_game.dart';

/// Nút 🔨 mở bảng Crafting (nằm phía trên nút ĐẤM)
class CraftButton extends StatelessWidget {
  const CraftButton({super.key, required this.game});
  final ZummoonGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 56, bottom: 148),
          child: Material(
            color: const Color(0xCC1E6FBF),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white54, width: 2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: game.toggleCrafting,
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction, color: Colors.white, size: 26),
                    Text('XÂY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}