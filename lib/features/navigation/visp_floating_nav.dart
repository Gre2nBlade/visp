import 'package:flutter/material.dart';

import '../../core/feedback/haptics.dart';
import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/visp_glass.dart';
import '../../state/preferences.dart';
import 'nav_destination.dart';

/// Плавающий навигационный бар: стеклянная пилюля с вкладками и отдельной
/// круглой кнопкой «+».
///
/// Активная вкладка выделяется подложкой-пилюлей, которая плавно переезжает
/// между позициями. Вокруг иконки отдельной рамки нет: прямоугольник вокруг
/// иконки дрожал визуально и дублировал подложку. Состав вкладок зависит от
/// установленных плагинов и закрепления Studio, а не фиксируется как четыре.
class VispFloatingNav extends StatelessWidget {
  const VispFloatingNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
    required this.glassMode,
    this.showLabels = true,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  /// Режим стекла: без стекла или обычное (раздел 11.2).
  final GlassMode glassMode;

  /// Показывать ли подписи вкладок. Выключается в настройках тем.
  final bool showLabels;

  /// Высота задаётся явно: без неё Row внутри Stack получал бы неограниченную
  // высоту и бар растягивался на весь экран. Без подписей панель ниже, и
  // иконка остаётся той же — меняется только плотность, а не размер цели.
  static const _barHeightWithLabels = 68.0;
  static const _barHeightIconsOnly = 58.0;
  static const _barPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final barHeight =
        showLabels ? _barHeightWithLabels : _barHeightIconsOnly;
    // Полукруглая пилюля: радиус равен половине внутренней высоты, поэтому
    // торцы смыкаются в круг, а не в скруглённый прямоугольник.
    final capsuleRadius = (barHeight / 2) - _barPadding;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.l,
          AppSpacing.s,
        ),
        child: SizedBox(
          // Фиксируем высоту всего бара: кнопка «+» задаёт её снизу,
          // капсула вкладок растягивается по ней.
          height: barHeight,
          child: Row(
            children: [
              Expanded(
                child: VispGlassCapsule(
                  enabled: glassMode != GlassMode.none,
                  radius: capsuleRadius,
                  padding: const EdgeInsets.all(_barPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth =
                          constraints.maxWidth / destinations.length;
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            left: currentIndex * tabWidth + 3,
                            top: 3,
                            bottom: 3,
                            width: tabWidth - 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    colors.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  showLabels ? 22 : capsuleRadius - 3,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              destinations.length,
                              (i) {
                                final d = destinations[i];
                                final selected = i == currentIndex;
                                return Expanded(
                                  child: _NavTab(
                                    destination: d,
                                    selected: selected,
                                    showLabel: showLabels,
                                    onTap: () {
                                      if (i == currentIndex) return;
                                      Haptics.light(context);
                                      onTap(i);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s + 2),
              _AddButton(glassMode: glassMode, onTap: onAdd),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка сама по себе: своей рамки и заливки у неё нет.
              // Выделение держит подложка-пилюля позади всей вкладки плюс
              // заливка глифа и подпись, поэтому рамка вокруг иконки была
              // вторым, конкурирующим средством выделения.
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                scale: selected ? 1.12 : 1,
                child: VispIcon(
                  destination.icon,
                  size: 24,
                  filled: selected,
                  color: selected ? colors.primary : colors.mutedForeground,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: AppSpacing.xs - 1),
                // Подпись не должна ни переноситься по букве, ни обрезаться:
                // при нехватке места она сжимается целиком.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.badge.copyWith(
                      fontSize: 11,
                      height: 1.1,
                      color: selected
                          ? colors.primary
                          : colors.mutedForeground,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.glassMode, required this.onTap});

  final GlassMode glassMode;
  final VoidCallback onTap;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Semantics(
      button: true,
      label: 'Добавить подключение',
      // Круглая стеклянная кнопка: спека 11.2 относит кнопку добавления
      // к навигационному слою, где стекло и живёт.
      child: VispGlass(
        enabled: glassMode != GlassMode.none,
        radius: _size / 2,
        distortion: 0.1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            Haptics.medium(context);
            onTap();
          },
          child: SizedBox(
            width: _size,
            height: _size,
            child: Center(
              child: VispIcon(
                VispIcons.plus,
                size: 24,
                color: colors.primary,
                weight: 700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
