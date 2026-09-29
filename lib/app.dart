import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/visp_theme.dart';
import 'core/widgets/blup_visp.dart';
import 'features/navigation/root_shell.dart';
import 'l10n/strings.dart';
import 'state/app_state.dart';
import 'state/preferences.dart';

class VispApp extends StatelessWidget {
  const VispApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final themeMode = switch (state.themeMode) {
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
        };

        return MaterialApp(
          title: 'Visp',
          debugShowCheckedModeBanner: false,
          theme: VispTheme.light(),
          darkTheme: VispTheme.dark(),
          themeMode: themeMode,
          locale: state.locale,
          supportedLocales: const [
            Locale('ru'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            if (!state.isInitialized) {
              return const _Splash();
            }
            return child!;
          },
          home: const RootShell(),
        );
      },
    );
  }
}

/// Короткая заставка на время загрузки настроек. Проверка обновлений при
/// запуске не задерживает доступ к сохранённым подключениям (раздел 1, 15).
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.dark.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BlupVisp(
              status: BlupStatus.idle,
              size: 120,
              motionReduced: false,
            ),
            const SizedBox(height: 24),
            Text(
              'Visp',
              style: AppTextStyles.display.copyWith(
                color: SemanticColors.dark.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
