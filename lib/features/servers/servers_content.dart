import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/blup_visp.dart';
import '../../core/widgets/visp_chip.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../connection/models/connection_models.dart';
import '../connection/widgets/engine_state_chip.dart';
import '../settings/server_details_screen.dart';
import '../../state/app_state.dart';

/// Список серверов-хостов с обязательными раскрываемыми группами.
///
/// Используется и шторкой главного экрана, и вкладкой «Серверы»: общее
/// состояние выбора, поиска и фильтров (раздел 5.1).
class ServersContent extends StatelessWidget {
  const ServersContent({
    super.key,
    this.onProfileSelected,
    this.scrollPhysics,
    this.shrinkWrap = false,
    this.padding,
  });

  final VoidCallback? onProfileSelected;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;
    final hosts = state.filteredHosts();

    if (hosts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VispIcon(VispIcons.server, size: 32),
            const SizedBox(height: AppSpacing.m),
            Text(s.noResults, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              state.serverQuery.isEmpty
                  ? s.noConnectionsYet
                  : s.searchHint,
              style: AppTextStyles.small.copyWith(
                color: SemanticColors.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: scrollPhysics,
      shrinkWrap: shrinkWrap,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.xxl,
          ),
      itemCount: hosts.length,
      itemBuilder: (context, index) {
        final host = hosts[index];
        return _HostGroup(
          host: host,
          selectedProfileId: state.selectedProfile?.id,
          expanded: state.isHostExpanded(host.id),
          onExpandToggle: () => state.toggleHostExpanded(host.id),
          onOpenDetails: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ServerDetailsScreen(hostId: host.id),
              ),
            );
          },
          onSelect: (profile) async {
            final previous = state.selectedProfile?.id;
            await state.selectProfile(profile.id);
              if (context.mounted && previous != profile.id) {
              if (state.status == BlupStatus.connected) {
                VispToast.show(context, s.sessionLost);
              }
            }
            onProfileSelected?.call();
          },
        );
      },
    );
  }
}

class _HostGroup extends StatelessWidget {
  const _HostGroup({
    required this.host,
    required this.selectedProfileId,
    required this.expanded,
    required this.onExpandToggle,
    required this.onOpenDetails,
    required this.onSelect,
  });

  final ServerHost host;
  final String? selectedProfileId;
  final bool expanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onOpenDetails;
  final void Function(ProtocolProfile) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: AppRadius.lAll,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            _HostHeader(
              host: host,
              expanded: expanded,
              onToggle: onExpandToggle,
              onOpenDetails: onOpenDetails,
            ),
            if (expanded)
              for (final profile in host.profiles)
                _ProfileRow(
                  profile: profile,
                  selected: profile.id == selectedProfileId,
                  onTap: () => onSelect(profile),
                ),
          ],
        ),
      ),
    );
  }
}

class _HostHeader extends StatelessWidget {
  const _HostHeader({
    required this.host,
    required this.expanded,
    required this.onToggle,
    required this.onOpenDetails,
  });

  final ServerHost host;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;
    // Сворачивание группы не снимает отметки и не выбирает профиль.
    final selectedInside = host.profiles.any(
      (p) => p.id == context.read<AppState>().selectedProfile?.id,
    );

    return InkWell(
      onTap: onToggle,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              VispIcon(
                expanded ? VispIcons.chevronDown : VispIcons.chevronRight,
                size: 20,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            host.name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (host.owned) ...[
                          const SizedBox(width: AppSpacing.s),
                          VispChip(label: 'Владелец', tone: ChipTone.accent),
                        ],
                        if (selectedInside) ...[
                          const SizedBox(width: AppSpacing.s),
                          VispChip(label: s.selected, tone: ChipTone.info),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${host.address}${host.region != null ? ' · ${host.region}' : ''} · '
                      '${host.profiles.length} ${s.profilesCount}',
                      style: AppTextStyles.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              VispIconButton(
                icon: VispIcons.info,
                tooltip: s.serverSettings,
                onPressed: onOpenDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final ProtocolProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.border),
          ),
        ),
        child: Row(
          children: [
            // Явный индикатор выбора: галочка + текст + цвет.
            SizedBox(
              width: 22,
              child: selected
                  ? VispIcon(VispIcons.check, size: 18, color: colors.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.s + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  Text(
                    profile.subtitle,
                    style: AppTextStyles.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (profile.engineState != EngineState.ready)
              EngineStateChip(state: profile.engineState),
          ],
        ),
      ),
    );
  }
}
