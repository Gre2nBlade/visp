import 'package:flutter/painting.dart';

/// Типографика Visp в духе Amnezia Client.
///
/// Amnezia использует PT Root UI VF — гротеск с кириллицей, веса 400–700.
/// Здесь та же логика на системном шрифте: система даёт кириллицу без
/// доставки ассета, а веса повторяют клиентские (400 тело, 700 заголовки).
/// Шкала размеров сжата внизу, как в оригинале: 11 / 12 / 13 / 14 / 16 / 18 /
/// 20 / 30 / 36.
class AppTextStyles {
  AppTextStyles._();

  /// Крупный заголовок экрана (36 в оригинале).
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -1.0,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.4,
  );

  /// Заголовок с усиленным начертанием.
  static const TextStyle h2Strong = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  /// Подпись кнопки в оригинале — 16 / 600.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Вторичный текст, описания серверов.
  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  /// Мелкая подпись 13 px, как LabelTextType.
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.23,
    letterSpacing: 0.02,
  );

  /// Подпись 11 px — бейджи и чипы (BadgeTextType).
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Моноширинный стиль для адресов, портов и ключей.
  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.43,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Табулярные цифры: скорость, пинг, лимиты, время сессии.
  static const TextStyle tabular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle tabularLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}