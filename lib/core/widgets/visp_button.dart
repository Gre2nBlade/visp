import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'visp_focus_ring.dart';

enum VispButtonStyle {
  /// Главное действие: заливка акцентом.
  primary,

  /// Второстепенное: прозрачный фон, волосяная рамка.
  secondary,

  /// Текстовое действие без рамки.
  tertiary,

  /// Разрушающее действие.
  danger,
}

enum VispButtonSize { compact, regular, prominent }

/// Кнопка Visp в духе Amnezia Client.
///
/// Плоская: без теней, глубину создаёт волосяная рамка в 1 px. Базовый
/// радиус 16. Нажатие даёт и смену цвета, и лёгкое сжатие до 0.96 —
/// отклик виден и пальцем, и глазом.
class VispButton extends StatefulWidget {
  const VispButton({
    super.key,
    required this.label,
    this.style = VispButtonStyle.primary,
    this.size = VispButtonSize.regular,
    this.icon,
    this.onPressed,
    this.onConfirmed,
    this.confirmTitle,
    this.confirmMessage,
    this.expanded = false,
    this.loading = false,
  });

  /// Компактная кнопка для вспомогательных действий.
  const VispButton.compact({
    super.key,
    required this.label,
    this.style = VispButtonStyle.secondary,
    this.icon,
    this.onPressed,
    this.onConfirmed,
    this.confirmTitle,
    this.confirmMessage,
    this.expanded = false,
    this.loading = false,
  }) : size = VispButtonSize.compact;

  /// Разрушающее действие с подтверждением.
  const VispButton.destructive({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.onConfirmed,
    this.confirmTitle,
    this.confirmMessage,
    this.expanded = false,
    this.loading = false,
  })  : style = VispButtonStyle.danger,
        size = VispButtonSize.regular;

  final String label;
  final VispButtonStyle style;
  final VispButtonSize size;
  final VispIcons? icon;
  final VoidCallback? onPressed;

  /// Если задано, нажатие сначала спрашивает подтверждение.
  final VoidCallback? onConfirmed;
  final String? confirmTitle;
  final String? confirmMessage;

  final bool expanded;
  final bool loading;

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
  bool _pressed = false;

  /// Защита от повторного нажатия, пока открыт диалог подтверждения.
  bool _handling = false;

  bool get _isDisabled =>
      widget.onPressed == null && widget.onConfirmed == null || widget.loading;

  Future<void> _handle() async {
    if (widget.onPressed == null && widget.onConfirmed == null) return;
    if (_handling) return;
    _handling = true;
    Haptics.light(context);

    try {
      if (widget.onConfirmed == null) {
        widget.onPressed?.call();
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: SemanticColors.of(dialogContext).popover,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.sAll,
          ),
          title: widget.confirmTitle == null
              ? null
              : Text(
                  widget.confirmTitle!,
                  style: AppTextStyles.h2Strong.copyWith(
                    color: SemanticColors.of(dialogContext).foreground,
                  ),
                ),
          content: widget.confirmMessage == null
              ? null
              : Text(
                  widget.confirmMessage!,
                  style: AppTextStyles.label.copyWith(
                    color: SemanticColors.of(dialogContext).mutedForeground,
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor:
                    SemanticColors.of(dialogContext).mutedForeground,
              ),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor:
                    SemanticColors.of(dialogContext).destructive,
              ),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      );

      if (confirmed == true) widget.onConfirmed?.call();
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final disabled = _isDisabled;

    // Акцент в Amnezia — янтарный; нажатое состояние уходит в burntOrange,
    // отключённое — в приглушённый тон, а не просто в прозрачность.
    Color fg;
    Color bg;
    Color? borderColor;
    switch (widget.style) {
      case VispButtonStyle.primary:
        fg = colors.primaryForeground;
        bg = _pressed ? colors.primaryPressed : colors.primary;
        break;
      case VispButtonStyle.secondary:
        fg = disabled ? colors.mutedForeground : colors.foreground;
        bg = _pressed ? colors.accent : Colors.transparent;
        borderColor = disabled ? colors.border : colors.borderStrong;
        break;
      case VispButtonStyle.tertiary:
        fg = disabled ? colors.mutedForeground : colors.primary;
        bg = _pressed ? colors.accent : Colors.transparent;
        break;
      case VispButtonStyle.danger:
        fg = disabled ? colors.mutedForeground : colors.destructive;
        bg = _pressed ? colors.destructive.withValues(alpha: 0.12)
            : Colors.transparent;
        borderColor = colors.destructive.withValues(alpha: 0.5);
        break;
    }

    if (disabled && widget.style == VispButtonStyle.primary) {
      bg = colors.muted;
      fg = colors.mutedForeground;
    }

    final radius = BorderRadius.circular(AppRadius.s);

    Widget content = Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: disabled || _handling ? null : _handle,
        borderRadius: radius,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
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
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: VispIcon(
                    widget.icon!,
                    size: 20,
                    color: fg,
                    filled: widget.style == VispButtonStyle.primary,
                  ),
                ),
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.button.copyWith(color: fg),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Плоская кнопка: рамка вместо тени. Она же работает как фокус-кольцо.
    if (borderColor != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: borderColor),
        ),
        child: content,
      );
    }

    if (!disabled) {
      content = VispFocusRing(
        borderRadius: radius,
        child: content,
      );
    }

    // Лёгкое сжатие при нажатии: 0.96 — заметно, но не преувеличено.
    return Semantics(
      button: true,
      enabled: !disabled,
      child: AnimatedScale(
        scale: _pressed && !disabled ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.expanded
            ? SizedBox(width: double.infinity, height: widget._height, child: content)
            : SizedBox(height: widget._height, child: content),
      ),
    );
  }
}