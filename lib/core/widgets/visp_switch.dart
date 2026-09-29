import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Переключатель Visp: мгновенный визуальный отклик, haptic — по глобальной
/// настройке.
class VispSwitch extends StatelessWidget {
  const VispSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return Semantics(
      toggled: value,
      child: Switch(
        value: value,
        onChanged: onChanged == null
            ? null
            : (v) {
                Haptics.selection(context);
                onChanged!(v);
              },
        activeThumbColor: colors.primary,
        inactiveThumbColor: colors.textSecondary,
        inactiveTrackColor: colors.surface2,
        trackOutlineColor: WidgetStateProperty.all(colors.border),
        splashRadius: 20,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Сегментированный выбор из 2–3 вариантов (тёмная подложка-пилюля).
class VispSegmented<T> extends StatelessWidget {
  const VispSegmented({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
    this.labels,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final Map<T, String>? labels;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.s + 2),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((v) {
          final selected = v == value;
          return _Segment(
            label: labels?[v] ?? v.toString(),
            selected: selected,
            onTap: () {
              Haptics.selection(context);
              onChanged(v);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Material(
      color: selected ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s - 2,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.background : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
