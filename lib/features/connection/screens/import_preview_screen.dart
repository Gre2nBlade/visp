import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/visp_button.dart';
import '../../../core/widgets/visp_card.dart';
import '../../../core/widgets/visp_chip.dart';
import '../../../core/widgets/visp_switch.dart';
import '../../../core/widgets/visp_toast.dart';
import '../../../l10n/strings.dart';
import '../../../state/app_state.dart';
import '../services/code_importer.dart';

/// Предварительный просмотр импорта (раздел 2.7).
///
/// Показывает название набора, источник, количество VPN-профилей и прокси,
/// требуемые модули и наличие правил маршрутизации. Можно выбрать нужные
/// записи; сворачивание не снимает отметки — здесь список плоский,
/// группировка по хостам появляется после добавления.
class ImportPreviewScreen extends StatefulWidget {
  const ImportPreviewScreen({
    super.key,
    required this.preview,
    required this.rawCode,
  });

  final ImportPreview preview;
  final String rawCode;

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  late List<PreviewEntry> _entries;
  String _rulesChoice = 'keep';
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _entries = widget.preview.entries
        .map((e) => e.copyWith(selected: true))
        .toList();
  }

  int get _selectedCount => _entries.where((e) => e.selected).length;

  void _toggleEntry(int index, bool value) {
    setState(() {
      _entries[index] = _entries[index].copyWith(selected: value);
    });
  }

  Future<void> _apply() async {
    if (_selectedCount == 0) {
      VispToast.showError(context, context.s.notChosen);
      return;
    }
    setState(() => _applying = true);
    final state = context.read<AppState>();
    final preview = ImportPreview(
      kind: widget.preview.kind,
      title: widget.preview.title,
      sourceLabel: widget.preview.sourceLabel,
      entries: _entries,
      hasRoutingRules: widget.preview.hasRoutingRules,
    );
    final added = state.applyImport(preview);

    // Прокси-записи требуют установленный плагин: предложить включить.
    final hasProxy = _entries.any((e) => e.isProxy && e.selected);
    if (hasProxy && !state.proxyInstalled) {
      VispToast.show(
        context,
        'Прокси для Telegram: установите плагин, чтобы добавить запись',
      );
    }
    setState(() => _applying = false);
    if (mounted) {
      VispToast.show(context, '${context.s.addedN}: $added');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.importPreview),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              children: [
                VispCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.preview.title, style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        '${s.source}: ${widget.preview.sourceLabel}',
                        style: AppTextStyles.small.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Wrap(
                        spacing: AppSpacing.s,
                        runSpacing: AppSpacing.s,
                        children: [
                          VispChip(
                            label:
                                'VPN: ${_entries.where((e) => !e.isProxy).length}',
                            tone: ChipTone.neutral,
                          ),
                          VispChip(
                            label:
                                'Прокси: ${_entries.where((e) => e.isProxy).length}',
                            tone: ChipTone.neutral,
                          ),
                          if (widget.preview.hasRoutingRules)
                            VispChip(
                              label: s.routingRules,
                              tone: ChipTone.info,
                            ),
                          if (_entries.any((e) => e.needsModule))
                            const VispChip(
                              label: 'Нужны модули',
                              tone: ChipTone.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  '${s.selected}: $_selectedCount',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.m),
                VispCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < _entries.length; i++) ...[
                        _PreviewEntryRow(
                          entry: _entries[i],
                          onChanged: (value) => _toggleEntry(i, value),
                        ),
                        if (i != _entries.length - 1) _divider(context),
                      ],
                    ],
                  ),
                ),
                if (widget.preview.hasRoutingRules) ...[
                  const SizedBox(height: AppSpacing.l),
                  _RoutingRulesCard(
                    choice: _rulesChoice,
                    onChanged: (v) => setState(() => _rulesChoice = v),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.l,
            ),
            child: VispButton(
              label: s.add,
              icon: VispIcons.check,
              expanded: true,
              loading: _applying,
              onPressed: _applying ? null : _apply,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }
}

class _PreviewEntryRow extends StatelessWidget {
  const _PreviewEntryRow({
    required this.entry,
    required this.onChanged,
  });

  final PreviewEntry entry;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;
    return InkWell(
      onTap: () => onChanged(!entry.selected),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              VispIcon(
                entry.isProxy ? VispIcons.proxy : VispIcons.server,
                size: 20,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: AppTextStyles.body),
                    Text(
                      entry.subtitle,
                      style: AppTextStyles.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.needsModule)
                VispChip(label: s.needsModule, tone: ChipTone.warning)
              else if (entry.isProxy)
                const VispChip(
                  label: 'Плагин «Прокси»',
                  tone: ChipTone.info,
                ),
              const SizedBox(width: AppSpacing.s),
              VispSwitch(value: entry.selected, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// Правила из чужого кода не заменяют локальные настройки молча:
/// доступны «Оставить мои», «Объединить» и «Заменить» (раздел 2.7).
class _RoutingRulesCard extends StatelessWidget {
  const _RoutingRulesCard({
    required this.choice,
    required this.onChanged,
  });

  final String choice;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.routingRules, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Правила из кода не заменяют локальные настройки молча. '
            'Выберите способ применения.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _ChoiceRow(
            label: s.keepMine,
            description: 'Локальные списки и режимы не изменятся',
            selected: choice == 'keep',
            onTap: () => onChanged('keep'),
          ),
          _ChoiceRow(
            label: s.merge,
            description: 'Новые записи добавятся к существующим',
            selected: choice == 'merge',
            onTap: () => onChanged('merge'),
          ),
          _ChoiceRow(
            label: s.replace,
            description: 'Локальные правила будут заменены правилами кода',
            selected: choice == 'replace',
            onTap: () => onChanged('replace'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.s + 2,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: selected
                  ? VispIcon(VispIcons.checkCircle, size: 18, color: colors.accent)
                  : Icon(Icons.radio_button_unchecked,
                      size: 18, color: colors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body),
                  Text(
                    description,
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
    );
  }
}
