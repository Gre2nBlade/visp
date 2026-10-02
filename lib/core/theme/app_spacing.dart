import 'package:flutter/painting.dart';

/// Сетка отступов и радиусов Visp в духе Amnezia Client.
///
/// Анализ всех радиусов в исходниках Amnezia даёт: 16 — базовый для карточек,
/// кнопок, полей и шторок; 8 — для уведомлений и мелких чипов; 4 — точечно.
/// Интерфейс плоский, тени не используются: глубину создают волосяные рамки
/// в 1 px, поэтому роль `border` здесь обязательна.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Радиусы: 16 — основной, 8 — мелкие элементы, 22 — круглые кнопки.
class AppRadius {
  AppRadius._();

  /// Мелкие чипы и уведомления.
  static const double sm = 8;

  /// Базовый радиус: карточки, кнопки, поля, шторки.
  static const double s = 16;

  /// Увеличенные поверхности.
  static const double m = 22;

  /// Круглые кнопки и капсулы.
  static const double l = 30;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius sAll = BorderRadius.all(Radius.circular(s));
  static const BorderRadius mAll = BorderRadius.all(Radius.circular(m));
  static const BorderRadius lAll = BorderRadius.all(Radius.circular(l));
}

/// Высоты контролов. В Amnezia строка списка — 56 px, это и есть минимум.
class AppControlHeight {
  AppControlHeight._();

  static const double compact = 36;
  static const double regular = 48;
  static const double prominent = 56;
}

/// Концентрические радиусы: внешний = внутренний + отступ.
///
/// Плоские вложенные поверхности с одинаковым радиусом читаются «зажато»,
/// поэтому у дочерней всегда радиус меньше на величину отступа.
class AppNestedRadius {
  AppNestedRadius._();

  static BorderRadius child(double outer, double padding) =>
      BorderRadius.circular((outer - padding).clamp(0.0, outer));
}

/// Кольцо фокуса: 1 px рамка плюс подсветка акцентом.
class AppFocusRing {
  AppFocusRing._();

  static const double width = 1;
  static const double gap = 2;
}