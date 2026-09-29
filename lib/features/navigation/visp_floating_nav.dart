import 'package:flutter/material.dart';

import '../../core/feedback/haptics.dart';
import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_capsule.dart';
import 'nav_destination.dart';

/// Плавающий навигационный бар: стеклянная капсула с базовыми вкладками
/// и отдельной круглой кнопкой «+» (раздел 4.6).
///
/// Активная вкладка выделяется подложкой-пилюлей, которая плавно переезжает
/// между позициями. Состав вкладок зависит от установленных плагинов и
/// закрепления Studio, а не фиксируется как четыре.
class VispFloatingNav extends StatelessWidget {
  const VispFloatingNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
    required this.glass,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  final bool glass;

  static const _barHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.l,
          AppSpacing.s,
        ),
        child: Row(
          children: [
            Expanded(
              child: GlassCapsule(
                enabled: glass,
                radius: const BorderRadius.all(Radius.circular(_barHeight / 2)),
                padding: const EdgeInsets.all(6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth =
                        constraints.maxWidth / destinations.length;
                    return SizedBox(
                      height: _barHeight - 12,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            left: currentIndex * tabWidth + 3,
                            top: 3,
                            width: tabWidth - 6,
                            height: _barHeight - 18,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  (_barHeight - 18) / 2,
                                ),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(destinations.length, (i) {
                              final d = destinations[i];
                              final selected = i == currentIndex;
                              return Expanded(
                                child: _NavTab(
                                  destination: d,
                                  selected: selected,
                                  onTap: () {
                                    if (i == currentIndex) return;
                                    Haptics.light(context);
                                    onTap(i);
                                  },
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s + 2),
            _AddButton(glass: glass, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VispIcon(
                destination.icon,
                size: 22,
                color: selected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: AppTextStyles.small.copyWith(
                  fontSize: 10,
                  height: 1.0,
                  color: selected ? colors.primary : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.glass, required this.onTap});

  final bool glass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Semantics(
      button: true,
      label: 'Добавить подключение',
      child: GlassCapsule(
        enabled: glass,
        radius: const BorderRadius.all(Radius.circular(28)),
        padding: EdgeInsets.zero,
        child: Material(
          color: colors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Haptics.medium(context);
              onTap();
            },
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: VispIcon(
                  VispIcons.plus,
                  size: 24,
                  color: colors.background,
                  weight: 700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
