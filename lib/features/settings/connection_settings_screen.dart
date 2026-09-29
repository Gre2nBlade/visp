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
import '../connection/screens/split_tunneling_screen.dart';

/// Настройки соединения: kill switch, автозапуск, always-on,
/// раздельное туннелирование, DNS и IPv6 (раздел 10, «Соединение»).
class ConnectionSettingsScreen extends StatelessWidget {
  const ConnectionSettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConnectionSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.groupConnection)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl + 56,
          ),
          children: [
            _SwitchCard(
              title: s.killSwitch,
              description: s.killSwitchDesc,
              icon: VispIcons.shieldCheck,
              value: state.killSwitch,
              onChanged: state.setKillSwitch,
            ),
            const SizedBox(height: AppSpacing.m),
            _SwitchCard(
              title: s.autostart,
              description: s.autostartDesc,
              icon: VispIcons.plug,
              value: state.autostart,
              onChanged: state.setAutostart,
            ),
            const SizedBox(height: AppSpacing.m),
            VispCard(
              padding: EdgeInsets.zero,
              child: VispListRow(
                title: s.splitTunneling,
                description: state.splitTunneling
                    ? s.splitTunnelingOn
                    : s.splitTunnelingOff,
                icon: VispIcons.route,
                trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SplitTunnelingScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _DnsCard(state: state),
            const SizedBox(height: AppSpacing.m),
            _Ipv6Card(),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final VispIcons icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return VispCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  description,
                  style: AppTextStyles.small.copyWith(
                    color: SemanticColors.of(context).textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          VispSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// DNS: видно, какой резолвер используется и идёт ли запрос через VPN.
/// DoH шифрует обращение к резолверу, но не меняет исходящий IP.
class _DnsCard extends StatelessWidget {
  const _DnsCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.dns, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            'Автоматический профиль сервера, собственный DNS или совместимый '
            'зашифрованный DNS (DoH/DoT). Резолвер виден пользователю.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: const [
              VispChip(label: 'Режим: профиль сервера', tone: ChipTone.info),
              VispChip(
                label: 'DoH не меняет исходящий IP',
                tone: ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          VispButton(
            label: 'Проверить сейчас',
            icon: VispIcons.signal,
            style: VispButtonStyle.secondary,
            onPressed: () => VispToast.show(
              context,
              'Проверка не включает туннель и не отправляет содержимое '
              'трафика: сохраняются итог, время и метод',
            ),
          ),
        ],
      ),
    );
  }
}

class _Ipv6Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IPv6', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            'IPv6 предпочтительно поддерживать через VPN. Если выбранное '
            'подключение этого не умеет, защищаемый IPv6-трафик блокируется '
            'от прямого выхода, а не выпускается в обход IPv4-туннеля. '
            'Блокировка IPv6 не скрывает наличие VPN.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
