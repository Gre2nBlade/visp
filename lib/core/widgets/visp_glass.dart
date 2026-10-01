import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Материал Visp (раздел 11.2): настоящее стекло и матовое стекло.
///
/// Настоящее стекло преломляет то, что под ним, и используется только для
/// навигационного слоя: капсула, кнопка «+», шторка серверов. Матовое
/// стекло (`LiquidGlassLite`) — облегчённый вариант без шейдера, поэтому
/// подходит для небольших панелей и слабых устройств.
///
/// Содержимое остаётся резким: текст и цифры никогда не размываются.
class VispGlass extends StatelessWidget {
  const VispGlass({
    super.key,
    required this.child,
    this.enabled = true,
    this.radius = 24,
    this.blurSigma = 12,
    this.matte = false,
    this.padding,
    this.distortion = 0.06,
  });

  final Widget child;

  /// Выключено — обычная поверхность без стекла.
  final bool enabled;

  final double radius;

  /// Сила размытия для матового стекла.
  final double blurSigma;

  /// Матовое стекло: без преломления, только иней и световой край.
  final bool matte;

  final EdgeInsetsGeometry? padding;

  /// Сила преломления для настоящего стекла.
  final double distortion;

  @override
  Widget build(BuildContext context) {
    final content = padding == null ? child : Padding(padding: padding!, child: child);

    // Выключенное стекло — обычная поверхность темы, без лишней работы GPU.
    if (!enabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: SemanticColors.of(context).surface1,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: SemanticColors.of(context).border),
        ),
        child: content,
      );
    }

    final shape = LiquidGlassShape.continuousRoundedRectangle(
      cornerRadius: radius,
    );

    if (matte) {
      return LiquidGlassLite(
        shape: shape,
        blur: LiquidGlassBlur(sigmaX: blurSigma, sigmaY: blurSigma),
        color: _matteColor(context),
        child: content,
      );
    }

    return LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: shape,
        refraction: LiquidGlassRefraction(
          distortion: distortion,
          distortionWidth: 24,
        ),
      ),
      child: content,
    );
  }

  /// Цвет матового стекла чуть плотнее, чтобы текст поверх оставался
  /// контрастным: иней не должен съедать читаемость.
  Color? _matteColor(BuildContext context) {
    final colors = SemanticColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? colors.card.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.78);
  }
}

/// Плавающая капсула навигации: стекло поверх прокручиваемого содержимого.
///
/// Спека 11.2: «Для Visp стекло прежде всего подходит навигационной капсуле».
class VispGlassCapsule extends StatelessWidget {
  const VispGlassCapsule({
    super.key,
    required this.child,
    this.enabled = true,
    this.radius = 28,
    this.padding,
  });

  final Widget child;
  final bool enabled;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return VispGlass(
      enabled: enabled,
      radius: radius,
      // Капсула плавает над контентом: чуть сильнее преломление и иней.
      blurSigma: 16,
      padding: padding,
      child: child,
    );
  }
}

/// Небольшая матовая панель: чтение, сводка, отладочные значения.
///
/// Матовое стекло выбрано осознанно: панель часто прокручивается вместе с
/// контентом, и полноценное преломление внутри списка даёт артефакты.
class VispGlassPanel extends StatelessWidget {
  const VispGlassPanel({
    super.key,
    required this.child,
    this.enabled = true,
    this.radius = AppRadius.lAll,
    this.padding = const EdgeInsets.all(AppSpacing.l),
  });

  final Widget child;
  final bool enabled;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return VispGlass(
      enabled: enabled,
      matte: true,
      radius: 16,
      padding: padding,
      child: child,
    );
  }
}
