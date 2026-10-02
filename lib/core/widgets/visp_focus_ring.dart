import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Видимое кольцо фокуса для плоских поверхностей.
///
/// В Amnezia фокус — это 1 px рамка плюс смена цвета заливки, а не жирное
/// кольцо снаружи. Здесь: акцентная рамка толщиной 1 px снаружи и сдвиг
/// содержимого на 2 px, чтобы рамка не съедала площадь контрола.
class VispFocusRing extends StatelessWidget {
  const VispFocusRing({
    super.key,
    required this.child,
    this.borderRadius,
    this.gap,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final br = borderRadius ?? AppRadius.sAll;
    final g = gap ?? AppFocusRing.gap;

    return Focus(
      child: Builder(
        builder: (context) {
          final focusNode = Focus.of(context);
          final focused = focusNode.hasFocus || focusNode.hasPrimaryFocus;
          return Container(
            padding: EdgeInsets.all(focused ? g : 0),
            decoration: BoxDecoration(
              borderRadius: br.add(BorderRadius.circular(focused ? g : 0)),
              border: focused
                  ? Border.all(color: colors.ring, width: AppFocusRing.width)
                  : null,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
