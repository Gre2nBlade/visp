import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Карточка Visp: одна поверхность для одного решения, без карточек в карточках.
/// Вторичные строки отделяются разделителем.
class VispCard extends StatelessWidget {
  const VispCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final br = radius ?? AppRadius.lAll;

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
        color: colors.surface1,
        borderRadius: br,
        border: Border.all(color: colors.border),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: br,
                child: content,
              ),
            ),
    );

    return margin != null ? Padding(padding: margin!, child: surface) : surface;
  }
}
