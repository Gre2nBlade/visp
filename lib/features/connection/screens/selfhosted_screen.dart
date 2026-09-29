import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/visp_button.dart';
import '../../../core/widgets/visp_card.dart';
import '../../../core/widgets/visp_input.dart';
import '../../../core/widgets/visp_list_row.dart';
import '../../../core/widgets/visp_toast.dart';
import '../../../l10n/strings.dart';
import '../../../state/app_state.dart';

/// Установка на свой сервер (раздел 12). Упрощённый мастер:
/// подключение → проверка компонентов → результат.
class SelfhostedScreen extends StatefulWidget {
  const SelfhostedScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SelfhostedScreen()),
    );
  }

  @override
  State<SelfhostedScreen> createState() => _SelfhostedScreenState();
}

enum _Step { form, installing, done }

class _SelfhostedScreenState extends State<SelfhostedScreen> {
  final _address = TextEditingController();
  final _user = TextEditingController(text: 'root');
  final _secret = TextEditingController();
  bool _obscure = true;
  String? _addressError;
  String? _secretError;
  _Step _step = _Step.form;

  @override
  void dispose() {
    _address.dispose();
    _user.dispose();
    _secret.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _addressError = _address.text.trim().isEmpty
          ? context.s.errorAddressUnreachable
          : null;
      _secretError = _secret.text.trim().isEmpty
          ? context.s.errorCredentials
          : null;
    });
    return _addressError == null && _secretError == null;
  }

  Future<void> _install() async {
    if (!_validate()) return;
    setState(() => _step = _Step.installing);
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await context
        .read<AppState>()
        .installSelfHosted(
          address: _address.text.trim(),
          user: _user.text.trim(),
          secret: _secret.text.trim(),
        );
    if (!mounted) return;
    setState(() => _step = _Step.done);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.selfHostedTitle)),
      body: SafeArea(
        child: switch (_step) {
          _Step.form => _buildForm(context),
          _Step.installing => _buildInstalling(context),
          _Step.done => _buildDone(context),
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxl + 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VispInput(
            controller: _address,
            label: s.serverAddress,
            hintText: s.serverAddressHint,
            errorText: _addressError,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.l),
          VispInput(
            controller: _user,
            label: s.sshUser,
            hintText: s.sshUserHint,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.l),
          VispInput(
            controller: _secret,
            label: s.sshPassword,
            errorText: _secretError,
            obscureText: _obscure,
            maxLines: _obscure ? 1 : 6,
            minLines: 1,
            suffixIcon: VispIconButton(
              icon: _obscure ? VispIcons.lock : VispIcons.info,
              tooltip: _obscure ? 'Показать' : 'Скрыть',
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _NoteCard(
            icon: VispIcons.key,
            text: s.sshKeyNote,
          ),
          const SizedBox(height: AppSpacing.l),
          VispButton(
            label: s.continueWord,
            icon: VispIcons.server,
            expanded: true,
            onPressed: _install,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            s.privacyNote,
            style: AppTextStyles.small.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          VispCard(
            padding: EdgeInsets.zero,
            child: VispListRow(
              title: s.howToVpn,
              description: 'Где взять данные для подключения и VPS',
              icon: VispIcons.info,
              onTap: () => VispToast.show(
                context,
                'Инструкции: github.com/absurdstudios/visp',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstalling(BuildContext context) {
    final s = context.s;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.l),
            Text(s.installProgress, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Проверка соединения, отпечатка сервера и совместимости системы',
              style: AppTextStyles.small.copyWith(
                color: SemanticColors.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
    final s = context.s;
    final state = context.watch<AppState>();
    final host = state.selectedHost;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VispIcon(
              VispIcons.checkCircle,
              size: 48,
              color: SemanticColors.of(context).accent,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(s.installDone, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.s),
            Text(
              host != null
                  ? '${host.name} · ${host.address}\nAmneziaWG добавлен в список серверов'
                  : 'Профили добавлены в список серверов',
              style: AppTextStyles.body.copyWith(
                color: SemanticColors.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            VispButton(
              label: s.done,
              icon: VispIcons.check,
              expanded: true,
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
            ),
            const SizedBox(height: AppSpacing.s),
            VispButton(
              label: s.studio,
              style: VispButtonStyle.secondary,
              icon: VispIcons.studio,
              expanded: true,
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
                context.read<AppState>().setStudioPinned(true);
                VispToast.show(context, s.studioInNav);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.icon, required this.text});

  final VispIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadius.mAll,
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VispIcon(icon, size: 18, color: colors.warning),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.small.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
