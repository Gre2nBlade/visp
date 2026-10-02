import 'package:flutter/material.dart';

/// Палитра Visp в духе Amnezia Client.
///
/// Значения взяты из исходников Amnezia Client (client/ui/qml/Modules/
/// Style/AmneziaStyle.qml) — это не подбор на глаз:
///
/// ```text
/// midnightBlack  #0E0E11  фон приложения
/// onyxBlack      #1C1D21  карточки, панель вкладок, шторки
/// slateGray      #2C2D30  разделители и рамки 1 px
/// charcoalGray   #494B50  отключённые состояния
/// mutedGray      #878B91  вторичный текст
/// paleGray       #D7D8DB  основной текст, состояние «выключено»
/// goldenApricot  #FBB26A  акцент: подключено, выбрано, фокус, CTA
/// burntOrange     #A85809  нажатое и отключённое состояние акцента
/// vibrantGreen    #3FBF6B  успех
/// vibrantRed      #EB5757  ошибка
/// ```
///
/// Ключевое отличие от прежней темы: акцент — янтарный, а не зелёный.
/// Зелёный остался только для успеха. Интерфейс плоский: вместо теней
/// используются волосяные рамки в 1 px, поэтому роль `border` здесь
/// заметна, а `shadow` не применяется.
class SemanticColors {
  // --- Поверхности ---------------------------------------------------------

  /// Фон приложения.
  final Color background;

  /// Карточки, панель вкладок, шторки.
  final Color card;

  /// Поверхность под наведением и нажатием.
  final Color surfaceHover;

  final Color cardForeground;

  /// Всплывающие поверхности: шторки, меню.
  final Color popover;

  final Color popoverForeground;

  /// Приглушённый блок: чипы, отключённые элементы.
  final Color muted;

  // --- Текст ---------------------------------------------------------------

  /// Основной текст.
  final Color foreground;

  /// Вторичный текст и подписи.
  final Color mutedForeground;

  // --- Акцент --------------------------------------------------------------

  /// Янтарный акцент: подключено, выбранный элемент, фокус, главный CTA.
  final Color primary;

  /// Текст на акценте.
  final Color primaryForeground;

  /// Светлый оттенок акцента для свечения и градиентов.
  final Color primaryBright;

  /// Нажатое и отключённое состояние акцента.
  final Color primaryPressed;

  final Color secondary;
  final Color secondaryForeground;

  /// Заливка наведения и нажатия (отдельная от акцента).
  final Color accent;

  final Color accentForeground;

  // --- Границы -------------------------------------------------------------

  /// Разделители и рамки, 1 px.
  final Color border;

  /// Усиленная рамка: выбранное состояние, фокус поля.
  final Color borderStrong;

  /// Рамки полей ввода.
  final Color input;

  /// Кольцо фокуса.
  final Color ring;

  // --- Состояния -----------------------------------------------------------

  final Color destructive;
  final Color destructiveForeground;

  final Color warning;
  final Color info;

  /// Успех. В отличие от прежней темы, зелёный больше не акцент:
  /// он означает именно успех.
  final Color success;

  // --- Blup Visp ------------------------------------------------------------

  /// Фигура в состоянии «подключено» повторяет акцент.
  final Color blupConnected;

  /// Фигура в состоянии ошибки.
  final Color blupError;

  /// Фигура в покое.
  final Color blupIdle;

  /// Фигура при установке: тёмная дуга на акцентном кольце.
  final Color blupConnecting;

  const SemanticColors._({
    required this.background,
    required this.card,
    required this.surfaceHover,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.muted,
    required this.foreground,
    required this.mutedForeground,
    required this.primary,
    required this.primaryForeground,
    required this.primaryBright,
    required this.primaryPressed,
    required this.secondary,
    required this.secondaryForeground,
    required this.accent,
    required this.accentForeground,
    required this.border,
    required this.borderStrong,
    required this.input,
    required this.ring,
    required this.destructive,
    required this.destructiveForeground,
    required this.warning,
    required this.info,
    required this.success,
    required this.blupConnected,
    required this.blupError,
    required this.blupIdle,
    required this.blupConnecting,
  });

  /// Основная тёмная тема — как в Amnezia Client.
  static const dark = SemanticColors._(
    background: Color(0xFF0E0E11),
    card: Color(0xFF1C1D21),
    surfaceHover: Color(0xFF232327),
    cardForeground: Color(0xFFD7D8DB),
    popover: Color(0xFF1C1D21),
    popoverForeground: Color(0xFFD7D8DB),
    muted: Color(0xFF2C2D30),
    foreground: Color(0xFFD7D8DB),
    mutedForeground: Color(0xFF878B91),
    primary: Color(0xFFFBB26A),
    primaryForeground: Color(0xFF0E0E11),
    primaryBright: Color(0xFFFCCC9C),
    primaryPressed: Color(0xFFA85809),
    secondary: Color(0xFF2C2D30),
    secondaryForeground: Color(0xFFD7D8DB),
    accent: Color(0xFF2C2D30),
    accentForeground: Color(0xFFD7D8DB),
    border: Color(0xFF2C2D30),
    borderStrong: Color(0xFF494B50),
    input: Color(0xFF494B50),
    ring: Color(0xFFFBB26A),
    destructive: Color(0xFFEB5757),
    destructiveForeground: Color(0xFF0E0E11),
    warning: Color(0xFFEAB308),
    info: Color(0xFF878B91),
    success: Color(0xFF3FBF6B),
    blupConnected: Color(0xFFFBB26A),
    blupError: Color(0xFFEB5757),
    blupIdle: Color(0xFFD7D8DB),
    blupConnecting: Color(0xFF261E1A),
  );

  /// Светлая тема. В Amnezia Client её нет — приложение тёмное. Здесь она
  /// нужна потому, что Visp умеет следовать системной: те же роли,
  /// инвертированные значения, акцент затемнён для контраста на светлом.
  static const light = SemanticColors._(
    background: Color(0xFFF7F5F2),
    card: Color(0xFFFFFFFF),
    surfaceHover: Color(0xFFEFEDE9),
    cardForeground: Color(0xFF1C1D21),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF1C1D21),
    muted: Color(0xFFEBE8E3),
    foreground: Color(0xFF1C1D21),
    mutedForeground: Color(0xFF6B6B70),
    // Акцент затемнён до 5.2:1 на белом: в светлой теме янтарный используется
    // и как текст (подпись активной вкладки 11 px, выбранная строка), и как
    // заливка кнопки с белой подписью, поэтому должен проходить AA в обе стороны.
    // #B4701F давал 3.98:1 и не проходил ни там, ни там.
    primary: Color(0xFF9A5F14),
    primaryForeground: Color(0xFFFFFFFF),
    primaryBright: Color(0xFFD9963F),
    primaryPressed: Color(0xFF7A4A0F),
    secondary: Color(0xFFEBE8E3),
    secondaryForeground: Color(0xFF1C1D21),
    accent: Color(0xFFEBE8E3),
    accentForeground: Color(0xFF1C1D21),
    border: Color(0xFFE2DFDA),
    borderStrong: Color(0xFFC9C5BE),
    input: Color(0xFFC9C5BE),
    ring: Color(0xFF9A5F14),
    destructive: Color(0xFFC5322F),
    destructiveForeground: Color(0xFFFFFFFF),
    warning: Color(0xFF9A6B00),
    info: Color(0xFF5A5A60),
    success: Color(0xFF2E8B4F),
    blupConnected: Color(0xFFB4701F),
    blupError: Color(0xFFC5322F),
    blupIdle: Color(0xFF6B6B70),
    blupConnecting: Color(0xFFEFE0CE),
  );

  static SemanticColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // --- Совместимость со старыми именами токенов -----------------------------

  Color get surface1 => card;
  Color get surface2 => muted;
  Color get textPrimary => foreground;
  Color get textSecondary => mutedForeground;
  Color get danger => destructive;
}