import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Стеклянный материал (раздел 11.2): browser-CSS-приближение — размытие,
/// полупрозрачность и световой край. Это не запущенные Flutter-библиотеки
/// liquid glass, а допустимая основа для прототипа интерфейса.
///
/// Стекло используется у навигационной капсулы, кнопки добавления, шторки
/// серверов и небольших панелей управления. Текст и цифры остаются резкими.
class GlassCapsule extends StatelessWidget {
  const GlassCapsule({
    super.key,
    required this.child,
    this.enabled = true,
    this.radius = const BorderRadius.all(Radius.circular(28)),
    this.blur = 22,
    this.tintAlpha,
    this.border = true,
    this.padding,
  });

  final Widget child;
  final bool enabled;
  final BorderRadius radius;
  final double blur;
  final double? tintAlpha;
  final bool border;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final alpha = tintAlpha ?? (dark ? 0.55 : 0.66);

    final content = padding != null ? Padding(padding: padding!, child: child) : child;

    if (!enabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: radius,
          border: border ? Border.all(color: colors.border) : null,
        ),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (dark ? colors.surface1 : Colors.white).withValues(alpha: alpha),
            borderRadius: radius,
            border: border
                ? Border.fromBorderSide(
                    BorderSide(
                      color: (dark ? colors.primaryBright : Colors.white)
                          .withValues(alpha: dark ? 0.14 : 0.7),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
