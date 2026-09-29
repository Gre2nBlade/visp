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
import '../connection/models/connection_models.dart';
import '../connection/widgets/engine_state_chip.dart';

/// Карточка сервера (раздел 5.2): шапка, вкладки «Протоколы» | «Управление».
class ServerDetailsScreen extends StatefulWidget {
  const ServerDetailsScreen({super.key, required this.hostId});

  final String hostId;

  @override
  State<ServerDetailsScreen> createState() => _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends State<ServerDetailsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;
    final host = state.hosts.where((h) => h.id == widget.hostId).firstOrNull;
    if (host == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(s.noData)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(host.name),
        actions: [
          VispIconButton(
            icon: VispIcons.edit,
            tooltip: s.rename,
            onPressed: () => VispToast.show(context, '${s.rename}: ${host.name}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: Text(
                host.address +
                    (host.region != null ? ' · ${host.region}' : ''),
                style: AppTextStyles.small.copyWith(
                  color: SemanticColors.of(context).textSecondary,
                ),
              ),
            ),
            _Tabs(
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
              labels: [s.protocols, s.management],
            ),
            Expanded(
              child: _tab == 0
                  ? _ProtocolsTab(host: host)
                  : _ManagementTab(host: host),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.index,
    required this.onChanged,
    required this.labels,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s + 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? colors.primary : colors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: selected ? colors.primary : colors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Протоколы сервера: каждый профиль отдельной строкой с описанием,
/// состоянием готовности и выбором. Отсутствующий движок предлагается
/// получить разрешённым для ОС способом.
class _ProtocolsTab extends StatelessWidget {
  const _ProtocolsTab({required this.host});

  final ServerHost host;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xxl + 56,
      ),
      children: [
        for (final profile in host.profiles) ...[
          _ProtocolCard(host: host, profile: profile),
          const SizedBox(height: AppSpacing.m),
        ],
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s),
          child: Text(
            'Три состояния различаются: движок есть на устройстве, протокол '
            'запущен на сервере и есть подходящая конфигурация. Скачивание '
            'движка не устанавливает протокол на удалённый сервер.',
            style: AppTextStyles.small.copyWith(
              color: SemanticColors.of(context).textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.host, required this.profile});

  final ServerHost host;
  final ProtocolProfile profile;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = SemanticColors.of(context);
    final s = context.s;
    final selected = state.selectedProfile?.id == profile.id;

    return VispCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.protocol.displayName,
                  style: AppTextStyles.h2,
                ),
              ),
              if (selected)
                const VispChip(label: 'Выбран', tone: ChipTone.accent)
              else if (profile.engineState != EngineState.ready)
                EngineStateChip(state: profile.engineState)
              else
                VispChip(label: s.readyToConnect, tone: ChipTone.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            profile.protocol.description,
            style: AppTextStyles.small.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Text('Порт ${profile.port}', style: AppTextStyles.mono),
              const SizedBox(width: AppSpacing.s),
              const VispChip(
                label: 'Источник: конфигурация получена',
                tone: ChipTone.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: VispButton(
                  label: selected ? s.selected : s.chooseServer,
                  icon: selected ? VispIcons.check : VispIcons.route,
                  style: selected
                      ? VispButtonStyle.secondary
                      : VispButtonStyle.primary,
                  onPressed: selected
                      ? null
                      : () async {
                          await state.selectProfile(profile.id);
                          if (context.mounted) {
                            VispToast.show(context, s.selected);
                          }
                        },
                ),
              ),
              if (!profile.engineReady) ...[
                const SizedBox(width: AppSpacing.s),
                VispButton.compact(
                  label: s.downloadEngine,
                  icon: VispIcons.download,
                  style: VispButtonStyle.secondary,
                  onPressed: () => VispToast.showError(
                    context,
                    'Доставка движка зависит от ОС и магазина',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Управление сервером: переименовать, изменить порт, настройки, поделиться
/// (только владелец), удалить сервер из приложения (красным, с подтверждением).
class _ManagementTab extends StatelessWidget {
  const _ManagementTab({required this.host});

  final ServerHost host;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xxl + 56,
      ),
      children: [
        if (host.owned) ...[
          VispCard(
            padding: EdgeInsets.zero,
            child: VispListRow(
              title: s.autoInstall,
              description: 'Доустановить компоненты на сервер',
              icon: VispIcons.download,
              trailing: const VispIcon(VispIcons.chevronRight, size: 18),
              onTap: () => VispToast.show(
                context,
                'Автоустановка доступна для своих серверов после '
                'привязки к Studio',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        VispCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              VispListRow(
                title: s.rename,
                description: host.name,
                icon: VispIcons.edit,
                onTap: () => VispToast.show(context, '${s.rename}: ${host.name}'),
              ),
              _divider(context),
              VispListRow(
                title: s.serverSettings,
                description: host.address,
                icon: VispIcons.settings,
                onTap: () => VispToast.show(context, s.serverSettings),
              ),
              _divider(context),
              VispListRow(
                title: s.share,
                description: host.owned
                    ? 'Мастер Studio: выбор профилей, формата и срока'
                    : 'Недоступно: создание кода требует подтверждённого '
                        'владения сервером',
                icon: VispIcons.share,
                trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                onTap: () {
                  if (!host.owned) {
                    VispToast.showError(
                      context,
                      'Создать новый код может только подтверждённый владелец '
                      'сервера. Получивший код может только передать его дальше',
                    );
                    return;
                  }
                  VispToast.show(context, 'Мастер создания кода Studio');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        VispButton.destructive(
          label: s.deleteServer,
          confirmTitle: s.deleteServer,
          confirmMessage: s.deleteServerConfirm,
          expanded: true,
          onConfirmed: () async {
            await state.deleteHost(host.id);
            if (context.mounted) {
              VispToast.show(context, s.deleteServer);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }
}
