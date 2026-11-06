import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../components/vfx/damage_popup.dart';
import '../../game/zummoon_game.dart';

final Paint _barBack = Paint()..color = const Color(0xAA000000);
final Paint _barFill = Paint();

/// Mixin dùng chung cho mọi thứ có máu: Tree, Rock, House (M2),
/// Crate (M3), Turret/Fence (M4), Zombie (M5).
///
/// QUY ƯỚC: mọi component dùng mixin này nên có anchor = center.
mixin Damageable on PositionComponent {
  double maxHp = 1;
  double hp = 1;
  bool isDead = false;

  /// Bán kính vùng nhận đòn (so với tâm component)
  double get hitRadius => size.x * 0.45;

  /// Người chơi có đấm được vật này không? (House = false)
  bool get punchable => true;

  /// Có bị đẩy lùi khi trúng đòn không? (Zombie = true)
  bool get canKnockback => false;

  /// Có phải kẻ địch không? Turret chỉ bắn những vật có isEnemy = true.
  /// (Zombie ở Module 5 sẽ ghi đè thành true)
  bool get isEnemy => false;

  double _flash = 0;
  bool _shaking = false;
  ZummoonGame? _dmgGame;

  bool get isFlashing => _flash > 0;
  double get hpRatio => (hp / maxHp).clamp(0.0, 1.0).toDouble();

  void initHp(double value) {
    maxHp = value;
    hp = value;
  }

  // ---------- Đăng ký với game để Player tìm được mục tiêu ----------
  @override
  void onMount() {
    super.onMount();
    _dmgGame = findGame() as ZummoonGame?;
    _dmgGame?.damageables.add(this);
  }

  @override
  void onRemove() {
    _dmgGame?.damageables.remove(this);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash -= dt;
  }

  // ---------- Sát thương ----------
  void takeDamage(double amount, {Vector2? from}) {
    if (isDead) return;

    hp = (hp - amount).clamp(0.0, maxHp).toDouble();
    _flash = 0.1;

    _spawnPopup('${amount.round()}', Colors.white);
    shake();

    if (canKnockback && from != null) {
      final dir = position - from;
      if (!dir.isZero()) knockback(dir.normalized(), 18);
    }

    if (hp <= 0) {
      isDead = true;
      onDeath();
    }
  }

  void heal(double amount) {
    if (isDead) return;
    hp = (hp + amount).clamp(0.0, maxHp).toDouble();
    _spawnPopup('+${amount.round()}', const Color(0xFF4CD964));
  }

  /// Ghi đè ở từng class để rớt đồ, hiệu ứng chết...
  void onDeath() {
    removeFromParent();
  }

  // ---------- Hiệu ứng ----------

  /// Rung qua lại (tổng dịch chuyển = 0 nên không bị lệch vị trí)
  void shake({double amplitude = 5}) {
    if (_shaking) return;
    _shaking = true;
    add(
      SequenceEffect(
        [
          MoveEffect.by(Vector2(amplitude, 0), EffectController(duration: 0.04)),
          MoveEffect.by(
              Vector2(-amplitude * 2, 0), EffectController(duration: 0.07)),
          MoveEffect.by(Vector2(amplitude, 0), EffectController(duration: 0.04)),
        ],
        onComplete: () => _shaking = false,
      ),
    );
  }

  void knockback(Vector2 direction, double force) {
    add(
      MoveEffect.by(
        direction * force,
        EffectController(duration: 0.12, curve: Curves.easeOut),
      ),
    );
  }

  /// Xuất hiện bằng cách phình to từ 0 -> 1 (nảy)
  void popIn() {
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.45, curve: Curves.elasticOut),
      ),
    );
  }

  void _spawnPopup(String text, Color color) {
    parent?.add(
      DamagePopup(
        text,
        at: position + Vector2(0, -hitRadius),
        color: color,
      ),
    );
  }

  /// Vẽ thanh máu (toạ độ cục bộ của component)
  void renderHpBar(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(4)),
      _barBack,
    );
    final r = hpRatio;
    _barFill.color = r > 0.5
        ? const Color(0xFF4CD964)
        : r > 0.25
            ? const Color(0xFFFFCC00)
            : const Color(0xFFFF3B30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, rect.width * r, rect.height),
        const Radius.circular(3),
      ),
      _barFill,
    );
  }
}
/// Dùng cho biến kiểu Solid / Object (Dart không tự promote sang Damageable)
bool isDeadObject(Object? o) => o is Damageable && o.isDead;