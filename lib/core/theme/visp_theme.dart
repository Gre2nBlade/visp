import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Тема Visp: семантические цвета, типографика, радиусы и отступы.
///
/// Mynaui Icons спрятаны за адаптером [VispIcon], поэтому прямые обращения
/// к Material-иконкам в feature-коде не нужны.
class VispTheme {
  VispTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final colors =
        brightness == Brightness.dark ? SemanticColors.dark : SemanticColors.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF0B1410)
          : Colors.white,
      secondary: colors.accentBright,
      onSecondary: brightness == Brightness.dark
          ? const Color(0xFF0B1410)
          : Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.surface1,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surface2,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      splashFactory: NoSplash.splashFactory,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.small,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
      ),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 20,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: AppRadius.sAll,
          border: Border.all(color: colors.border),
        ),
        textStyle: AppTextStyles.small.copyWith(color: colors.textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surface2,
        contentTextStyle: AppTextStyles.body.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mAll,
          side: BorderSide(color: colors.border),
        ),
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          96,
        ),
      ),
    );
  }
}
