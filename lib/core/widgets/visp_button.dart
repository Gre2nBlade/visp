import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'visp_focus_ring.dart';

enum VispButtonStyle {
  /// Основная заполненная шалфейная кнопка.
  primary,

  /// Вторичная с рамкой.
  secondary,

  /// Третичная текстовая.
  tertiary,

  /// Деструктивная.
  danger,
}

enum VispButtonSize { compact, regular, prominent }

/// Кнопка Visp.
///
/// Стили по DESIGN.md: primary — заполненная акцентом, secondary — с рамкой,
/// tertiary — текстовая. Деструктивное действие требует подтверждения
/// диалогом — для него есть [VispButton.destructive].
class VispButton extends StatefulWidget {
  const VispButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = VispButtonStyle.primary,
    this.size = VispButtonSize.regular,
    this.icon,
    this.expanded = false,
    this.loading = false,
    this.confirmTitle,
    this.confirmMessage,
    this.onConfirmed,
  });

  const VispButton.compact({
    super.key,
    required this.label,
    this.onPressed,
    this.style = VispButtonStyle.primary,
    this.icon,
    this.loading = false,
    this.confirmTitle,
    this.confirmMessage,
    this.onConfirmed,
    this.expanded = false,
  })  : size = VispButtonSize.compact;

  /// Деструктивная кнопка: показывает подтверждение перед действием.
  const VispButton.destructive({
    super.key,
    required this.label,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.onConfirmed,
    this.size = VispButtonSize.regular,
    this.expanded = false,
  })  : style = VispButtonStyle.danger,
        icon = null,
        loading = false,
        onPressed = null;

  final String label;
  final VoidCallback? onPressed;
  final VispButtonStyle style;
  final VispButtonSize size;
  final VispIcons? icon;
  final bool expanded;
  final bool loading;

  final String? confirmTitle;
  final String? confirmMessage;
  final VoidCallback? onConfirmed;

  double get _height {
    switch (size) {
      case VispButtonSize.compact:
        return AppControlHeight.compact;
      case VispButtonSize.regular:
        return AppControlHeight.regular;
      case VispButtonSize.prominent:
        return AppControlHeight.prominent;
    }
  }

  @override
  State<VispButton> createState() => _VispButtonState();
}

class _VispButtonState extends State<VispButton> {
  bool _confirming = false;

  void _handle() async {
    if (widget.onConfirmed != null) {
      Haptics.medium(context);
      final confirmed = await _confirm();
      if (confirmed && mounted) {
        widget.onConfirmed!();
      }
      return;
    }
    widget.onPressed?.call();
  }

  Future<bool> _confirm() async {
    setState(() => _confirming = true);
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _DestructiveDialog(
          title: widget.confirmTitle!,
          message: widget.confirmMessage ?? '',
          confirmLabel: widget.label,
        ),
      );
      return result ?? false;
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final isDisabled = widget.onPressed == null &&
        widget.onConfirmed == null &&
        !widget.loading;

    Color? fg;
    Color? bg;
    Color? borderColor;
    switch (widget.style) {
      case VispButtonStyle.primary:
        fg = colors.background;
        bg = colors.primary;
        break;
      case VispButtonStyle.secondary:
        fg = colors.textPrimary;
        bg = Colors.transparent;
        borderColor = colors.border;
        break;
      case VispButtonStyle.tertiary:
        fg = colors.primary;
        bg = Colors.transparent;
        break;
      case VispButtonStyle.danger:
        fg = colors.danger;
        bg = Colors.transparent;
        borderColor = colors.danger.withValues(alpha: 0.4);
        break;
    }

    final button = SizedBox(
      height: widget._height,
      child: Material(
        color: bg,
        borderRadius: AppRadius.mAll,
        child: InkWell(
          onTap: isDisabled || widget.loading || _confirming ? null : _handle,
          borderRadius: AppRadius.mAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else if (widget.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs + 2),
                    child: VispIcon(widget.icon!, size: 18, color: fg),
                  ),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.button.copyWith(color: fg),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final withBorder = borderColor != null
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mAll,
              border: Border.all(color: borderColor),
            ),
            child: button,
          )
        : button;

    final focusable = VispFocusRing(
      radius: AppRadius.mAll,
      child: withBorder,
    );

    return widget.expanded
        ? Row(children: [Expanded(child: focusable)])
        : focusable;
  }
}

class _DestructiveDialog extends StatelessWidget {
  const _DestructiveDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return AlertDialog(
      backgroundColor: colors.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lAll,
        side: BorderSide(color: colors.border),
      ),
      title: Text(title, style: AppTextStyles.h1),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: AppTextStyles.button.copyWith(color: colors.danger),
          ),
        ),
      ],
    );
  }
}
