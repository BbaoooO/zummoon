import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/mixins/damageable.dart';
import '../../core/weapon.dart';
import '../../game/zummoon_game.dart';
import '../vfx/slash_arc.dart';
import 'hand.dart';
import '../../core/game_state.dart';

class Player extends PositionComponent
    with KeyboardHandler, HasGameReference<ZummoonGame>, Damageable {
  Player({required this.joystick})
      : super(
          size: Vector2.all(kPlayerSize),
          anchor: Anchor.center,
          position: kWorldSize / 2 + Vector2(0, kHouseSize / 2 + 70),
          priority: 10,
        ) {
          initHp(kPlayerMaxHp);
          }

  final JoystickComponent joystick;

  late final Hand leftHand;
  late final Hand rightHand;

  @override
  bool get punchable => false; // không tự đấm mình

  @override
  void onDeath() => game.onPlayerDied();

  /// Game gán callback này để nhận đòn đánh. [point] = tâm vùng trúng đòn
  /// (toạ độ world), [radius] = bán kính.
  void Function(Vector2 point, double radius)? onPunch;

  final Vector2 _keyboardDir = Vector2.zero();
  double _cooldown = 0;
  bool _nextIsLeft = true;
  WeaponType _shownWeapon = WeaponType.fist;

  final Paint _body = Paint()..color = const Color(0xFF3F7FD6);
  final Paint _outline = Paint()
    ..color = const Color(0xFF16305A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _eye = Paint()..color = Colors.white;
  final Paint _pupil = Paint()..color = Colors.black;

  @override
  Future<void> onLoad() async {
    final c = size / 2;
    leftHand = Hand(idlePosition: Vector2(c.x + 10, c.y - 18));
    rightHand = Hand(idlePosition: Vector2(c.x + 10, c.y + 18));
    addAll([leftHand, rightHand]);
  }

  // ---------------- INPUT ----------------

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardDir.setZero();
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _keyboardDir.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _keyboardDir.x += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _keyboardDir.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _keyboardDir.y += 1;
    }
    

    if (event is KeyDownEvent) {
      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.space) punch();
      
            // Xây dựng
      if (k == LogicalKeyboardKey.keyB) game.toggleCrafting();
      if (k == LogicalKeyboardKey.enter) game.buildManager.confirm();
      if (k == LogicalKeyboardKey.escape) game.buildManager.cancel();
      if (k == LogicalKeyboardKey.keyE) game.buildManager.toggleRotate();

      // --- DEBUG (xóa ở Module 6) ---
      if (k == LogicalKeyboardKey.keyG) game.state.add(ResourceType.scrap, 20);
            // --- DEBUG (xóa ở Module 6) ---
      if (k == LogicalKeyboardKey.keyN) game.waves.startNow(); // bắt đầu Wave ngay
      if (k == LogicalKeyboardKey.keyX) game.waves.debugKillAll(); // giết hết Zombie

      // Đổi vũ khí: phím 1-4, Q = chuyển vòng
      if (k == LogicalKeyboardKey.digit1) game.weapons.equip(0);
      if (k == LogicalKeyboardKey.digit2) game.weapons.equip(1);
      if (k == LogicalKeyboardKey.digit3) game.weapons.equip(2);
      if (k == LogicalKeyboardKey.digit4) game.weapons.equip(3);
      if (k == LogicalKeyboardKey.keyQ) game.weapons.cycle();

      // --- DEBUG (xóa ở Module 6) ---
      if (k == LogicalKeyboardKey.keyH) game.house.takeDamage(40);
      if (k == LogicalKeyboardKey.keyR) game.startNewGame();
      if (k == LogicalKeyboardKey.keyC) {
        // thả 1 Crate ngay phía trước mặt
        game.crateSpawner
            .dropCrateAt(position + Vector2(cos(angle), sin(angle)) * 260);
      }
    }
    return true;
  }

  Vector2 _inputDirection() {
    if (joystick.direction != JoystickDirection.idle) {
      return joystick.relativeDelta;
    }
    return _keyboardDir.isZero() ? _keyboardDir : _keyboardDir.normalized();
  }

  // ---------------- UPDATE ----------------

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;
    // Hồi máu chậm khi đang Peace (không hiện popup)
    if (game.state.phase.value == WavePhase.peace) {
      hp = min(maxHp, hp + kPlayerRegenPeace * dt);
    }

    _cooldown = max(0, _cooldown - dt);

    // Đồng bộ vũ khí đang trang bị với hình vẽ trên tay
    final w = game.weapons.current;
    if (w != _shownWeapon) {
      _shownWeapon = w;
      rightHand.weaponVisual.setWeapon(w);
    }

    final input = _inputDirection();
    if (!input.isZero()) {
      position.addScaled(input, kPlayerSpeed * dt);

      final target = atan2(input.y, input.x);
      var diff = (target - angle) % (2 * pi);
      if (diff > pi) diff -= 2 * pi;
      angle += diff * min(1.0, dt * 14);
    }

    // Va chạm với vật cản (Cây, Đá, House, Crate...)
    for (final s in game.solids) {
      // CŨ:  if (s is Damageable && s.isDead) continue;
      // MỚI:
      if (isDeadObject(s)) continue;
      final push = s.pushOut(position, kPlayerSize * 0.45);
      if (push != null) position.add(push);
    }

    // Giữ Player trong bản đồ
    final r = kPlayerSize / 2;
    position.clamp(Vector2.all(r), kWorldSize - Vector2.all(r));
  }

  // ---------------- ATTACK ----------------

  /// Tâm vùng trúng đòn, nằm phía trước mặt Player (toạ độ world)
  Vector2 get punchPoint {
    final reach = game.weapons.current.reach;
    return position +
        Vector2(cos(angle), sin(angle)) * (kPlayerSize / 2 + reach);
  }

  void punch() {
        // CŨ:  if (_cooldown > 0) return;
    if (isDead || _cooldown > 0) return;
    final w = game.weapons.current;
    _cooldown = w.cooldown;

    if (w == WeaponType.fist) {
      // Đấm luân phiên tay trái / tay phải
      final hand = _nextIsLeft ? leftHand : rightHand;
      _nextIsLeft = !_nextIsLeft;
      hand.punch(w.reach);
    } else {
      // Cầm vũ khí: tay phải nhích tới + vũ khí vung + vệt chém
      rightHand.punch(w.reach * 0.4);
      rightHand.weaponVisual.swing();
      game.world.add(SlashArc(
        at: position.clone(),
        facing: angle,
        radius: kPlayerSize / 2 + w.reach + 14,
        color: w.rarity.color,
      ));
    }

    // Thân người hơi nhún theo đòn đánh
    add(
      ScaleEffect.by(
        Vector2.all(1.07),
        EffectController(duration: 0.05, reverseDuration: 0.08),
      ),
    );

    onPunch?.call(punchPoint, w.hitRadius);
  }

  // ---------------- RENDER ----------------

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final r = size.x / 2;

    canvas.drawCircle(c, r, _body);
    canvas.drawCircle(c, r, _outline);

    for (final dy in [-9.0, 9.0]) {
      canvas.drawCircle(Offset(c.dx + 10, c.dy + dy), 5, _eye);
      canvas.drawCircle(Offset(c.dx + 12, c.dy + dy), 2.5, _pupil);
    }
        if (isFlashing) {
      canvas.drawCircle(c, r, Paint()..color = const Color(0x88FF3B30));
    }
  }
}