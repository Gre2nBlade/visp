import 'package:flutter/material.dart';

/// Семантические цвета Visp в ролях shadcn/ui (DESIGN.md «Tokens»).
///
/// Каждый токен имеет тёмное и светлое значение; компоненты читают роли, а не
/// сырые цвета. Тёмная ветка — shadcn slate, роль primary — брендовый зелёный
/// («подключено»). Цвет никогда не бывает единственным носителем состояния.
class SemanticColors {
  // --- shadcn semantic roles ---------------------------------------------

  /// Фон приложения (canvas).
  final Color background;

  /// Основной текст на фоне.
  final Color foreground;

  /// Поверхность карточек и групп списка.
  final Color card;

  /// Текст на карточке.
  final Color cardForeground;

  /// Поверхность меню/шторок.
  final Color popover;

  /// Текст на popover.
  final Color popoverForeground;

  /// Главный CTA и выбранный элемент (брендовый зелёный).
  final Color primary;

  /// Текст/иконки на primary.
  final Color primaryForeground;

  /// Более светлый оттенок primary для свечения и градиентов.
  final Color primaryBright;

  /// Вторичные кнопки и приглушённые блоки.
  final Color secondary;

  /// Текст на secondary.
  final Color secondaryForeground;

  /// Неактивные элементы, отключённые заливки.
  final Color muted;

  /// Вторичный текст и подписи.
  final Color mutedForeground;

  /// Заливка hover/press.
  final Color accent;

  /// Текст на accent.
  final Color accentForeground;

  /// Деструктивные поверхности.
  final Color destructive;

  /// Текст на destructive.
  final Color destructiveForeground;

  /// Все рамки и разделители (1 px).
  final Color border;

  /// Рамки полей ввода.
  final Color input;

  /// Кольцо фокуса (2 px).
  final Color ring;

  /// Предупреждения и beta-канал.
  final Color warning;

  /// Информационные чипы.
  final Color info;

  // --- спецификация Visp ---------------------------------------------------

  /// Спокойный шалфейный цвет подключённого Blup Visp (#6FBF93, раздел 4.1.3).
  final Color blupConnected;

  /// Терракотовый акцент ошибки (#E57B6E, раздел 4.1.5).
  final Color blupError;

  /// Приглушённый зелёно-графитовый цвет выключенного Blup Visp.
  final Color blupIdle;

  const SemanticColors._({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.primaryBright,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.warning,
    required this.info,
    required this.blupConnected,
    required this.blupError,
    required this.blupIdle,
  });

  /// shadcn slate dark + брендовый зелёный primary.
  static const dark = SemanticColors._(
    background: Color(0xFF020617),
    foreground: Color(0xFFF8FAFC),
    card: Color(0xFF111827),
    cardForeground: Color(0xFFF8FAFC),
    popover: Color(0xFF111827),
    popoverForeground: Color(0xFFF8FAFC),
    primary: Color(0xFF22C55E),
    primaryForeground: Color(0xFF052E16),
    primaryBright: Color(0xFF4ADE80),
    secondary: Color(0xFF1E293B),
    secondaryForeground: Color(0xFFF8FAFC),
    muted: Color(0xFF1E293B),
    mutedForeground: Color(0xFF94A3B8),
    accent: Color(0xFF1E293B),
    accentForeground: Color(0xFFF8FAFC),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFCA5A5),
    border: Color(0xFF1E293B),
    input: Color(0xFF334155),
    ring: Color(0xFF22C55E),
    warning: Color(0xFFE7C46A),
    info: Color(0xFF82B8E8),
    blupConnected: Color(0xFF6FBF93),
    blupError: Color(0xFFE57B6E),
    blupIdle: Color(0xFF4A5A4F),
  );

  /// Светлая тема из DESIGN.md: canvas #F8FAFC, карточки #FFFFFF,
  /// secondary/muted #F1F5F9, текст #020617, primary #16A34A.
  static const light = SemanticColors._(
    background: Color(0xFFF8FAFC),
    foreground: Color(0xFF020617),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF020617),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF020617),
    primary: Color(0xFF16A34A),
    primaryForeground: Color(0xFFFFFFFF),
    primaryBright: Color(0xFF15803D),
    secondary: Color(0xFFF1F5F9),
    secondaryForeground: Color(0xFF0F172A),
    muted: Color(0xFFF1F5F9),
    mutedForeground: Color(0xFF475569),
    accent: Color(0xFFF1F5F9),
    accentForeground: Color(0xFF0F172A),
    destructive: Color(0xFFB93F31),
    destructiveForeground: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    input: Color(0xFFCBD5E1),
    ring: Color(0xFF16A34A),
    warning: Color(0xFF8A6A14),
    info: Color(0xFF2D5F96),
    blupConnected: Color(0xFF3E9C6E),
    blupError: Color(0xFFC4503F),
    blupIdle: Color(0xFF7C8C80),
  );

  static SemanticColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // --- Совместимость со старыми именами токенов -----------------------------
  // Мост для постепенной миграции компонентов на shadcn-имена.

  Color get surface1 => card;
  Color get surface2 => secondary;
  Color get textPrimary => foreground;
  Color get textSecondary => mutedForeground;
  Color get danger => destructive;
}
