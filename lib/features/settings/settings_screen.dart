import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/icons/visp_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/visp_list_row.dart';
import '../../core/widgets/visp_switch.dart';
import '../../core/widgets/visp_toast.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../state/preferences.dart';
import 'about_screen.dart';
import 'connection_settings_screen.dart';
import 'personalization_screen.dart';
import 'plugins_screen.dart';
import 'studio_screen.dart';

/// Настройки (раздел 10). Группы: Studio, Соединение, Плагины, Обновления,
/// Тактильная отдача, Персонализация, Приложение, О приложении.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl + 56),
          children: [
            VispSectionHeader(text: s.studio),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.studio,
                  description: s.studioDesc,
                  icon: VispIcons.studio,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => StudioScreen.open(context),
                ),
                _SwitchRow(
                  title: s.studioInNav,
                  description: s.studioInNavDesc,
                  icon: VispIcons.studio,
                  value: state.studioPinned,
                  onChanged: state.setStudioPinned,
                ),
              ],
            ),
            VispSectionHeader(text: s.groupConnection),
            VispListGroup(
              children: [
                _SwitchRow(
                  title: s.killSwitch,
                  description: s.killSwitchDesc,
                  icon: VispIcons.shieldCheck,
                  value: state.killSwitch,
                  onChanged: state.setKillSwitch,
                ),
                _SwitchRow(
                  title: s.autostart,
                  description: s.autostartDesc,
                  icon: VispIcons.plug,
                  value: state.autostart,
                  onChanged: state.setAutostart,
                ),
                VispListRow(
                  title: s.alwaysOn,
                  description: s.alwaysOnDesc,
                  icon: VispIcons.lock,
                  onTap: () => VispToast.show(
                    context,
                    'Always-on включается в системных настройках устройства',
                  ),
                ),
                VispListRow(
                  title: s.dns,
                  description: s.dnsDesc,
                  icon: VispIcons.globe,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => ConnectionSettingsScreen.open(context),
                ),
                VispListRow(
                  title: s.splitTunneling,
                  icon: VispIcons.route,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  description: state.splitTunneling
                      ? s.splitTunnelingOn
                      : s.splitTunnelingOff,
                  onTap: () => ConnectionSettingsScreen.open(context),
                ),
              ],
            ),
            VispSectionHeader(text: s.groupPlugins),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.groupPlugins,
                  description: s.pluginsDesc,
                  icon: VispIcons.plugins,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => PluginsScreen.open(context),
                ),
              ],
            ),
            VispSectionHeader(text: s.groupUpdates),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.groupUpdates,
                  description: state.updateChannel == UpdateChannel.beta
                      ? s.beta
                      : s.stable,
                  icon: VispIcons.refresh,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => PersonalizationScreen.openUpdates(context),
                ),
              ],
            ),
            VispSectionHeader(text: s.groupHaptics),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.groupHaptics,
                  description: s.hapticsDesc,
                  icon: VispIcons.signal,
                  trailing: _HapticsSegment(),
                ),
              ],
            ),
            VispSectionHeader(text: s.groupPersonalization),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.theme,
                  description: _themeLabel(state.themeMode, s),
                  icon: VispIcons.theme,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => PersonalizationScreen.open(context),
                ),
                _SwitchRow(
                  title: s.glass,
                  description: s.glassDesc,
                  icon: VispIcons.shield,
                  value: state.glass,
                  onChanged: state.setGlass,
                ),
              ],
            ),
            VispSectionHeader(text: s.groupApp),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.language,
                  description: state.locale?.languageCode == 'en'
                      ? 'English'
                      : 'Русский',
                  icon: VispIcons.language,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => _showLanguageSheet(context),
                ),
                _SwitchRow(
                  title: s.screenshots,
                  description: s.screenshotsDesc,
                  icon: VispIcons.device,
                  value: state.screenshotsAllowed,
                  onChanged: state.setScreenshotsAllowed,
                ),
                VispListRow(
                  title: s.logging,
                  description: s.loggingDesc,
                  icon: VispIcons.code,
                  onTap: () => VispToast.show(context, s.logging),
                ),
                _SwitchRow(
                  title: s.debugInfo,
                  description: 'Скорость, пинг и трафик на главном экране',
                  icon: VispIcons.gauge,
                  value: state.debugVisible,
                  onChanged: state.setDebugVisible,
                ),
                VispListRow(
                  title: s.resetAll,
                  icon: VispIcons.delete,
                  destructive: true,
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
            VispSectionHeader(text: s.groupAbout),
            VispListGroup(
              children: [
                VispListRow(
                  title: s.groupAbout,
                  description: s.aboutDesc,
                  icon: VispIcons.info,
                  trailing: const VispIcon(VispIcons.chevronRight, size: 18),
                  onTap: () => AboutScreen.open(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode mode, S s) {
    switch (mode) {
      case AppThemeMode.system:
        return s.system;
      case AppThemeMode.light:
        return s.light;
      case AppThemeMode.dark:
        return s.dark;
    }
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = SemanticColors.of(context);
        final state = context.read<AppState>();
        return Container(
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
                Text(context.s.language, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.m),
                for (final entry in const [
                  ('ru', 'Русский', 'Основной язык приложения'),
                  ('en', 'English', 'English language'),
                ])
                  _LanguageRow(
                    code: entry.$1,
                    title: entry.$2,
                    subtitle: entry.$3,
                    selected: state.locale?.languageCode == entry.$1,
                    onTap: () {
                      state.setLocale(entry.$1);
                      Navigator.of(context).pop();
                    },
                  ),
                _LanguageRow(
                  code: '',
                  title: context.s.system,
                  subtitle: 'Язык устройства',
                  selected: state.locale == null,
                  onTap: () {
                    state.setLocale(null);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmReset(BuildContext context) async {
    final s = context.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SemanticColors.of(context).surface2,
        title: Text(s.resetAll),
        content: Text(s.resetAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              s.delete,
              style: AppTextStyles.button.copyWith(
                color: SemanticColors.of(context).danger,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().resetAll();
      if (context.mounted) {
        VispToast.show(context, s.done);
      }
    }
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final VispIcons icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return VispListRow(
      title: title,
      description: description,
      icon: icon,
      trailing: VispSwitch(value: value, onChanged: onChanged),
      maxLinesDescription: 2,
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: selected
                  ? VispIcon(VispIcons.checkCircle,
                      size: 18, color: colors.primary)
                  : Icon(Icons.radio_button_unchecked,
                      size: 18, color: colors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HapticsSegment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return VispSegmented<HapticPref>(
      values: HapticPref.values,
      value: state.haptics,
      labels: {
        HapticPref.auto: context.s.auto,
        HapticPref.minimal: context.s.minimal,
        HapticPref.off: context.s.off,
      },
      onChanged: state.setHaptics,
    );
  }
}
