import 'package:flutter/material.dart';

import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum ChipTone {
  neutral,
  accent,
  warning,
  danger,
  info,
  beta,
}

/// Чип статуса/протокола/канала/разрешения.
///
/// Чипы никогда не заменяют поясняющий текст: статус передаётся
/// иконкой, цветом и текстом одновременно.
class VispChip extends StatelessWidget {
  const VispChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
    this.icon,
    this.selected = false,
  });

  final String label;
  final ChipTone tone;
  final VispIcons? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    Color fg;
    Color bg;
    VispIcons? leading = icon;
    switch (tone) {
      case ChipTone.neutral:
        fg = colors.textSecondary;
        bg = colors.surface2;
      case ChipTone.accent:
        fg = colors.primary;
        bg = colors.primary.withValues(alpha: 0.12);
        leading = leading ?? VispIcons.checkCircle;
      case ChipTone.warning:
        fg = colors.warning;
        bg = colors.warning.withValues(alpha: 0.14);
        leading = leading ?? VispIcons.warning;
      case ChipTone.danger:
        fg = colors.danger;
        bg = colors.danger.withValues(alpha: 0.14);
        leading = leading ?? VispIcons.alert;
      case ChipTone.info:
        fg = colors.info;
        bg = colors.info.withValues(alpha: 0.14);
        leading = leading ?? VispIcons.info;
      case ChipTone.beta:
        fg = colors.info;
        bg = colors.info.withValues(alpha: 0.14);
        leading = leading ?? VispIcons.flask;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.s + 2),
        border: selected ? Border.all(color: fg, width: 1.2) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s + 2,
          vertical: AppSpacing.xs + 1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs + 1),
                child: VispIcon(leading, size: 13, color: fg),
              ),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
