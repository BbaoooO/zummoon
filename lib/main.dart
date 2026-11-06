import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/zummoon_game.dart';
import 'overlays/build_bar.dart';
import 'overlays/craft_button.dart';
import 'overlays/crafting_panel.dart';
import 'overlays/house_upgrade_panel.dart';
import 'overlays/resource_hud.dart';
import 'overlays/wave_hud.dart';
import 'overlays/weapon_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape(); // bỏ dòng này nếu test trên Chrome/desktop

  final game = ZummoonGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<ZummoonGame>(
          game: game,
          initialActiveOverlays: const [
            ZummoonGame.overlayHud,
            ZummoonGame.overlayWave,
            ZummoonGame.overlayWeapons,
            ZummoonGame.overlayCraftButton,
          ],
          overlayBuilderMap: {
            ZummoonGame.overlayHud: (context, g) => ResourceHud(state: g.state),
            ZummoonGame.overlayWave: (context, g) => WaveHud(game: g),
            ZummoonGame.overlayUpgrade: (context, g) =>
                HouseUpgradePanel(game: g),
            ZummoonGame.overlayWeapons: (context, g) => WeaponBar(game: g),
            ZummoonGame.overlayCraftButton: (context, g) =>
                CraftButton(game: g),
            ZummoonGame.overlayCrafting: (context, g) => CraftingPanel(game: g),
            ZummoonGame.overlayBuildBar: (context, g) => BuildBar(game: g),
          },
        ),
      ),
    ),
  );
}