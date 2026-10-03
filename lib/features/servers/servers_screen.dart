import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import 'servers_content.dart';
import 'widgets/server_filter_button.dart';

/// Вкладка «Серверы»: один список, поиск и фильтрация (раздел 5).
class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;
    final protocols = ServerFilterButton.availableProtocols(state.hosts);

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
              child: Row(
                children: [
                  Expanded(child: _SearchField()),
                  const SizedBox(width: AppSpacing.s),
                  // Фильтры — одна кнопка: лента чипов не помещалась в экран,
                  // когда протоколов становилось больше четырёх.
                  ServerFilterButton(
                    protocolFilter: state.protocolFilter,
                    readyOnly: state.readyOnly,
                    protocols: protocols,
                    onProtocolChanged: state.setProtocolFilter,
                    onReadyOnlyChanged: state.setReadyOnly,
                    onClear: () {
                      state.setProtocolFilter(null);
                      state.setReadyOnly(false);
                    },
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
