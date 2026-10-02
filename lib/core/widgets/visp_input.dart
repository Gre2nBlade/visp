import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'visp_focus_ring.dart';

/// Поле ввода Visp: подпись над полем, helper/error-текст под полем,
/// видимое кольцо фокуса, не плейсхолдер-only подписи (DESIGN.md, «Input»).
class VispInput extends StatelessWidget {
  const VispInput({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.xs + 2,
            left: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
        ),
        VispFocusRing(
          borderRadius: AppRadius.sAll,
          child: Material(
            color: hasError
                ? colors.danger.withValues(alpha: 0.08)
                : colors.surface2,
            borderRadius: AppRadius.mAll,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadius.mAll,
                border: Border.all(
                  color: hasError ? colors.danger : colors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (prefixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.m,
                        top: maxLines > 1 ? AppSpacing.m : 0,
                      ),
                      child: prefixIcon!,
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: enabled,
                      obscureText: obscureText,
                      maxLines: maxLines,
                      minLines: minLines,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      autofocus: autofocus,
                      inputFormatters: inputFormatters,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      cursorColor: colors.primary,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: AppTextStyles.body.copyWith(
                          color: colors.textSecondary.withValues(alpha: 0.6),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.m - 2,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (suffixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s),
                      child: suffixIcon!,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (helperText != null || errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs + 2,
              left: AppSpacing.xs,
            ),
            child: Text(
              errorText ?? helperText!,
              style: AppTextStyles.small.copyWith(
                color: hasError ? colors.danger : colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
