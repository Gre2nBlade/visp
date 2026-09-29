import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/visp_button.dart';
import '../../core/widgets/visp_card.dart';
import '../../core/widgets/visp_switch.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../state/preferences.dart';

/// Персонализация (раздел 11): тема, материал-стекло, каталог тем и иконок.
class PersonalizationScreen extends StatelessWidget {
  /// Сразу к разделу обновлений (канал stable/beta).
  static Future<void> openUpdates(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PersonalizationScreen(initialUpdates: true),
      ),
    );
  }

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PersonalizationScreen()),
    );
  }

  final bool initialUpdates;

  const PersonalizationScreen({super.key, this.initialUpdates = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.groupPersonalization)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + 56,
          ),
          children: [
            Text(
              s.theme,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.s),
            _ThemeSegment(state: state),
            const SizedBox(height: AppSpacing.xl),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(s.glass, style: AppTextStyles.h2),
                      ),
                      VispSwitch(
                        value: state.glass,
                        onChanged: state.setGlass,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    'Стекло — материал навигационной капсулы, кнопки добавления '
                    'и шторки серверов, а не смена всей палитры. Текст, цифры '
                    'скорости и поля ввода остаются резкими.',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (initialUpdates) ...[
              _UpdatesCard(state: state),
              const SizedBox(height: AppSpacing.xl),
            ],
            _CatalogCard(),
            const SizedBox(height: AppSpacing.xl),
            _IconsCard(),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispSegmented<AppThemeMode>(
      values: AppThemeMode.values,
      value: state.themeMode,
      labels: {
        AppThemeMode.system: s.system,
        AppThemeMode.light: s.light,
        AppThemeMode.dark: s.dark,
      },
      onChanged: state.setThemeMode,
    );
  }
}

class _UpdatesCard extends StatelessWidget {
  const _UpdatesCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.groupUpdates, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            'Канал выбирается отдельно для приложения, движков и плагинов. '
            'Beta приходит тем же механизмом проверки подписи, что и стабильные '
            'релизы.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          VispSegmented<UpdateChannel>(
            values: UpdateChannel.values,
            value: state.updateChannel,
            labels: {
              UpdateChannel.stable: s.stable,
              UpdateChannel.beta: s.beta,
            },
            onChanged: state.setUpdateChannel,
          ),
          const SizedBox(height: AppSpacing.m),
          VispButton(
            label: s.checkUpdates,
            icon: VispIcons.refresh,
            style: VispButtonStyle.secondary,
            expanded: true,
            onPressed: () => VispToast.show(context, s.updateAvailable),
          ),
        ],
      ),
    );
  }
}

/// Каталог тем получает с сервера превью и совместимые ресурсы.
/// Ошибка каталога не сбрасывает оформление (раздел 11.1).
class _CatalogCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VispIcon(VispIcons.theme, size: 18, color: colors.accent),
              const SizedBox(width: AppSpacing.s),
              Text('Каталог тем', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Скачанная тема работает без интернета. Перед применением — '
            'предварительный просмотр и возврат к текущему варианту.',
            style: AppTextStyles.small.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _ThemeSwatch(name: 'Шалфей', color: const Color(0xFF6FBF93)),
              const SizedBox(width: AppSpacing.s),
              _ThemeSwatch(name: 'Графит', color: const Color(0xFF4A5A4F)),
              const SizedBox(width: AppSpacing.s),
              _ThemeSwatch(name: 'Терракота', color: const Color(0xFFE57B6E)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.mAll,
            border: Border.all(
              color: SemanticColors.of(context).border,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 1),
        Text(
          name,
          style: AppTextStyles.small.copyWith(
            color: SemanticColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}

class _IconsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Иконка приложения', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            'На iOS настоящие альтернативные иконки включены в сборку: сервер '
            'обновляет каталог, но не заменяет их скачанной картинкой. На '
            'Android доступность зависит от лаунчера. Закреплённый ярлык — '
            'не замена настоящей иконки.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          VispButton(
            label: 'Открыть каталог',
            style: VispButtonStyle.tertiary,
            icon: VispIcons.info,
            onPressed: () => VispToast.show(context, 'Каталог иконок'),
          ),
        ],
      ),
    );
  }
}
