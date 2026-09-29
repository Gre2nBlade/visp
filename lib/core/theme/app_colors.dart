import 'package:flutter/material.dart';

/// Семантические цвета Visp.
///
/// Тёмная и светлая ветки содержат одни и те же смысловые токены из DESIGN.md,
/// чтобы цвет никогда не был единственным носителем состояния.
class SemanticColors {
  final Color background;
  final Color surface1;
  final Color surface2;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentBright;
  final Color warning;
  final Color danger;
  final Color info;

  /// Спокойный шалфейный цвет подключённого Blup Visp (#6FBF93, раздел 4.1.3).
  final Color blupConnected;

  /// Терракотовый акцент ошибки (#E57B6E, раздел 4.1.5).
  final Color blupError;

  /// Приглушённый зелёно-графитовый цвет выключенного Blup Visp.
  final Color blupIdle;

  const SemanticColors._({
    required this.background,
    required this.surface1,
    required this.surface2,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentBright,
    required this.warning,
    required this.danger,
    required this.info,
    required this.blupConnected,
    required this.blupError,
    required this.blupIdle,
  });

  static const dark = SemanticColors._(
    background: Color(0xFF0B0D0F),
    surface1: Color(0xFF12161A),
    surface2: Color(0xFF191F24),
    border: Color(0xFF2B343B),
    textPrimary: Color(0xFFF3F6F4),
    textSecondary: Color(0xFFAAB6B0),
    accent: Color(0xFF8FD3AA),
    accentBright: Color(0xFFB6F0C9),
    warning: Color(0xFFE7C46A),
    danger: Color(0xFFEF8A7D),
    info: Color(0xFF82B8E8),
    blupConnected: Color(0xFF6FBF93),
    blupError: Color(0xFFE57B6E),
    blupIdle: Color(0xFF4A5A4F),
  );

  /// Светлая тема из описания 11.2: фон #F3F7F4, поверхности #FFFFFF и #EBF1EC,
  /// текст #17211B / #5A685F, акцент #3E9C6E.
  static const light = SemanticColors._(
    background: Color(0xFFF3F7F4),
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFEBF1EC),
    border: Color(0xFFD2DCD4),
    textPrimary: Color(0xFF17211B),
    textSecondary: Color(0xFF5A685F),
    accent: Color(0xFF3E9C6E),
    accentBright: Color(0xFF2E7C56),
    warning: Color(0xFF8A6A14),
    danger: Color(0xFFB93F31),
    info: Color(0xFF2D5F96),
    blupConnected: Color(0xFF3E9C6E),
    blupError: Color(0xFFC4503F),
    blupIdle: Color(0xFF7C8C80),
  );

  static SemanticColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
