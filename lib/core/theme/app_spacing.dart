import 'package:flutter/painting.dart';

/// Сетка отступов 4 px из DESIGN.md: общие промежутки 8, 12, 16, 24, 32.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Радиусы скруглений 8 / 12 / 16 / 24.
class AppRadius {
  AppRadius._();

  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  static const Radius sRadius = Radius.circular(s);
  static const Radius mRadius = Radius.circular(m);
  static const Radius lRadius = Radius.circular(l);
  static const Radius xlRadius = Radius.circular(xl);

  static const BorderRadius sAll = BorderRadius.all(sRadius);
  static const BorderRadius mAll = BorderRadius.all(mRadius);
  static const BorderRadius lAll = BorderRadius.all(lRadius);
  static const BorderRadius xlAll = BorderRadius.all(xlRadius);
}

/// Высоты контролов: 36 compact, 44 regular, 52 prominent.
class AppControlHeight {
  AppControlHeight._();

  static const double compact = 36;
  static const double regular = 44;
  static const double prominent = 52;
}

/// Кольцо фокуса: 2 px акцентного цвета на 3 px снаружи контрола.
class AppFocusRing {
  AppFocusRing._();

  static const double width = 2;
  static const double gap = 3;
}
