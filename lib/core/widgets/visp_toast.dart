import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Тост подтверждения завершённого локального действия.
///
/// Ошибки дополняются действием «next action»: [showError] принимает
/// кнопку повтора или выбора другого подключения.
class VispToast {
  VispToast._();

  static void show(
    BuildContext context,
    String message, {
    VispToastTone tone = VispToastTone.neutral,
  }) {
    _show(context, message, tone, null);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Кнопка действия появляется только вместе с обработчиком: подпись без
    // обработчика приводила к падению на `onAction!`, и ошибка оставалась
    // без сообщения — пользователь не понимал, что произошло.
    _show(
      context,
      message,
      VispToastTone.danger,
      (actionLabel != null && onAction != null)
          ? (actionLabel, onAction)
          : null,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    VispToastTone tone,
    (String, VoidCallback)? action,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: action != null
              ? const Duration(seconds: 6)
              : const Duration(seconds: 3),
          content: _Content(message: message, tone: tone),
          action: action == null
              ? null
              : SnackBarAction(
                  label: action.$1,
                  onPressed: action.$2,
                ),
        ),
      );
  }
}

enum VispToastTone { neutral, accent, danger, warning }

class _Content extends StatelessWidget {
  const _Content({required this.message, required this.tone});

  final String message;
  final VispToastTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final color = switch (tone) {
      VispToastTone.neutral => colors.textPrimary,
      VispToastTone.accent => colors.primary,
      VispToastTone.danger => colors.danger,
      VispToastTone.warning => colors.warning,
    };
    return Row(
      children: [
        Expanded(child: Text(message)),
        Icon(tone == VispToastTone.neutral ? Icons.check : Icons.info_outline,
            size: 16, color: color),
      ],
    );
  }
}
