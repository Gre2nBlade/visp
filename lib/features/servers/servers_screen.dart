import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../connection/models/connection_models.dart';
import 'servers_content.dart';

/// Вкладка «Серверы»: один список, поиск и фильтрация (раздел 5).
class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;
    final protocols = _availableProtocols(state.hosts);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.servers),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: _SearchField(),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                ),
                children: [
                  _FilterChip(
                    label: s.all,
                    selected: state.protocolFilter == null,
                    onTap: () => state.setProtocolFilter(null),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  for (final protocol in protocols) ...[
                    _FilterChip(
                      label: protocol.displayName,
                      selected: state.protocolFilter == protocol,
                      onTap: () => state.setProtocolFilter(
                        state.protocolFilter == protocol ? null : protocol,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                  ],
                  _FilterChip(
                    label: s.filterReady,
                    selected: state.readyOnly,
                    onTap: () => state.setReadyOnly(!state.readyOnly),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Expanded(child: ServersContent()),
          ],
        ),
      ),
    );
  }

  List<Protocol> _availableProtocols(List<ServerHost> hosts) {
    final set = <Protocol>{};
    for (final host in hosts) {
      for (final profile in host.profiles) {
        set.add(profile.protocol);
      }
    }
    return set.toList();
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final state = context.watch<AppState>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadius.mAll,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.m),
            child: Icon(Icons.search, size: 18, color: colors.textSecondary),
          ),
          Expanded(
            child: TextField(
              onChanged: state.setServerQuery,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: context.s.searchHint,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.m - 2,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (state.serverQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => state.setServerQuery(''),
              tooltip: context.s.close,
              splashRadius: 16,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.16)
          : colors.surface2,
      borderRadius: BorderRadius.circular(AppRadius.s + 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s + 4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s - 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.s + 4),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: 0.5)
                  : colors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: selected ? colors.primary : colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
