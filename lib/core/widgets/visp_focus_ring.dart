import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Видимое кольцо фокуса: 2 px акцент на 3 px снаружи контрола (DESIGN.md).
class VispFocusRing extends StatelessWidget {
  const VispFocusRing({
    super.key,
    required this.child,
    this.radius,
    this.gap,
  });

  final Widget child;
  final BorderRadius? radius;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final br = radius ?? AppRadius.mAll;
    final g = gap ?? AppFocusRing.gap;

    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus ||
              Focus.of(context).hasPrimaryFocus;
          return Padding(
            padding: EdgeInsets.all(g),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: br.add(BorderRadius.circular(g + 1)),
                border: focused
                    ? Border.all(
                        color: colors.primary,
                        width: AppFocusRing.width,
                      )
                    : null,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
