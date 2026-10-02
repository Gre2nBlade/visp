import 'package:flutter/material.dart';

/// Семантический набор иконок Visp.
///
/// Реальные Mynaui Icons поставляются шрифтом и заменяются здесь; feature-код
/// работает только с семантическими именами, смена источника иконок не
/// расходится по приложению (DESIGN.md, «Icons»).
enum VispIcons {
  home,
  server,
  settings,
  studio,
  plugins,
  proxy,
  plus,
  shieldCheck,
  shield,
  plug,
  database,
  globe,
  route,
  refresh,
  flask,
  alert,
  check,
  checkCircle,
  file,
  qr,
  key,
  send,
  chevronDown,
  chevronRight,
  edit,
  back,
  search,
  filter,
  copy,
  paste,
  lock,
  wifi,
  signal,
  clock,
  gauge,
  download,
  upload,
  delete,
  person,
  users,
  bell,
  info,
  warning,
  link,
  mail,
  code,
  close,
  dpi,
  theme,
  language,
  security,
  device,
  bug,
  share,
  heart,
  uploadCloud,
  monitor,
}

/// Кодировка глифов MynaUI Icons (MIT).
///
/// FontPackage: mynaui · имена из packages/icons. Нумерация у начертаний
/// outline и solid совпадает, поэтому один и тот же код даёт тонкий контур
/// или заливку в зависимости от выбранного семейства.
class MynaUi {
  MynaUi._();

  /// Тонкий контур: обычные элементы интерфейса.
  static const String fontFamily = 'mynaui';

  /// Заливка: активные состояния, крупные акценты.
  static const String solidFamily = 'mynaui_solid';


  /// Заливка для произвольного глифа.
///
/// Используется только в инструментах и тестах. В release-сборке
/// tree-shaking иконок отвергает неконстантные вызовы `IconData`, поэтому
/// обычный интерфейс обязан брать иконку из [MynaUiSolid].
@visibleForTesting
static IconData solid(int codePoint) =>
    IconData(codePoint, fontFamily: solidFamily);

  static const IconData home = IconData(0xec49, fontFamily: fontFamily);
  static const IconData server = IconData(0xee32, fontFamily: fontFamily);
  static const IconData settings = IconData(0xeb55, fontFamily: fontFamily);
  static const IconData studio = IconData(0xec70, fontFamily: fontFamily);
  static const IconData plugins = IconData(0xedee, fontFamily: fontFamily);
  static const IconData proxy = IconData(0xef17, fontFamily: fontFamily);
  static const IconData plus = IconData(0xede8, fontFamily: fontFamily);
  static const IconData shieldCheck = IconData(0xee3c, fontFamily: fontFamily);
  static const IconData shield = IconData(0xee44, fontFamily: fontFamily);
  static const IconData database = IconData(0xeb7e, fontFamily: fontFamily);
  static const IconData globe = IconData(0xec18, fontFamily: fontFamily);
  static const IconData route = IconData(0xee00, fontFamily: fontFamily);
  static const IconData flask = IconData(0xebe8, fontFamily: fontFamily);
  static const IconData alert = IconData(0xeb7b, fontFamily: fontFamily);
  static const IconData check = IconData(0xeaf0, fontFamily: fontFamily);
  static const IconData checkCircle = IconData(0xeae8, fontFamily: fontFamily);
  static const IconData file = IconData(0xebd4, fontFamily: fontFamily);
  static const IconData qr = IconData(0xee1d, fontFamily: fontFamily);
  static const IconData key = IconData(0xec67, fontFamily: fontFamily);
  static const IconData send = IconData(0xee3a, fontFamily: fontFamily);
  static const IconData chevronDown = IconData(0xeafc, fontFamily: fontFamily);
  static const IconData chevronRight = IconData(0xeb04, fontFamily: fontFamily);
  static const IconData edit = IconData(0xedce, fontFamily: fontFamily);
  static const IconData back = IconData(0xea42, fontFamily: fontFamily);
  static const IconData search = IconData(0xee2f, fontFamily: fontFamily);
  static const IconData filter = IconData(0xebd9, fontFamily: fontFamily);
  static const IconData copy = IconData(0xeb61, fontFamily: fontFamily);
  static const IconData paste = IconData(0xeb22, fontFamily: fontFamily);
  static const IconData lock = IconData(0xed50, fontFamily: fontFamily);
  static const IconData wifi = IconData(0xeefc, fontFamily: fontFamily);
  static const IconData signal = IconData(0xed82, fontFamily: fontFamily);
  static const IconData clock = IconData(0xea0f, fontFamily: fontFamily);
  static const IconData gauge = IconData(0xea05, fontFamily: fontFamily);
  static const IconData download = IconData(0xeba4, fontFamily: fontFamily);
  static const IconData upload = IconData(0xeed7, fontFamily: fontFamily);
  static const IconData delete = IconData(0xeeb6, fontFamily: fontFamily);
  static const IconData person = IconData(0xeee3, fontFamily: fontFamily);
  static const IconData users = IconData(0xeee5, fontFamily: fontFamily);
  static const IconData bell = IconData(0xea81, fontFamily: fontFamily);
  static const IconData info = IconData(0xec5c, fontFamily: fontFamily);
  static const IconData warning = IconData(0xeb7b, fontFamily: fontFamily);
  static const IconData link = IconData(0xed38, fontFamily: fontFamily);
  static const IconData mail = IconData(0xed56, fontFamily: fontFamily);
  static const IconData code = IconData(0xeb4d, fontFamily: fontFamily);
  static const IconData close = IconData(0xef05, fontFamily: fontFamily);
  static const IconData dpi = IconData(0xee3c, fontFamily: fontFamily);
  static const IconData theme = IconData(0xee85, fontFamily: fontFamily);
  static const IconData language = IconData(0xec18, fontFamily: fontFamily);
  static const IconData security = IconData(0xed50, fontFamily: fontFamily);
  static const IconData device = IconData(0xed86, fontFamily: fontFamily);
  static const IconData monitor = IconData(0xed87, fontFamily: fontFamily);
  static const IconData bug = IconData(0xeb7b, fontFamily: fontFamily);
  static const IconData share = IconData(0xee3a, fontFamily: fontFamily);
  static const IconData heart = IconData(0xeb7b, fontFamily: fontFamily);
  static const IconData uploadCloud = IconData(0xeed7, fontFamily: fontFamily);
  static const IconData plug = IconData(0xef17, fontFamily: fontFamily);
  static const IconData refresh = IconData(0xee00, fontFamily: fontFamily);
}

/// Семантические имена → глифы MynaUI.
///
/// Feature-код работает только с именами: замена набора иконок не
/// расходится по приложению (DESIGN.md, «Icons»).
extension VispIconsData on VispIcons {
  IconData get data {
    switch (this) {
      case VispIcons.home:
        return MynaUi.home;
      case VispIcons.server:
        return MynaUi.server;
      case VispIcons.settings:
        return MynaUi.settings;
      case VispIcons.studio:
        return MynaUi.studio;
      case VispIcons.plugins:
        return MynaUi.plugins;
      case VispIcons.proxy:
        return MynaUi.proxy;
      case VispIcons.plus:
        return MynaUi.plus;
      case VispIcons.shieldCheck:
        return MynaUi.shieldCheck;
      case VispIcons.shield:
        return MynaUi.shield;
      case VispIcons.plug:
        return MynaUi.plug;
      case VispIcons.database:
        return MynaUi.database;
      case VispIcons.globe:
        return MynaUi.globe;
      case VispIcons.route:
        return MynaUi.route;
      case VispIcons.refresh:
        return MynaUi.refresh;
      case VispIcons.flask:
        return MynaUi.flask;
      case VispIcons.alert:
        return MynaUi.alert;
      case VispIcons.check:
        return MynaUi.check;
      case VispIcons.checkCircle:
        return MynaUi.checkCircle;
      case VispIcons.file:
        return MynaUi.file;
      case VispIcons.qr:
        return MynaUi.qr;
      case VispIcons.key:
        return MynaUi.key;
      case VispIcons.send:
        return MynaUi.send;
      case VispIcons.chevronDown:
        return MynaUi.chevronDown;
      case VispIcons.chevronRight:
        return MynaUi.chevronRight;
      case VispIcons.edit:
        return MynaUi.edit;
      case VispIcons.back:
        return MynaUi.back;
      case VispIcons.search:
        return MynaUi.search;
      case VispIcons.filter:
        return MynaUi.filter;
      case VispIcons.copy:
        return MynaUi.copy;
      case VispIcons.paste:
        return MynaUi.paste;
      case VispIcons.lock:
        return MynaUi.lock;
      case VispIcons.wifi:
        return MynaUi.wifi;
      case VispIcons.signal:
        return MynaUi.signal;
      case VispIcons.clock:
        return MynaUi.clock;
      case VispIcons.gauge:
        return MynaUi.gauge;
      case VispIcons.download:
        return MynaUi.download;
      case VispIcons.upload:
        return MynaUi.upload;
      case VispIcons.delete:
        return MynaUi.delete;
      case VispIcons.person:
        return MynaUi.person;
      case VispIcons.users:
        return MynaUi.users;
      case VispIcons.bell:
        return MynaUi.bell;
      case VispIcons.info:
        return MynaUi.info;
      case VispIcons.warning:
        return MynaUi.warning;
      case VispIcons.link:
        return MynaUi.link;
      case VispIcons.mail:
        return MynaUi.mail;
      case VispIcons.code:
        return MynaUi.code;
      case VispIcons.close:
        return MynaUi.close;
      case VispIcons.dpi:
        return MynaUi.dpi;
      case VispIcons.theme:
        return MynaUi.theme;
      case VispIcons.language:
        return MynaUi.language;
      case VispIcons.security:
        return MynaUi.security;
      case VispIcons.device:
        return MynaUi.device;
      case VispIcons.monitor:
        return MynaUi.monitor;
      case VispIcons.bug:
        return MynaUi.bug;
      case VispIcons.share:
        return MynaUi.share;
      case VispIcons.heart:
        return MynaUi.heart;
      case VispIcons.uploadCloud:
        return MynaUi.uploadCloud;
    }
  }
}


/// Залитые иконки MynaUI.
///
/// Держатся отдельно от контурных и объявлены константами: так
/// tree-shaking иконок в release-сборке видит статические ссылки на шрифт
/// и не выбрасывает его целиком.
class MynaUiSolid {
  MynaUiSolid._();

  static const IconData home = IconData(0xec49, fontFamily: MynaUi.solidFamily);
  static const IconData server = IconData(0xee32, fontFamily: MynaUi.solidFamily);
  static const IconData settings =
      IconData(0xeb55, fontFamily: MynaUi.solidFamily);
  static const IconData studio = IconData(0xec70, fontFamily: MynaUi.solidFamily);
  static const IconData plugins =
      IconData(0xedee, fontFamily: MynaUi.solidFamily);
  static const IconData proxy = IconData(0xef17, fontFamily: MynaUi.solidFamily);
  static const IconData plus = IconData(0xede8, fontFamily: MynaUi.solidFamily);
  static const IconData shieldCheck =
      IconData(0xee3c, fontFamily: MynaUi.solidFamily);
  static const IconData shield = IconData(0xee44, fontFamily: MynaUi.solidFamily);
  static const IconData checkCircle =
      IconData(0xeae8, fontFamily: MynaUi.solidFamily);
  static const IconData info = IconData(0xec5c, fontFamily: MynaUi.solidFamily);
  static const IconData warning = IconData(0xeb7b, fontFamily: MynaUi.solidFamily);
  static const IconData theme = IconData(0xee85, fontFamily: MynaUi.solidFamily);
  static const IconData search = IconData(0xee2f, fontFamily: MynaUi.solidFamily);
  static const IconData key = IconData(0xec67, fontFamily: MynaUi.solidFamily);
  static const IconData lock = IconData(0xed50, fontFamily: MynaUi.solidFamily);
  static const IconData signal = IconData(0xed82, fontFamily: MynaUi.solidFamily);
  static const IconData device = IconData(0xed86, fontFamily: MynaUi.solidFamily);
  static const IconData monitor = IconData(0xed87, fontFamily: MynaUi.solidFamily);
}

/// Залитая версия иконки.
///
/// Возвращает готовую константу, если она есть: вычисляемый `IconData`
/// ломает tree-shaking иконок в release-сборке.
IconData filledData(VispIcons icon) {
  switch (icon) {
    case VispIcons.home:
      return MynaUiSolid.home;
    case VispIcons.server:
      return MynaUiSolid.server;
    case VispIcons.settings:
      return MynaUiSolid.settings;
    case VispIcons.studio:
      return MynaUiSolid.studio;
    case VispIcons.plugins:
      return MynaUiSolid.plugins;
    case VispIcons.proxy:
      return MynaUiSolid.proxy;
    case VispIcons.plus:
      return MynaUiSolid.plus;
    case VispIcons.shieldCheck:
    case VispIcons.dpi:
      return MynaUiSolid.shieldCheck;
    case VispIcons.shield:
      return MynaUiSolid.shield;
    case VispIcons.checkCircle:
      return MynaUiSolid.checkCircle;
    case VispIcons.info:
      return MynaUiSolid.info;
    case VispIcons.warning:
    case VispIcons.alert:
      return MynaUiSolid.warning;
    case VispIcons.theme:
      return MynaUiSolid.theme;
    case VispIcons.search:
      return MynaUiSolid.search;
    case VispIcons.key:
      return MynaUiSolid.key;
    case VispIcons.lock:
    case VispIcons.security:
      return MynaUiSolid.lock;
    case VispIcons.signal:
      return MynaUiSolid.signal;
    case VispIcons.device:
      return MynaUiSolid.device;
    case VispIcons.monitor:
      return MynaUiSolid.monitor;
    default:
      // Контурная иконка используется как залитая: это честнее, чем
      // конструировать IconData во время выполнения — tree-shaking иконок
      // отвергает неконстантные вызовы.
      return icon.data;
  }
}

/// Виджет-адаптер для иконок Visp.
///
/// Размеры по DESIGN.md: 20 px в строках, 24 px в крупных действиях,
/// 16 px внутри чипов. Каждая иконка-кнопка получает доступное имя.
class VispIcon extends StatelessWidget {
  const VispIcon(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.weight,
    this.filled = false,
  });

  final VispIcons icon;
  final double size;
  final Color? color;

  /// Заливка вместо контура. Используется для активных состояний, чтобы
  /// выделение читалось формой, а не только цветом.
  final bool filled;

  /// Толщина линии иконки. Сохраняется для совместимости вызовов.
  final double? weight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Icon(
      filled ? filledData(icon) : icon.data,
      size: size,
      color: color ?? theme.iconTheme.color,
      semanticLabel: icon.name,
    );
  }
}

/// Иконка-кнопка с tooltip/семантической меткой (требование accessibility).
class VispIconButton extends StatelessWidget {
  const VispIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 20,
    this.color,
  });

  final VispIcons icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final button = IconButton(
      icon: VispIcon(icon, size: size, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 22,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minHeight: 44,
        minWidth: 44,
      ),
      color: colors.onSurface,
    );
    return Semantics(
      button: true,
      label: tooltip,
      child: button,
    );
  }
}
