import '../../core/icons/visp_icon.dart';

/// Точки назначения плавающей навигации.
///
/// Состав вкладок определяется плагинами и закреплением Studio:
/// Home и Servers — базовые, Proxy появляется после установки плагина
/// «Прокси» (раздел 8.2), Studio — необязательное закрепление (раздел 10),
/// Settings — постоянная.
enum NavDestination {
  home,
  servers,
  proxy,
  studio,
  settings,
}

extension NavDestinationX on NavDestination {
  VispIcons get icon {
    switch (this) {
      case NavDestination.home:
        return VispIcons.home;
      case NavDestination.servers:
        return VispIcons.server;
      case NavDestination.proxy:
        return VispIcons.proxy;
      case NavDestination.studio:
        return VispIcons.studio;
      case NavDestination.settings:
        return VispIcons.settings;
    }
  }

  String get label {
    switch (this) {
      case NavDestination.home:
        return 'Главная';
      case NavDestination.servers:
        return 'Серверы';
      case NavDestination.proxy:
        return 'Прокси';
      case NavDestination.studio:
        return 'Studio';
      case NavDestination.settings:
        return 'Настройки';
    }
  }
}
