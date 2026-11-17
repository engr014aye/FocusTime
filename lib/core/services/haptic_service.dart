import 'package:flutter/services.dart';

class HapticService {
  static final HapticService instance = HapticService._internal();
  bool isEnabled = true;

  HapticService._internal();

  void light() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void selection() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  void success() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isEnabled) HapticFeedback.lightImpact();
    });
  }
}
