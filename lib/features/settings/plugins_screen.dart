import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/visp_button.dart';
import '../../core/widgets/visp_card.dart';
import '../../core/widgets/visp_chip.dart';
import '../../core/widgets/visp_list_row.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';

/// Экран «Плагины» (раздел 8): установленные, доступные и зависимости
/// в отдельных секциях. Каждый плагин — источник, версия, разрешения,
/// здоровье. Перед установкой — лист разрешений с полным деревом зависимостей.
class PluginsScreen extends StatelessWidget {
  const PluginsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PluginsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.groupPlugins)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + 56,
          ),
          children: [
            VispSectionHeader(text: 'Установленные'),
            VispCard(
              padding: EdgeInsets.zero,
              child: VispListRow(
                title: s.proxyForTelegram,
                description: s.proxyPluginDesc,
                icon: VispIcons.proxy,
                trailing: state.proxyInstalled
                    ? const VispChip(label: 'Работает', tone: ChipTone.accent)
                    : const VispChip(label: 'Не установлен', tone: ChipTone.neutral),
                onTap: () => state.proxyInstalled
                    ? VispToast.show(context, s.installed)
                    : _showPermissionSheet(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VispSectionHeader(text: 'Доступные'),
            _PluginCard(
              title: 'Обход DPI',
              description: 'Модуль совместимости соединения с сетью, а не '
                  'второй VPN и не обещание смены внешнего IP. Начальная '
                  'поддержка — только подготовленные и проверенные ОС.',
              icon: VispIcons.dpi,
              platforms: const ['Только ПК', 'Android'],
              version: '0.4.2',
              tone: ChipTone.beta,
              onInstall: () => VispToast.showError(
                context,
                'Модуль не подготовлен для этой платформы',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _PluginCard(
              title: 'Antigravity',
              description: 'Кандидат на исследование: диагностика соединения и '
                  'разрешённые параметры. Не исправляет любую ошибку 400.',
              icon: VispIcons.flask,
              platforms: const ['Только ПК'],
              version: '0.1.0',
              tone: ChipTone.beta,
              onInstall: () => VispToast.showError(
                context,
                'Экспериментальный модуль: совместимость проверяется',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VispSectionHeader(text: 'Зависимости и разрешения'),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Плагин — подписанный пакет с manifest, версией API, '
                    'платформами, разрешениями, зависимостями, health-check и '
                    'декларацией сетевых форматов (раздел 13.14).',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const VispChip(
                    label: 'Жизненный цикл: install → verify → configure → '
                        'run → update → rollback → uninstall',
                    tone: ChipTone.info,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Лист разрешений с полным деревом зависимостей перед установкой.
  void _showPermissionSheet(BuildContext context) {
    final s = context.s;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = SemanticColors.of(context);
        final state = context.read<AppState>();
        return Container(
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.proxyForTelegram, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Запрашиваемые разрешения и зависимости:',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.m),
                for (final entry in const [
                  ('Локальная сеть', 'Для локального TG WS Proxy'),
                  ('Уведомления', 'Статус проверок прокси'),
                  ('Фоновая работа', 'Периодическая проверка прокси'),
                  ('Зависимость', 'Движок прокси поставляется в составе плагина'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: Row(
                      children: [
                        VispIcon(VispIcons.check, size: 16, color: colors.accent),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.small
                                  .copyWith(color: colors.textPrimary),
                              children: [
                                TextSpan(
                                  text: '${entry.$1}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: entry.$2,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.m),
                VispButton(
                  label: s.install,
                  icon: VispIcons.download,
                  expanded: true,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await state.installProxyPlugin();
                    if (context.mounted) {
                      VispToast.show(context, s.installed);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PluginCard extends StatelessWidget {
  const _PluginCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.platforms,
    required this.version,
    required this.tone,
    required this.onInstall,
  });

  final String title;
  final String description;
  final VispIcons icon;
  final List<String> platforms;
  final String version;
  final ChipTone tone;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VispIcon(icon, size: 22),
              const SizedBox(width: AppSpacing.m),
              Expanded(child: Text(title, style: AppTextStyles.h2)),
              VispChip(label: 'Beta', tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            description,
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final platform in platforms)
                VispChip(label: platform, tone: ChipTone.neutral),
              VispChip(label: 'Версия $version', tone: ChipTone.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          VispButton(
            label: s.install,
            icon: VispIcons.download,
            style: VispButtonStyle.secondary,
            onPressed: onInstall,
          ),
        ],
      ),
    );
  }
}
