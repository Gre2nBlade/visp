import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/feedback/haptics.dart';
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
import '../services/code_importer.dart';
import 'import_preview_screen.dart';
import 'selfhosted_screen.dart';

/// Разделы экрана добавления подключения (раздел 6).
enum AddSection { key, selfHosted, file, qr, subscription }

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({super.key, this.initialSection = AddSection.key});

  /// Открывает экран добавления подключения.
  static Future<void> open(
    BuildContext context, {
    AddSection initialSection = AddSection.key,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddConnectionScreen(initialSection: initialSection),
      ),
    );
  }

  /// Разбирает код и открывает предпросмотр импорта.
  /// Возвращает true, если подключения были добавлены.
  static Future<bool?> openWithPreview(
    BuildContext context,
    String code,
  ) async {
    final preview = CodeImporter.parse(code);
    if (preview.kind == ImportKind.unknown) {
      VispToast.showError(context, context.s.formatUnsupported);
      return false;
    }
    if (preview.kind == ImportKind.devActivation) {
      final state = context.read<AppState>();
      final ok = await state.activateDevCode(code);
      if (!context.mounted) return false;
      if (ok) {
        // Только toast «Код активирован»: поле очищается, экран остаётся
        // прежним, VPN и список подключений не меняются (раздел 13.2).
        VispToast.show(context, context.s.activationSuccess);
      } else {
        VispToast.showError(context, context.s.invalidCode);
      }
      return false;
    }
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ImportPreviewScreen(preview: preview, rawCode: code),
      ),
    );
  }

  final AddSection initialSection;

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  late final TextEditingController _codeController;
  late final FocusNode _codeFocus;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeFocus = FocusNode();
    if (widget.initialSection != AddSection.key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openSection(widget.initialSection);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final value = _codeController.text.trim();
    if (value.isEmpty) return;
    setState(() => _codeError = null);
    final result =
        await AddConnectionScreen.openWithPreview(context, value);
    if (result == true && mounted) {
      _codeController.clear();
    }
  }

  void _openSection(AddSection section) {
    switch (section) {
      case AddSection.key:
        _codeFocus.requestFocus();
      case AddSection.selfHosted:
        SelfhostedScreen.open(context);
      case AddSection.file:
        _showFilePickerNote();
      case AddSection.qr:
        _showQrSheet();
      case AddSection.subscription:
        _showSubscriptionSheet();
    }
  }

  void _showFilePickerNote() {
    VispToast.showError(
      context,
      'Выбор файла конфигурации: OpenVPN, WireGuard и совместимые конфиги',
      actionLabel: context.s.paste,
      onAction: () => _codeFocus.requestFocus(),
    );
  }

  /// QR-сканер запрашивает камеру только на время сканирования (раздел 18).
  /// В первой версии доступен ручной ввод распознанного кода.
  void _showQrSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = SemanticColors.of(context);
        final s = context.s;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.qrCode, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Сканер запросит камеру только на время сканирования. '
                  'Если сканирование недоступно, вставьте распознанный код.',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                VispButton(
                  label: '${s.paste} код',
                  icon: VispIcons.paste,
                  expanded: true,
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    final text = (data?.text ?? '').trim();
                    if (!context.mounted) return;
                    if (text.isEmpty) {
                      VispToast.showError(context, context.s.noData);
                      return;
                    }
                    Navigator.of(context).pop();
                    _codeController.text = text;
                    await _submitCode();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubscriptionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = SemanticColors.of(context);
        final s = context.s;
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface1,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.l),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.subscription, style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'base64, Clash YAML, sing-box JSON, Xray JSON. '
                    'Адрес подписки с токеном считается секретом.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  VispInput(
                    controller: controller,
                    label: s.subscription,
                    hintText: 'https://example.com/sub/…',
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) return;
                      Navigator.of(context).pop();
                      _codeController.text = value.trim();
                      _submitCode();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.addConnection),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
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
              controller: _codeController,
              focusNode: _codeFocus,
              label: s.pasteKey,
              hintText: s.pasteKeyHint,
              errorText: _codeError,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.go,
              onChanged: (_) {
                if (_codeError != null) setState(() => _codeError = null);
              },
              onSubmitted: (_) => _submitCode(),
              suffixIcon: VispButton.compact(
                label: s.paste,
                icon: VispIcons.paste,
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  final text = (data?.text ?? '').trim();
                  if (!context.mounted) return;
                  if (text.isEmpty) {
                    VispToast.showError(context, context.s.noData);
                    return;
                  }
                  _codeController.text = text;
                  Haptics.selection(context);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            VispButton(
              label: s.continueWord,
              icon: VispIcons.key,
              expanded: true,
              onPressed: _submitCode,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(text: s.otherOptions),
            const SizedBox(height: AppSpacing.m),
            VispCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  VispListRow(
                    title: s.selfHosted,
                    description: s.selfHostedDesc,
                    icon: VispIcons.server,
                    onTap: () => SelfhostedScreen.open(context),
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.configFile,
                    description: s.configFileDesc,
                    icon: VispIcons.file,
                    onTap: _showFilePickerNote,
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.qrCode,
                    description: s.qrCodeDesc,
                    icon: VispIcons.qr,
                    onTap: _showQrSheet,
                  ),
                  _divider(context),
                  VispListRow(
                    title: s.subscription,
                    description: s.subscriptionDesc,
                    icon: VispIcons.refresh,
                    onTap: _showSubscriptionSheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.small.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
