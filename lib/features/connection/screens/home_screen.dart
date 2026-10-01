import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/feedback/haptics.dart';
import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/blup_visp.dart';
import '../../../core/widgets/visp_button.dart';
import '../../../core/widgets/visp_chip.dart';
import '../../../core/widgets/visp_glass.dart';
import '../../../core/widgets/visp_input.dart';
import '../../../core/widgets/visp_card.dart';
import '../../../core/widgets/visp_list_row.dart';
import '../../../core/widgets/visp_toast.dart';
import '../../../l10n/strings.dart';
import '../../../state/app_state.dart';
import '../../servers/servers_content.dart';
import '../models/connection_models.dart';
import '../widgets/engine_state_chip.dart';
import 'add_connection_screen.dart';
import 'split_tunneling_screen.dart';

/// Главный экран: Blup Visp в центре, текстовый статус, кнопка подключения,
/// карточка текущего сервера и debug-блок (раздел 4).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      body: state.hasConnections
          ? _ConnectedHome(state: state, s: s)
          : _EmptyHome(s: s),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xxl,
          AppSpacing.l,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlupVisp(
              status: BlupStatus.idle,
              size: 120,
              motionReduced: _motionReduced(context),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(s.noConnectionsYet, style: AppTextStyles.display),
            const SizedBox(height: AppSpacing.s),
            Text(
              s.enterCodeHint,
              style: AppTextStyles.body.copyWith(
                color: SemanticColors.of(context).textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _CompactAddPanel(),
          ],
        ),
      ),
    );
  }
}

/// Компактная панель ввода кода прямо на главной, если подключений ещё нет
/// (раздел 1: никакой промежуточной пустой страницы перед вводом кода).
class _CompactAddPanel extends StatefulWidget {
  const _CompactAddPanel();

  @override
  State<_CompactAddPanel> createState() => _CompactAddPanelState();
}

class _CompactAddPanelState extends State<_CompactAddPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    final result = await AddConnectionScreen.openWithPreview(context, value);
    if (result == true && mounted) {
      _controller.clear();
      VispToast.show(context, context.s.addedN);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final text = (data?.text ?? '').trim();
    if (!mounted) return;
    if (text.isEmpty) {
      VispToast.showError(context, context.s.noData);
      return;
    }
    _controller.text = text;
    Haptics.selection(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VispInput(
          controller: _controller,
          label: s.pasteKey,
          hintText: s.pasteKeyHint,
          maxLines: 2,
          minLines: 1,
          textInputAction: TextInputAction.go,
          onSubmitted: _submit,
          suffixIcon: VispButton.compact(
            label: s.paste,
            icon: VispIcons.paste,
            onPressed: _paste,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            VispButton.compact(
              label: s.selfHosted,
              style: VispButtonStyle.secondary,
              icon: VispIcons.server,
              onPressed: () => AddConnectionScreen.open(context,
                  initialSection: AddSection.selfHosted),
            ),
            VispButton.compact(
              label: s.configFile,
              style: VispButtonStyle.secondary,
              icon: VispIcons.file,
              onPressed: () => AddConnectionScreen.open(context,
                  initialSection: AddSection.file),
            ),
            VispButton.compact(
              label: s.qrCode,
              style: VispButtonStyle.secondary,
              icon: VispIcons.qr,
              onPressed: () => AddConnectionScreen.open(context,
                  initialSection: AddSection.qr),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectedHome extends StatelessWidget {
  const _ConnectedHome({required this.state, required this.s});

  final AppState state;
  final S s;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final isBlocked = state.status == BlupStatus.blocked;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            // Blup Visp стоит в геометрическом центре доступной области,
            // а элементы управления прижаты к низу: центр экрана остаётся
            // пустым, композиция читается с одного взгляда.
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: BlupVisp(
                      status: state.status,
                      size: 208,
                      trafficPulse: state.trafficPulse,
                      motionReduced: _motionReduced(context),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      _StatusText(state: state, s: s),
                      const Spacer(),
                      if (state.errorText != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            state.errorText!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.small.copyWith(
                              color: colors.danger,
                            ),
                          ),
                        ),
                      if (isBlocked)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: Center(
                            child: VispChip(
                              label: s.trafficBlocked,
                              tone: ChipTone.danger,
                            ),
                          ),
                        ),
                      _ProtocolSelector(state: state),
                      const SizedBox(height: AppSpacing.l),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _ConnectButton(state: state, s: s),
                      ),
                      if (state.debugVisible) ...[
                        const SizedBox(height: AppSpacing.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l,
                          ),
                          child: _DebugBlock(state: state),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.l),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ServerCard(state: state, s: s),
        ],
      ),
    );
  }
}

bool _motionReduced(BuildContext context) {
  final mq = MediaQuery.of(context);
  return mq.disableAnimations || mq.accessibleNavigation;
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.state, required this.s});

  final AppState state;
  final S s;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final isConnected = state.status == BlupStatus.connected;
    final isError = state.status == BlupStatus.error;

    final String label;
    switch (state.status) {
      case BlupStatus.idle:
        label = s.vpnOff;
      case BlupStatus.preparing:
      case BlupStatus.checking:
      case BlupStatus.connecting:
      case BlupStatus.reconnecting:
        label = state.statusDetail ?? s.connect;
      case BlupStatus.connected:
        label = s.connected;
      case BlupStatus.error:
        label = isError ? (state.errorText?.split('.').first ?? s.vpnOff) : s.vpnOff;
      case BlupStatus.blocked:
        label = s.trafficBlocked;
    }

    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.h1.copyWith(
            color: isError
                ? colors.danger
                : isConnected
                    ? colors.primary
                    : colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          _subtitle(),
          style: AppTextStyles.small.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  String _subtitle() {
    final host = state.selectedHost;
    final profile = state.selectedProfile;
    if (host == null || profile == null) return s.notChosen;
    return '${profile.protocol.displayName} | ${host.address}';
  }
}

/// Кнопка-переключатель протокола (раздел 8.1): серая кнопка с закруглёнными
/// углами и стрелкой вниз. Смена протокола при активной сессии
/// предупреждает о переподключении (раздел 7.3).
class _ProtocolSelector extends StatelessWidget {
  const _ProtocolSelector({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.selectedProfile;
    final host = state.selectedHost;
    if (profile == null || host == null) return const SizedBox.shrink();

    return Center(
      child: VispButton.compact(
        label: profile.protocol.displayName,
        icon: VispIcons.chevronDown,
        style: VispButtonStyle.secondary,
        onPressed: () => _openProtocolSheet(context, host),
      ),
    );
  }

  void _openProtocolSheet(BuildContext context, ServerHost host) {
    final s = context.s;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SemanticColors.of(context).popover,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      builder: (sheetContext) {
        final colors = SemanticColors.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.s,
                ),
                child: Text(s.protocolChoice, style: AppTextStyles.h2),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.l,
                  right: AppSpacing.l,
                  bottom: AppSpacing.s,
                ),
                child: Text(
                  '${host.name} · ${host.address}',
                  style: AppTextStyles.small.copyWith(color: colors.textSecondary),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: host.profiles.length,
                  itemBuilder: (_, i) {
                    final p = host.profiles[i];
                    final selected = p.id == state.selectedProfile?.id;
                    return InkWell(
                      onTap: () => _confirmAndSelect(context, p),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                          vertical: AppSpacing.s,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.protocol.displayName,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? colors.primary
                                          : colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${p.protocol.description}'
                                    '\n${host.address}:${p.port}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.small
                                        .copyWith(color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            EngineStateChip(state: p.engineState),
                            if (selected)
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.s),
                                child: VispIcon(VispIcons.check,
                                    size: 18, color: colors.primary),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAndSelect(BuildContext context, ProtocolProfile profile) async {
    final s = context.s;
    if (state.isActive && profile.id != state.selectedProfile?.id) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: SemanticColors.of(dialogContext).popover,
          title: Text(s.protocolChoice, style: AppTextStyles.h2),
          content: Text(s.switchProtocolWarn, style: AppTextStyles.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                s.continueWord,
                style: AppTextStyles.button
                    .copyWith(color: SemanticColors.of(dialogContext).primary),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await state.selectProfile(profile.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.state, required this.s});

  final AppState state;
  final S s;

  @override
  Widget build(BuildContext context) {
    final isInProgress = state.status == BlupStatus.preparing ||
        state.status == BlupStatus.checking ||
        state.status == BlupStatus.connecting ||
        state.status == BlupStatus.reconnecting;
    final isConnected = state.status == BlupStatus.connected;

    if (isInProgress) {
      return Row(
        children: [
          Expanded(
            child: VispButton(
              label: s.cancelConnection,
              style: VispButtonStyle.secondary,
              icon: VispIcons.close,
              onPressed: state.cancelConnect,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: VispButton(
            label: isConnected ? s.disconnect : s.connect,
            size: VispButtonSize.prominent,
            icon: isConnected ? VispIcons.close : VispIcons.plug,
            style: isConnected ? VispButtonStyle.danger : VispButtonStyle.primary,
            onPressed: () async {
              if (isConnected) {
                state.disconnect();
                return;
              }
              if (state.selectedProfile == null) {
                VispToast.showError(
                  context,
                  s.notChosen,
                  actionLabel: s.addConnection,
                  onAction: () => AddConnectionScreen.open(context),
                );
                return;
              }
              await state.connect();
            },
          ),
        ),
      ],
    );
  }
}

/// Debug-информация под хамелеоном (раздел 4.2): скорость, пинг, сессия.
/// Переключатель не включает отправку диагностики автоматически.
class _DebugBlock extends StatelessWidget {
  const _DebugBlock({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return VispGlassPanel(
      // Матовое стекло: панель прокручивается с контентом, и преломление
      // внутри списка давало бы артефакты на краях.
      enabled: state.glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VispIcon(VispIcons.gauge, size: 16),
              const SizedBox(width: AppSpacing.s),
              Text(s.debugInfo, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
              children: [
                Expanded(
                  child: _DebugStat(
                    label: s.download,
                    value: state.downSpeed == null
                        ? s.noData
                        : state.downSpeed!.toStringAsFixed(1),
                    unit: state.downSpeed == null ? '' : ' Mb/s',
                    icon: VispIcons.download,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _DebugStat(
                    label: s.upload,
                    value: state.upSpeed == null
                        ? s.noData
                        : state.upSpeed!.toStringAsFixed(1),
                    unit: state.upSpeed == null ? '' : ' Mb/s',
                    icon: VispIcons.upload,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _DebugStat(
                    label: s.ping,
                    value: state.ping == null
                        ? s.noData
                        : state.ping.toString(),
                    unit: state.ping == null ? '' : ' ms',
                    icon: VispIcons.signal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: _DebugStat(
                    label: s.protocol,
                    value: state.selectedProfile?.protocol.displayName ??
                        s.auto,
                    icon: VispIcons.route,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _DebugStat(
                    label: s.sessionTime,
                    value: _formatDuration(state.sessionDuration),
                    icon: VispIcons.clock,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }
}

class _DebugStat extends StatelessWidget {
  const _DebugStat({
    required this.label,
    required this.value,
    required this.icon,
    this.unit = '',
  });

  final String label;
  final String value;
  final VispIcons icon;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Row(
      children: [
        VispIcon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '$value$unit',
                style: AppTextStyles.tabular.copyWith(
                  color: colors.textPrimary,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Карточка текущего подключения (раздел 4.3) + строка раздельного
/// туннелирования (раздел 4.4).
class _ServerCard extends StatelessWidget {
  const _ServerCard({required this.state, required this.s});

  final AppState state;
  final S s;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final host = state.selectedHost;
    final profile = state.selectedProfile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, 0),
      child: Column(
        children: [
          VispGlassPanel(
            enabled: state.glass,
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.lAll,
                onTap: () => _showServersSheet(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              host?.name ?? s.notChosen,
                              style: AppTextStyles.h2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile == null
                                  ? s.notChosen
                                  : '${profile.protocol.displayName} | ${host!.address}',
                              style: AppTextStyles.small.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      VispIcon(VispIcons.chevronDown, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          VispCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: VispListRow(
              title: s.splitTunneling,
              icon: VispIcons.route,
              description: state.splitTunneling
                  ? s.splitTunnelingOn
                  : s.splitTunnelingOff,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SplitTunnelingScreen(),
                  ),
                );
              },
              trailing: Switch(
                value: state.splitTunneling,
                activeThumbColor: colors.primary,
                onChanged: (v) => state.setSplitTunneling(v),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ),
    );
  }

  /// Шторка списка именно VPN-серверов: прокси здесь не показываются.
  void _showServersSheet(BuildContext context) {
    Haptics.light(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return VispGlass(
          enabled: state.glass,
          radius: 24,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    children: [
                      Text(s.serversList, style: AppTextStyles.h2),
                      const Spacer(),
                      VispIconButton(
                        icon: VispIcons.close,
                        tooltip: s.close,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ServersContent(
                    shrinkWrap: true,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    onProfileSelected: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      0,
                      AppSpacing.l,
                      AppSpacing.xxl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
