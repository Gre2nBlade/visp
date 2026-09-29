import 'package:flutter/material.dart';

import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Строка списка Visp: иконка, заголовок, однострочное описание,
/// завершающее состояние/действие. Минимальная высота 52 px.
class VispListRow extends StatelessWidget {
  const VispListRow({
    super.key,
    required this.title,
    this.icon,
    this.description,
    this.trailing,
    this.onTap,
    this.onTrailingTap,
    this.trailingTooltip,
    this.destructive = false,
    this.padding,
    this.maxLinesDescription = 1,
  });

  final String title;
  final VispIcons? icon;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  final String? trailingTooltip;
  final bool destructive;
  final EdgeInsetsGeometry? padding;
  final int maxLinesDescription;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final titleColor =
        destructive ? colors.danger : colors.textPrimary;

    final content = Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: VispIcon(
              icon!,
              size: 20,
              color: destructive ? colors.danger : colors.textSecondary,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    description!,
                    maxLines: maxLinesDescription,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
        if (onTrailingTap != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: VispIconButton(
              icon: VispIcons.chevronRight,
              tooltip: trailingTooltip,
              onPressed: onTrailingTap!,
            ),
          ),
      ],
    );

    final minHeight = 52.0;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
          child: content,
        ),
      ),
    );
  }
}

/// Заголовок группы настроек/секции.
class VispSectionHeader extends StatelessWidget {
  const VispSectionHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.small.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Группа строк в одной карточке с разделителями между строками.
class VispListGroup extends StatelessWidget {
  const VispListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: AppRadius.lAll,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.l),
                child: Divider(height: 1, color: colors.border),
              ),
          ],
        ],
      ),
    );
  }
}
