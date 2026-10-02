import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Карточка Visp в духе Amnezia Client.
///
/// Плоская поверхность без тени: глубину создаёт волосяная рамка в 1 px,
/// а базовый радиус 16. Карточка не вкладывается в карточку — для вложенных
/// элементов радиус считается через [AppNestedRadius], иначе вложенные
/// углы выглядят зажатыми.
class VispCard extends StatelessWidget {
  const VispCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? radius;

  /// Выбранное состояние: рамка переходит в акцентную.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final br = radius ?? AppRadius.sAll;

    final content = Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
      child: child,
    );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: br,
        border: Border.all(
          color: selected ? colors.primary : colors.border,
        ),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: br,
                hoverColor: colors.surfaceHover,
                splashColor: colors.accent,
                child: content,
              ),
            ),
    );

    if (margin != null) return Padding(padding: margin!, child: surface);
    return surface;
  }
}