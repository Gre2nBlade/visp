import 'package:flutter/material.dart';

import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum ChipTone {
  /// Нейтральная подпись: приглушённая заливка и вторичный текст.
  neutral,

  /// Акцентное состояние: янтарный, как выбранный элемент в Amnezia.
  accent,

  /// Предупреждение: жёлтый.
  warning,

  /// Ошибка: красный.
  danger,

  /// Информация: вторичный тон, без кричащего цвета.
  info,

  /// Beta-канал.
  beta,
}

/// Чип статуса, протокола или канала в стиле Amnezia.
///
/// Тонкие, радиус 8, текст 11 px. Чип никогда не заменяет поясняющий
/// текст: состояние передаётся иконкой, цветом и подписью одновременно.
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
        fg = colors.mutedForeground;
        bg = colors.muted;
      case ChipTone.accent:
        fg = colors.primary;
        bg = colors.primary.withValues(alpha: 0.12);
        leading = leading ?? VispIcons.checkCircle;
      case ChipTone.warning:
        fg = colors.warning;
        bg = colors.warning.withValues(alpha: 0.12);
        leading = leading ?? VispIcons.warning;
      case ChipTone.danger:
        fg = colors.destructive;
        bg = colors.destructive.withValues(alpha: 0.12);
        leading = leading ?? VispIcons.alert;
      case ChipTone.info:
        fg = colors.mutedForeground;
        bg = colors.muted;
        leading = leading ?? VispIcons.info;
      case ChipTone.beta:
        fg = colors.primary;
        bg = colors.muted;
        leading = leading ?? VispIcons.flask;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: selected ? Border.all(color: fg, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs + 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: VispIcon(leading, size: 13, color: fg),
            ),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}