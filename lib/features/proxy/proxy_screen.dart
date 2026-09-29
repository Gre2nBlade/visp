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
import '../../core/widgets/visp_switch.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../connection/models/connection_models.dart';

/// Вкладка «Прокси» появляется после установки плагина «Прокси для Telegram»
/// (раздел 8.2). Telegram-прокси обслуживают Telegram, а не все приложения.
class ProxyScreen extends StatelessWidget {
  const ProxyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.proxyTab),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + 56,
          ),
          children: [
            _LocalServiceCard(state: state),
            const SizedBox(height: AppSpacing.xl),
            VispSectionHeader(text: s.proxyForTelegram),
            if (state.proxies.isEmpty)
              VispCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      VispIcon(VispIcons.proxy, size: 32),
                      const SizedBox(height: AppSpacing.m),
                      Text(s.noConnectionsYet, style: AppTextStyles.body),
                    ],
                  ),
                ),
              )
            else
              for (final proxy in state.proxies) ...[
                _ProxyRow(proxy: proxy),
                const SizedBox(height: AppSpacing.m),
              ],
            const SizedBox(height: AppSpacing.xl),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Проверка', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    'Желаемый интервал — пожелание планировщику, не точный '
                    'таймер. Видно фактическое время последней проверки. '
                    'Открытый TCP-порт и его пинг не доказывают, что через '
                    'прокси работает Telegram.',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      VispButton.compact(
                        label: '15 мин',
                        style: VispButtonStyle.secondary,
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.s),
                      VispButton.compact(
                        label: '30 мин',
                        style: VispButtonStyle.secondary,
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.s),
                      VispButton.compact(
                        label: 'Час',
                        style: VispButtonStyle.secondary,
                        onPressed: () {},
                      ),
                    ],
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

/// Локальный TG WS Proxy: состояния «Выключен», «Запускается», «Работает»,
/// «Ошибка» (раздел 9.3).
class _LocalServiceCard extends StatelessWidget {
  const _LocalServiceCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final running = state.localProxyRunning;
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VispIcon(VispIcons.server, size: 20),
              const SizedBox(width: AppSpacing.m),
              Expanded(child: Text(s.localService, style: AppTextStyles.h2)),
              VispSwitch(
                value: running,
                onChanged: (_) => state.toggleLocalProxyService(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            running
                ? '${s.serviceRunning}: 127.0.0.1:8080'
                : s.serviceOff,
            style: AppTextStyles.small.copyWith(
              color: running
                  ? SemanticColors.of(context).primary
                  : SemanticColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          VispButton(
            label: s.openInTelegram,
            icon: VispIcons.send,
            style: VispButtonStyle.secondary,
            onPressed: () => VispToast.show(
              context,
              'Настройка предлагается пользователю: это не право '
              'переписывать настройки чужого приложения',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxyRow extends StatelessWidget {
  const _ProxyRow({required this.proxy});

  final ProxyRecord proxy;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;

    ChipTone tone;
    switch (proxy.checkState) {
      case ProxyCheckState.working:
        tone = ChipTone.accent;
      case ProxyCheckState.laggy:
        tone = ChipTone.warning;
      case ProxyCheckState.dead:
      case ProxyCheckState.stale:
        tone = ChipTone.danger;
      default:
        tone = ChipTone.neutral;
    }

    return VispCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(proxy.name, style: AppTextStyles.h2),
              ),
              VispChip(label: proxy.checkState.displayName, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            '${proxy.type.displayName} · ${proxy.address}',
            style: AppTextStyles.small.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Text(
                proxy.ping == null
                    ? '${s.ping}: ${s.noData}'
                    : '${s.ping}: ${proxy.ping} ms',
                style: AppTextStyles.tabular.copyWith(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              VispButton.compact(
                label: s.checkProxy,
                icon: VispIcons.signal,
                style: VispButtonStyle.secondary,
                onPressed: () => VispToast.show(
                  context,
                  'Проверяется доступность адреса; статус работоспособности '
                  'требует соответствующей проверки',
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              VispButton.compact(
                label: s.openInTelegram,
                icon: VispIcons.send,
                style: VispButtonStyle.secondary,
                onPressed: () => VispToast.show(
                  context,
                  'Успешное открытие ссылки не означает подтверждённое '
                  'соединение внутри Telegram',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
