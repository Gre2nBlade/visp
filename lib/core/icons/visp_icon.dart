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
}

extension VispIconsData on VispIcons {
  IconData get data {
    switch (this) {
      case VispIcons.home:
        return Icons.home_outlined;
      case VispIcons.server:
        return Icons.dns_outlined;
      case VispIcons.settings:
        return Icons.settings_outlined;
      case VispIcons.studio:
        return Icons.dashboard_outlined;
      case VispIcons.plugins:
        return Icons.extension_outlined;
      case VispIcons.proxy:
        return Icons.send_outlined;
      case VispIcons.plus:
        return Icons.add;
      case VispIcons.shieldCheck:
        return Icons.verified_user_outlined;
      case VispIcons.shield:
        return Icons.shield_outlined;
      case VispIcons.plug:
        return Icons.power_outlined;
      case VispIcons.database:
        return Icons.storage_outlined;
      case VispIcons.globe:
        return Icons.public_outlined;
      case VispIcons.route:
        return Icons.alt_route_outlined;
      case VispIcons.refresh:
        return Icons.refresh_outlined;
      case VispIcons.flask:
        return Icons.science_outlined;
      case VispIcons.alert:
        return Icons.error_outline;
      case VispIcons.check:
        return Icons.check;
      case VispIcons.checkCircle:
        return Icons.check_circle_outline;
      case VispIcons.file:
        return Icons.insert_drive_file_outlined;
      case VispIcons.qr:
        return Icons.qr_code_scanner_outlined;
      case VispIcons.key:
        return Icons.vpn_key_outlined;
      case VispIcons.send:
        return Icons.send_outlined;
      case VispIcons.chevronDown:
        return Icons.keyboard_arrow_down;
      case VispIcons.chevronRight:
        return Icons.keyboard_arrow_right;
      case VispIcons.edit:
        return Icons.edit_outlined;
      case VispIcons.back:
        return Icons.arrow_back;
      case VispIcons.search:
        return Icons.search;
      case VispIcons.filter:
        return Icons.filter_list;
      case VispIcons.copy:
        return Icons.content_copy;
      case VispIcons.paste:
        return Icons.content_paste_outlined;
      case VispIcons.lock:
        return Icons.lock_outline;
      case VispIcons.wifi:
        return Icons.wifi_outlined;
      case VispIcons.signal:
        return Icons.signal_cellular_alt;
      case VispIcons.clock:
        return Icons.schedule_outlined;
      case VispIcons.gauge:
        return Icons.speed_outlined;
      case VispIcons.download:
        return Icons.download_outlined;
      case VispIcons.upload:
        return Icons.upload_outlined;
      case VispIcons.delete:
        return Icons.delete_outline;
      case VispIcons.person:
        return Icons.person_outline;
      case VispIcons.users:
        return Icons.group_outlined;
      case VispIcons.bell:
        return Icons.notifications_outlined;
      case VispIcons.info:
        return Icons.info_outline;
      case VispIcons.warning:
        return Icons.warning_amber_outlined;
      case VispIcons.link:
        return Icons.link;
      case VispIcons.mail:
        return Icons.mail_outline;
      case VispIcons.code:
        return Icons.code;
      case VispIcons.close:
        return Icons.close;
      case VispIcons.dpi:
        return Icons.network_check_outlined;
      case VispIcons.theme:
        return Icons.palette;
      case VispIcons.language:
        return Icons.language;
      case VispIcons.security:
        return Icons.security;
      case VispIcons.device:
        return Icons.devices;
      case VispIcons.bug:
        return Icons.bug_report;
      case VispIcons.share:
        return Icons.share_outlined;
      case VispIcons.heart:
        return Icons.favorite_outline;
      case VispIcons.uploadCloud:
        return Icons.cloud_upload_outlined;
    }
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
  });

  final VispIcons icon;
  final double size;
  final Color? color;

  /// Толщина линии иконки (Material Symbols weight, 100–900).
  final double? weight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Icon(
      icon.data,
      size: size,
      color: color ?? theme.iconTheme.color,
      weight: weight,
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
