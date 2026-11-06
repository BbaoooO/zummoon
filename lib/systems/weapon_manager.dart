import 'package:flutter/foundation.dart';

import '../core/weapon.dart';

enum WeaponAddResult { added, replaced, duplicate }

/// Quản lý túi vũ khí của Player. ValueNotifier để UI tự cập nhật.
class WeaponManager {
  static const int maxSlots = 4; // ô 0 luôn là Tay không

  final ValueNotifier<List<WeaponType>> inventory =
      ValueNotifier([WeaponType.fist]);
  final ValueNotifier<int> equippedIndex = ValueNotifier(0);

  WeaponType get current => inventory.value[equippedIndex.value];

  /// Thêm vũ khí mới và tự trang bị luôn.
  WeaponAddResult add(WeaponType w) {
    final inv = inventory.value;
    if (inv.contains(w)) return WeaponAddResult.duplicate;

    final list = [...inv];
    if (list.length < maxSlots) {
      list.add(w);
      inventory.value = list;
      equippedIndex.value = list.length - 1;
      return WeaponAddResult.added;
    }

    // Túi đầy: thay vũ khí đang cầm (nếu đang cầm Tay không thì thay ô 1)
    final idx = equippedIndex.value == 0 ? 1 : equippedIndex.value;
    list[idx] = w;
    inventory.value = list;
    equippedIndex.value = idx;
    return WeaponAddResult.replaced;
  }

  void equip(int index) {
    if (index < 0 || index >= inventory.value.length) return;
    equippedIndex.value = index;
  }

  void cycle() => equip((equippedIndex.value + 1) % inventory.value.length);

  void reset() {
    inventory.value = [WeaponType.fist];
    equippedIndex.value = 0;
  }
}