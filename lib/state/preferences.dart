import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }
enum UpdateChannel { stable, beta }
enum HapticPref { auto, minimal, off }

/// Режим поверхностного материала (раздел 11.2).
///
/// Два состояния: обычный материал и стекло. Матовое стекло убрано — на
/// устройстве оно не читалось как отдельный материал и только путало
/// с обычным, поэтому выбор свёрнут до понятного «стекло / нет».
enum GlassMode {
  none('Без стекла'),
  regular('Стекло');

  final String label;
  const GlassMode(this.label);
}

/// Локально сохранённые предпочтения.
///
/// Настройки хранятся между запусками: закрепление Studio, тема, стекло,
/// тактильная отдача, состояние плагинов и видимость debug-блока.
class Preferences {
  Preferences._();

  static SharedPreferences? _sp;

  static Future<void> load() async {
    _sp = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    final sp = _sp;
    assert(sp != null, 'Preferences.load() must be called before use');
    return sp!;
  }

  static const _keyThemeMode = 'visp.themeMode';
  static const _keyHaptics = 'visp.haptics';
  static const _keyGlass = 'visp.glassMode';
  static const _keyGlassLegacy = 'visp.glass';
  static const _keyStudioPinned = 'visp.studioPinned';
  static const _keyProxyInstalled = 'visp.proxyInstalled';
  static const _keyDevRole = 'visp.devRole';
  static const _keyDebugVisible = 'visp.debugVisible';
  static const _keyNavLabels = 'visp.navLabels';
  static const _keyLocale = 'visp.locale';
  static const _keyKillSwitch = 'visp.killSwitch';
  static const _keyAutostart = 'visp.autostart';
  static const _keySplitTunneling = 'visp.splitTunneling';
  static const _keyScreenshots = 'visp.screenshots';
  static const _keyChannel = 'visp.updateChannel';

  static AppThemeMode get themeMode {
    switch (_p.getString(_keyThemeMode)) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  static set themeMode(AppThemeMode v) =>
      _p.setString(_keyThemeMode, v.name);

  static HapticPref get haptics {
    switch (_p.getString(_keyHaptics)) {
      case 'minimal':
        return HapticPref.minimal;
      case 'off':
        return HapticPref.off;
      default:
        return HapticPref.auto;
    }
  }

  static set haptics(HapticPref v) => _p.setString(_keyHaptics, v.name);

/// Режим стекла. Старое булево значение мигрирует в режим, чтобы
/// предыдущий выбор пользователя не потерялся.
static GlassMode get glassMode {
  final stored = _p.getString(_keyGlass);
  for (final mode in GlassMode.values) {
    if (mode.name == stored) return mode;
  }
  // Миграция: прежний тумблер «стекло» вкл/выкл.
  final legacy = _p.getBool(_keyGlassLegacy) ?? true;
  return legacy ? GlassMode.regular : GlassMode.none;
}

static set glassMode(GlassMode v) => _p.setString(_keyGlass, v.name);

/// Совместимое чтение старого флага: стекло включено в любом из режимов.
static bool get glass => glassMode != GlassMode.none;
static set glass(bool v) =>
    _p.setString(_keyGlass, (v ? GlassMode.regular : GlassMode.none).name);

  static bool get studioPinned => _p.getBool(_keyStudioPinned) ?? false;
  static set studioPinned(bool v) => _p.setBool(_keyStudioPinned, v);

  static bool get proxyInstalled => _p.getBool(_keyProxyInstalled) ?? false;
  static set proxyInstalled(bool v) => _p.setBool(_keyProxyInstalled, v);

  static bool get devRole => _p.getBool(_keyDevRole) ?? false;
  static set devRole(bool v) => _p.setBool(_keyDevRole, v);

  static bool get debugVisible => _p.getBool(_keyDebugVisible) ?? false;
  static set debugVisible(bool v) => _p.setBool(_keyDebugVisible, v);

  /// Подписи вкладок в навигации. По умолчанию показываются.
  static bool get navLabels => _p.getBool(_keyNavLabels) ?? true;
  static set navLabels(bool v) => _p.setBool(_keyNavLabels, v);

  /// 'ru' или 'en'; null — системный язык.
  static String? get locale => _p.getString(_keyLocale);
  static set locale(String? v) {
    if (v == null) {
      _p.remove(_keyLocale);
    } else {
      _p.setString(_keyLocale, v);
    }
  }

  static bool get killSwitch => _p.getBool(_keyKillSwitch) ?? false;
  static set killSwitch(bool v) => _p.setBool(_keyKillSwitch, v);

  static bool get autostart => _p.getBool(_keyAutostart) ?? false;
  static set autostart(bool v) => _p.setBool(_keyAutostart, v);

  static bool get splitTunneling => _p.getBool(_keySplitTunneling) ?? false;
  static set splitTunneling(bool v) => _p.setBool(_keySplitTunneling, v);

  static bool get screenshotsAllowed => _p.getBool(_keyScreenshots) ?? true;
  static set screenshotsAllowed(bool v) => _p.setBool(_keyScreenshots, v);

  static UpdateChannel get updateChannel {
    return _p.getString(_keyChannel) == 'beta'
        ? UpdateChannel.beta
        : UpdateChannel.stable;
  }

  static set updateChannel(UpdateChannel v) =>
      _p.setString(_keyChannel, v.name);

  static Future<void> resetAll() async {
    await _p.clear();
  }
}
