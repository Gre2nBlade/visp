import 'package:flutter/material.dart';

import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/strings.dart';
import '../../connection/models/connection_models.dart';

/// Кнопка фильтра и шторка со всеми фильтрами.
///
/// Раньше фильтры лежали горизонтальной лентой из отдельных чипов. Список
/// протоколов растёт вместе с импортом, поэтому лента могла стать шире
/// экрана и увести полезную подпись за край. Теперь на её месте одна
/// компактная кнопка с центрированным текстом, а полный список живёт в
/// шторке.
///
/// Состояние не своё: [protocolFilter] и [readyOnly] читаются из [AppState],
/// поэтому вкладка «Серверы» и шторка на главном экране показывают одно и
/// то же и меняют один и тот же список.
class ServerFilterButton extends StatelessWidget {
  const ServerFilterButton({
    super.key,
    required this.protocolFilter,
    required this.readyOnly,
    required this.protocols,
    required this.onProtocolChanged,
    required this.onReadyOnlyChanged,
    required this.onClear,
  });

  /// Протоколы, реально встречающиеся в списке.
  ///
  /// Шторке на главном экране и вкладке «Серверы» нужен один и тот же
  /// список, иначе фильтр предлагал бы протоколы, которых нет в данных.
  static List<Protocol> availableProtocols(List<ServerHost> hosts) {
    final set = <Protocol>{};
    for (final host in hosts) {
      for (final profile in host.profiles) {
        set.add(profile.protocol);
      }
    }
    final list = set.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }

  final Protocol? protocolFilter;
  final bool readyOnly;
  final List<Protocol> protocols;
  final ValueChanged<Protocol?> onProtocolChanged;
  final ValueChanged<bool> onReadyOnlyChanged;
  final VoidCallback onClear;

  /// Короткая подпись на кнопке: активные фильтры, иначе «Фильтр».
  String _summary(BuildContext context) {
    final s = context.s;
    if (protocolFilter == null && !readyOnly) return s.filter;
    if (protocolFilter != null && readyOnly) {
      return '${protocolFilter!.displayName} · ${s.filterReadyShort}';
    }
    return protocolFilter?.displayName ?? s.filterReady;
  }

  bool get _active => protocolFilter != null || readyOnly;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return Semantics(
      button: true,
      label: '${context.s.filter}: ${_summary(context)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSheet(context),
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            decoration: BoxDecoration(
              color: _active ? colors.muted : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.s),
              border: Border.all(
                color: _active ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VispIcon(
                  VispIcons.search,
                  size: 15,
                  color: _active ? colors.primary : colors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                // Подпись фильтра центрируется внутри кнопки: при разной
                // длине названий протокол�� текст не «прыгал» влево-вправо.
                Flexible(
                  child: Text(
                    _summary(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.badge.copyWith(
                      color:
                          _active ? colors.primary : colors.foreground,
                    ),
                  ),
                ),
                if (_active) ...[
                  const SizedBox(width: AppSpacing.xs),
                  VispIcon(
                    VispIcons.close,
                    size: 14,
                    color: colors.mutedForeground,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final s = context.s;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: SemanticColors.of(sheetContext).card,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.filter, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  s.filterHint,
                  style: AppTextStyles.label.copyWith(
                    color: SemanticColors.of(sheetContext).mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _FilterRow(
                        label: s.all,
                        selected: protocolFilter == null && !readyOnly,
                        onTap: () {
                          onClear();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                      _FilterRow(
                        label: s.filterReady,
                        detail: s.filterReadyDesc,
                        selected: readyOnly && protocolFilter == null,
                        onTap: () {
                          onReadyOnlyChanged(!readyOnly);
                        },
                      ),
                      const Divider(height: AppSpacing.l),
                      for (final protocol in protocols)
                        _FilterRow(
                          label: protocol.displayName,
                          detail: protocol.description,
                          selected: protocolFilter == protocol,
                          onTap: () {
                            onProtocolChanged(
                              protocolFilter == protocol ? null : protocol,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Align(
                  alignment: Alignment.centerRight,
                  child: VispFilterDoneButton(
                    label: s.done,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: Row(
              // Иконка выравнивается по заголовку строки, а не по центру
              // блока: у протоколов описание в две строки, и по центру иконка
              // уезжала под первую строку текста.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: VispIcon(
                    selected ? VispIcons.checkCircle : VispIcons.info,
                    size: 18,
                    filled: selected,
                    color: selected ? colors.primary : colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: selected
                              ? colors.primary
                              : colors.foreground,
                        ),
                      ),
                      if (detail != null)
                        Text(
                          detail!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VispFilterDoneButton extends StatelessWidget {
  const VispFilterDoneButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: colors.primaryForeground,
            ),
          ),
        ),
      ),
    );
  }
}