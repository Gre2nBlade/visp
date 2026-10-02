import 'package:flutter/material.dart';

import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Строка списка Visp в стиле Amnezia Client.
///
/// Иконка 20 px, заголовок, однострочное описание, завершающее состояние.
/// Минимальная высота 56 px — это размер строки в Amnezia, и он же
/// достаточен для касания. Строка без рамки: группу рисует [VispListGroup].
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
    this.selected = false,
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

  /// Выбранная строка: заголовок переходит в акцент, как в Amnezia.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final titleColor = destructive
        ? colors.destructive
        : selected
            ? colors.primary
            : colors.foreground;

    final content = Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: VispIcon(
              icon!,
              size: 20,
              filled: selected,
              color: destructive
                  ? colors.destructive
                  : selected
                      ? colors.primary
                      : colors.mutedForeground,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(color: titleColor),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    description!,
                    maxLines: maxLinesDescription,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: colors.mutedForeground,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: colors.surfaceHover,
        splashColor: colors.accent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.s,
                ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Заголовок группы настроек: мелкая подпись с разрядкой, как в Amnezia.
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
        style: AppTextStyles.badge.copyWith(
          color: colors.mutedForeground,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Группа строк в одной плоской карточке с разделителями.
///
/// Радиус 16 и волосяная рамка — как у CardType в Amnezia. Строки внутри
/// рамок не имеют собственных: это плоская поверхность, а не набор карточек.
class VispListGroup extends StatelessWidget {
  const VispListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.sAll,
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
