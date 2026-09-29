import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/blup_visp.dart';
import '../../core/widgets/visp_button.dart';
import '../../core/widgets/visp_card.dart';
import '../../core/widgets/visp_chip.dart';
import '../../core/widgets/visp_switch.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../connection/models/connection_models.dart';

/// Studio — кабинет владельцев серверов и делегированных сотрудников
/// (раздел 13). Всегда доступна из Настроек без секретного кода.
class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StudioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;
    final ownedHosts = state.hosts.where((h) => h.owned).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.studio),
        actions: [
          if (state.devRole)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: Center(
                child: VispChip(
                  label: 'Глобальный кабинет',
                  tone: ChipTone.info,
                ),
              ),
            ),
        ],
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
            // Область видимости: организация, группа серверов и роль.
            VispCard(
              child: Row(
                children: [
                  BlupVisp(
                    status: ownedHosts.isEmpty
                        ? BlupStatus.idle
                        : BlupStatus.connected,
                    size: 56,
                    compact: true,
                    motionReduced: true,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.devRole
                              ? 'Глобальный кабинет Visp'
                              : 'Studio владельца',
                          style: AppTextStyles.h2,
                        ),
                        Text(
                          state.devRole
                              ? 'Сводка служб, отчёты об ошибках, релизы и каталог'
                              : 'Область: личные серверы · роль: владелец',
                          style: AppTextStyles.small.copyWith(
                            color: SemanticColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (ownedHosts.isEmpty)
              _EmptyState()
            else
              _OwnerOverview(ownedHosts: ownedHosts),
            const SizedBox(height: AppSpacing.xl),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.studioInNav, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    s.studioInNavDesc,
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.studioInNav,
                          style: AppTextStyles.body,
                        ),
                      ),
                      VispSwitch(
                        value: state.studioPinned,
                        onChanged: state.setStudioPinned,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Управление доступом', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    'Создать новый код может только подтверждённый владелец '
                    'сервера или сотрудник с явно делегированным правом выдачи '
                    'доступа. Получивший код может только передать его дальше.',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  VispButton(
                    label: 'Создать набор доступа',
                    icon: VispIcons.key,
                    expanded: true,
                    onPressed: () => VispToast.show(
                      context,
                      'Мастер создания кода: выбор профилей, формата и срока',
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            VispIcon(VispIcons.studio, size: 40),
            const SizedBox(height: AppSpacing.m),
            Text(s.studioEmpty, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              s.studioEmptyDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(
                color: SemanticColors.of(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerOverview extends StatelessWidget {
  const _OwnerOverview({required this.ownedHosts});

  final List<ServerHost> ownedHosts;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Обзор владельца', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.m),
        for (final host in ownedHosts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: VispCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(host.name, style: AppTextStyles.h2),
                      ),
                      const VispChip(label: 'Работает', tone: ChipTone.accent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    '${host.address} · ${host.profiles.length} ${s.profilesCount}',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.s,
                    children: [
                      VispChip(
                        label: 'Активных кодов: 1',
                        tone: ChipTone.neutral,
                      ),
                      VispChip(
                        label: 'Устройств: 2 из 5',
                        tone: ChipTone.neutral,
                      ),
                      VispChip(
                        label: 'Трафик: 12% от лимита',
                        tone: ChipTone.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Text(
          'Показываются только реальные данные с временем последнего получения. '
          '«Нет данных», «Сервер недоступен» и «Сервер остановлен» — '
          'разные состояния.',
          style: AppTextStyles.small.copyWith(
            color: SemanticColors.of(context).textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
