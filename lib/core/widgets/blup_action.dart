import 'package:flutter/material.dart';

import '../feedback/haptics.dart';
import '../icons/visp_icon.dart';
import '../theme/app_colors.dart';
import 'blup_visp.dart';
import '../../l10n/strings.dart';

/// Круглое действие в центре Blup Visp (раздел 4.1, 8.1).
///
/// Кнопка лежит внутри фигуры, поэтому главное действие не уводит взгляд
/// с блупа. Состояние читается по форме, цвету и подписи, а не по одному
/// цвету: у каждого состояния своя иконка.
class BlupAction extends StatelessWidget {
  const BlupAction({
    super.key,
    required this.status,
    required this.onTap,
    required this.onCancel,
    this.size = 78,
  });

  final BlupStatus status;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  /// Диаметр действия. Достаточен для касания ≥ 48 dp.
  final double size;

  /// Иконка состояния: подключение, отмена, готовность.
  VispIcons get _icon {
    switch (status) {
      case BlupStatus.idle:
      case BlupStatus.connected:
      case BlupStatus.blocked:
        return VispIcons.plug;
      case BlupStatus.preparing:
      case BlupStatus.checking:
      case BlupStatus.connecting:
      case BlupStatus.reconnecting:
        return VispIcons.close;
      case BlupStatus.error:
        return VispIcons.refresh;
    }
  }

  /// Подсказка для скринридера: действие и его результат.
  String _label(S s) {
    switch (status) {
      case BlupStatus.idle:
        return s.connect;
      case BlupStatus.connected:
        return s.disconnect;
      case BlupStatus.preparing:
      case BlupStatus.checking:
      case BlupStatus.connecting:
      case BlupStatus.reconnecting:
        return s.cancelConnection;
      case BlupStatus.error:
        return s.retry;
      case BlupStatus.blocked:
        return s.unblock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final s = context.s;
    final isBusy = status == BlupStatus.preparing ||
        status == BlupStatus.checking ||
        status == BlupStatus.connecting ||
        status == BlupStatus.reconnecting;
    final isConnected = status == BlupStatus.connected;
    final isError = status == BlupStatus.error;

    // Кольцо совпадает с цветом состояния фигуры, поэтому кнопка читается
    // как часть блупа, а не как чужой элемент поверх него.
    final ringColor = isError
        ? colors.danger
        : isConnected
            ? colors.primary
            : isBusy
                ? colors.primaryBright
                : colors.textSecondary;

    final isRunning = _isSpinning(status);

    return Semantics(
      button: true,
      label: _label(s),
      child: Tooltip(
        message: _label(s),
        child: SizedBox(
          width: size,
          height: size,
          child: Material(
            color: colors.background.withValues(alpha: 0.55),
            shape: CircleBorder(
              side: BorderSide(
                color: ringColor.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Haptics.light(context);
                if (isBusy) {
                  onCancel();
                } else {
                  onTap();
                }
              },
child: Center(
                  // Во время установки прогресс показывает дуга по кольцу
                  // фигуры, поэтому здесь остаётся только иконка: два
                  // индикатора прогресса рядом выглядели бы дублем.
                  child: isRunning
                      ? SizedBox(
                          key: const ValueKey('busy'),
                          width: size * 0.30,
                          height: size * 0.30,
                        )
                      : VispIcon(
                          _icon,
                          key: const ValueKey('icon'),
                          size: size * 0.36,
                          color: ringColor,
                        ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  /// Вращение в фазах установки: так видно, что процесс идёт.
  static bool _isSpinning(BlupStatus status) =>
      status == BlupStatus.preparing ||
      status == BlupStatus.checking ||
      status == BlupStatus.connecting ||
      status == BlupStatus.reconnecting;
}