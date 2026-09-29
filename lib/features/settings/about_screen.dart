import 'package:flutter/material.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/visp_button.dart';
import '../../core/widgets/visp_card.dart';
import '../../core/widgets/visp_list_row.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';

/// О приложении (раздел 10): версия, исходный код, лицензии, политика.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final colors = SemanticColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.groupAbout)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.xxl,
            AppSpacing.l,
            AppSpacing.xxl + 56,
          ),
          children: [
            Center(
              child: const BlupMark(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text('Visp', style: AppTextStyles.display),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Center(
              child: Text(
                'CLIENT FOR VPN AND PROXY',
                style: AppTextStyles.small.copyWith(
                  color: colors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            VispCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  VispListRow(
                    title: s.version,
                    description: '1.0.0 · прототип',
                    icon: VispIcons.info,
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.checkUpdates,
                    icon: VispIcons.refresh,
                    onTap: () => _showUpdateSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VispSectionHeader(text: s.groupAbout),
            VispCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  VispListRow(
                    title: s.sourceCode,
                    description: 'github.com/absurdstudios/visp',
                    icon: VispIcons.code,
                    onTap: () => VispToast.show(context, s.sourceCode),
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.licenses,
                    icon: VispIcons.file,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Visp',
                      applicationVersion: '1.0.0',
                    ),
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.privacyPolicy,
                    icon: VispIcons.shieldCheck,
                    onTap: () => VispToast.show(context, s.privacyPolicy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VispIcon(VispIcons.shieldCheck,
                          size: 18, color: colors.primary),
                      const SizedBox(width: AppSpacing.s),
                      Text('Что Visp не обещает', style: AppTextStyles.h2),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Visp — клиент, а не обещание бесплатного сервера. '
                    'Ни один протокол не гарантирует невидимость или обход '
                    'любых белых списков. Результат зависит от доступности '
                    'сервера, сети и конфигурации. DNS, WARP, VPN и прокси '
                    'решают разные задачи — интерфейс показывает состояние '
                    'каждого участка.',
                    style: AppTextStyles.small.copyWith(
                      color: colors.textSecondary,
                      height: 1.55,
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

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }

  /// Модал «Доступно обновление»: Обновить / Позже (раздел 15).
  void _showUpdateSheet(BuildContext context) {
    final s = context.s;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = SemanticColors.of(context);
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
                Text(s.updateAvailable, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Visp 1.1.0: улучшен импорт подписок, исправлены ошибки '
                  'переподключения. Размер 4.2 МБ, совместима с этой '
                  'версией устройства. Скачивание вне магазина — с проверкой '
                  'подписи; автоустановки нет.',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                VispButton(
                  label: s.updateNow,
                  icon: VispIcons.download,
                  expanded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    VispToast.show(context, 'Загрузка начнётся в фоне');
                  },
                ),
                const SizedBox(height: AppSpacing.s),
                VispButton(
                  label: s.later,
                  style: VispButtonStyle.secondary,
                  expanded: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Логотип-метка: упрощённый язык формы Blup Visp.
class BlupMark extends StatelessWidget {
  const BlupMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: SemanticColors.of(context).surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SemanticColors.of(context).border),
      ),
      child: Center(
        child: VispIcon(
          VispIcons.shieldCheck,
          size: 40,
          color: SemanticColors.of(context).primary,
        ),
      ),
    );
  }
}
