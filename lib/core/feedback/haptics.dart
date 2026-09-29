import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// Сила тактильной отдачи (раздел «Тактильная отдача» настроек).
enum HapticStrength { auto, minimal, off }

/// Сервис тактильной отдачи.
///
/// Настройка применяется к навигации, переключателям и подтверждению опасных
/// действий. Reduced-motion и системный режим без вибрации имеют приоритет —
/// на платформе без haptic API взаимодействие остаётся тихим и рабочим.
class Haptics {
  Haptics._();

  static HapticStrength strength = HapticStrength.auto;

  /// light impact — переключение вкладок навигации.
  static void light(BuildContext? context) {
    _guard(context, () => HapticFeedback.lightImpact());
  }

  /// medium impact — действие «+» и деструктивные подтверждения.
  static void medium(BuildContext? context) {
    _guard(context, () => HapticFeedback.mediumImpact());
  }

  /// notification error — ошибки и отказы.
  static void error(BuildContext? context) {
    _guard(context, () => HapticFeedback.heavyImpact());
  }

  /// selection — переключатели и мелкий выбор.
  static void selection(BuildContext? context) {
    _guard(context, () => HapticFeedback.selectionClick());
  }

  static void _guard(BuildContext? context, VoidCallback perform) {
    if (strength == HapticStrength.off) return;
    if (context != null) {
      final mq = MediaQuery.maybeOf(context);
      if (mq != null && (mq.disableAnimations || mq.accessibleNavigation)) return;
    }
    perform();
  }
}
