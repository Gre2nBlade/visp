import 'package:flutter/material.dart';

import '../../../core/feedback/haptics.dart';
import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/visp_glass.dart';
import '../../../state/app_state.dart';
import '../../../state/preferences.dart';

/// Выбор материала поверхностей: обычный или стекло (раздел 11.2).
///
/// Каждый вариант показывает живой образец навигационной капсулы: выбор
/// виден сразу, без перезапуска приложения.
class GlassModePicker extends StatelessWidget {
  const GlassModePicker({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mode in GlassMode.values) ...[
          _GlassModeTile(
            mode: mode,
            selected: state.glassMode == mode,
            onTap: () {
              Haptics.selection(context);
              state.setGlassMode(mode);
            },
          ),
          if (mode != GlassMode.values.last)
            const SizedBox(height: AppSpacing.s),
        ],
        const SizedBox(height: AppSpacing.m),
        // Образец материала в текущем режиме.
        VispGlassCapsule(
          enabled: state.glassMode != GlassMode.none,
          radius: 22,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VispIcon(VispIcons.shieldCheck, size: 16, color: colors.primary),
              const SizedBox(width: AppSpacing.s),
              Text(
                state.glassMode == GlassMode.none ? 'Обычный материал' : 'Стекло',
                style: AppTextStyles.small.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassModeTile extends StatelessWidget {
  const _GlassModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final GlassMode mode;
  final bool selected;
  final VoidCallback onTap;

  static const Map<GlassMode, String> _descriptions = {
    GlassMode.none: 'Без преломления и размытия. Экономнее по ресурсам.',
    GlassMode.regular: 'Преломление фона с инерцией навигации и кнопки «+».',
  };

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            // Отметка выбранного: цвет и иконка, а не только цвет рамки.
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.mAll,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            children: [
              VispIcon(
                selected ? VispIcons.checkCircle : VispIcons.info,
                size: 18,
                filled: selected,
                color: selected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: AppTextStyles.body.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      _descriptions[mode] ?? '',
                      style: AppTextStyles.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}