import 'package:flutter/widgets.dart';

/// Делегат локализации: русский — основной, английский — второй язык
/// (раздел 1). Строки хранятся в одном классе, без внешней генерации.

/// Строки интерфейса. Русский — основной, английский — второй язык
/// (раздел 1: языки приложения — русский и английский).
///
/// Ключи объединены в один класс, чтобы feature-код не зависел от платформы
/// локализации и мог обращаться к строкам через [S.of].
class S {
  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? en : ru;
  }

  static const ru = S._ru();
  static const en = S._en();

  const S._ru();
  const S._en();

  // Общие -------------------------------------------------------------
  String get appName => this == ru ? 'Visp' : 'Visp';
  String get cancel => this == ru ? 'Отмена' : 'Cancel';
  String get continueWord => this == ru ? 'Продолжить' : 'Continue';
  String get done => this == ru ? 'Готово' : 'Done';
  String get add => this == ru ? 'Добавить' : 'Add';
  String get delete => this == ru ? 'Удалить' : 'Delete';
  String get rename => this == ru ? 'Переименовать' : 'Rename';
  String get save => this == ru ? 'Сохранить' : 'Save';
  String get search => this == ru ? 'Поиск' : 'Search';
  String get all => this == ru ? 'Все' : 'All';
  String get notChosen => this == ru ? 'Не выбрано' : 'Not selected';
  String get noData => this == ru ? 'Нет данных' : 'No data';

  /// Заголовок экрана при ошибке. Само сообщение с кодом — в карточке.
  String get error => this == ru ? 'Ошибка подключения' : 'Connection error';
  String get close => this == ru ? 'Закрыть' : 'Close';

  // Главная -----------------------------------------------------------
  String get vpnOff => this == ru ? 'VPN выключен' : 'VPN is off';
  String get connected => this == ru ? 'Подключено' : 'Connected';
  String get connect => this == ru ? 'Подключиться' : 'Connect';
  String get disconnect => this == ru ? 'Отключить' : 'Disconnect';
  String get cancelConnection => this == ru ? 'Отменить' : 'Cancel';
  String get trafficBlocked => this == ru ? 'Трафик заблокирован' : 'Traffic is blocked';
  String get retry => this == ru ? 'Повторить' : 'Retry';
  String get unblock => this == ru ? 'Разблокировать' : 'Unblock';
  String get sessionLost => this == ru
      ? 'Старая сессия потеряна, переподключение'
      : 'Previous session lost, reconnecting';
  String get needsModule => this == ru ? 'Нужен модуль' : 'Module required';
  String get splitTunneling => this == ru ? 'Раздельное туннелирование' : 'Split tunneling';
  String get splitTunnelingOff => this == ru ? 'Раздельное туннелирование выключено' : 'Split tunneling is off';
  String get splitTunnelingOn => this == ru ? 'Раздельное туннелирование включено' : 'Split tunneling is on';
  String get chooseServer => this == ru ? 'Выбрать сервер' : 'Choose a server';
  String get serversList => this == ru ? 'Список серверов' : 'Server list';
  String get noConnectionsYet => this == ru
      ? 'Подключений ещё нет'
      : 'No connections yet';
  String get enterCodeHint => this == ru
      ? 'Вставьте код или ссылку, чтобы добавить подключение'
      : 'Paste a code or link to add a connection';
  String get debugInfo => this == ru ? 'Debug-информация' : 'Debug information';
  String get ping => this == ru ? 'Пинг' : 'Ping';
  String get download => this == ru ? 'Загрузка' : 'Download';
  String get upload => this == ru ? 'Отдача' : 'Upload';
  String get sessionTime => this == ru ? 'Время сессии' : 'Session time';
  String get protocol => this == ru ? 'Протокол' : 'Protocol';
  String get auto => this == ru ? 'Автоматически' : 'Automatic';
  String get autoMode => this == ru ? 'Авто' : 'Auto';

  // Добавление подключения ---------------------------------------------
  String get addConnection => this == ru ? 'Добавить подключение' : 'Add connection';
  String get pasteKey => this == ru ? 'Вставьте ключ/ссылку/код' : 'Paste key/link/code';
  String get paste => this == ru ? 'Вставить' : 'Paste';
  String get pasteKeyHint => this == ru
      ? 'visp://, VISP-код, vless://, hysteria2://, ss://, trojan://, vmess://, подписка, tg://proxy'
      : 'visp://, VISP code, vless://, hysteria2://, ss://, trojan://, vmess://, subscription, tg://proxy';
  String get otherOptions => this == ru ? 'Другие варианты подключения' : 'Other connection options';
  String get selfHosted => this == ru ? 'Self-hosted' : 'Self-hosted';
  String get selfHostedDesc => this == ru ? 'Настроить VPN на собственном сервере' : 'Set up VPN on your own server';
  String get configFile => this == ru ? 'Файл с настройками' : 'Settings file';
  String get configFileDesc => this == ru
      ? 'OpenVPN, WireGuard и другие конфиги'
      : 'OpenVPN, WireGuard and other configs';
  String get qrCode => this == ru ? 'QR-код' : 'QR code';
  String get qrCodeDesc => this == ru ? 'Сканировать код камерой' : 'Scan a code with the camera';
  String get subscription => this == ru ? 'Импорт подписки' : 'Import subscription';
  String get subscriptionDesc => this == ru
      ? 'base64, Clash YAML, sing-box/Xray JSON'
      : 'base64, Clash YAML, sing-box/Xray JSON';

  // Импорт -------------------------------------------------------------
  String get importPreview => this == ru ? 'Предпросмотр импорта' : 'Import preview';
  String get source => this == ru ? 'Источник' : 'Source';
  String get routingRules => this == ru ? 'Правила маршрутизации' : 'Routing rules';
  String get requiredModules => this == ru ? 'Требуемые модули' : 'Required modules';
  String get addedN => this == ru ? 'Добавлено подключений' : 'Connections added';
  String get formatUnsupported => this == ru ? 'Формат пока не поддерживается' : 'Format is not supported yet';
  String get codeExpired => this == ru ? 'Код истёк' : 'Code expired';
  String get codeRevoked => this == ru ? 'Код отозван' : 'Code revoked';
  String get deviceLimit => this == ru ? 'Достигнут лимит устройств' : 'Device limit reached';
  String get activationSuccess => this == ru ? 'Код активирован' : 'Code activated';
  String get networkErrorTryAgain => this == ru
      ? 'Сетевая ошибка. Проверьте подключение и повторите'
      : 'Network error. Check your connection and try again';
  String get invalidCode => this == ru ? 'Неверный код' : 'Invalid code';
  String get keepMine => this == ru ? 'Оставить мои' : 'Keep mine';
  String get merge => this == ru ? 'Объединить' : 'Merge';
  String get replace => this == ru ? 'Заменить' : 'Replace';

  // Серверы ------------------------------------------------------------
  String get servers => this == ru ? 'Серверы' : 'Servers';
  String get filterProtocol => this == ru ? 'Протокол' : 'Protocol';
  String get filterReady => this == ru ? 'Готовые' : 'Ready';
  String get favorites => this == ru ? 'Избранное' : 'Favorites';
  String get readyToConnect => this == ru ? 'Готов к подключению' : 'Ready to connect';
  String get notSetOnServer => this == ru ? 'Не настроен на сервере' : 'Not configured on the server';
  String get noConfig => this == ru ? 'Нет конфигурации' : 'No configuration';
  String get downloadEngine => this == ru ? 'Скачать' : 'Download';
  String get selected => this == ru ? 'Выбрано' : 'Selected';
  String get searchHint => this == ru ? 'Название, IP, регион, протокол' : 'Name, IP, region, protocol';
  String get noResults => this == ru ? 'Ничего не найдено' : 'No results found';
  String get protocols => this == ru ? 'Протоколы' : 'Protocols';
  String get management => this == ru ? 'Управление' : 'Management';
  String get share => this == ru ? 'Поделиться' : 'Share';
  String get deleteServer => this == ru ? 'Удалить сервер из приложения' : 'Delete server from the app';
  String get deleteServerConfirm => this == ru
      ? 'Удаление локальной записи не удаляет сервер у владельца. Если запись используется, соответствующая сессия будет завершена.'
      : 'Deleting the local record does not remove the server. An active session will be closed.';
  String get serverSettings => this == ru ? 'Настройки сервера' : 'Server settings';
  String get autoInstall => this == ru ? 'Автоустановка' : 'Auto-install';
  String get profilesCount => this == ru ? 'профилей' : 'profiles';

  // Состояния движка (раздел 3.4) -------------------------------------
  String get engineReady => this == ru ? 'Готов' : 'Ready';
  String get engineNotInstalled => this == ru ? 'Нужен модуль' : 'Module required';
  String get engineDownloading => this == ru ? 'Скачивается' : 'Downloading';
  String get engineNeedsUpdate => this == ru ? 'Обновление' : 'Update available';
  String get engineUnsupported => this == ru ? 'Недоступно' : 'Unsupported';
  String get engineDownloadHint => this == ru
      ? 'Движок докачивается при первом подключении'
      : 'The engine downloads on first connection';
  String get protocolChoice => this == ru ? 'Выбор протокола' : 'Choose protocol';
  String get switchProtocolWarn => this == ru
      ? 'Смена протокола при активной сессии переподключит соединение.'
      : 'Switching protocol during an active session will reconnect.';

  // Настройки ----------------------------------------------------------
  String get settings => this == ru ? 'Настройки' : 'Settings';
  String get studio => this == ru ? 'Studio' : 'Studio';
  String get studioDesc => this == ru
      ? 'Кабинет владельца серверов и кодов доступа'
      : 'Dashboard for server owners and access codes';
  String get studioInNav => this == ru ? 'Studio в навигации' : 'Studio in navigation';
  String get studioInNavDesc => this == ru
      ? 'Необязательное закрепление вкладки. Открепление не убирает пункт из настроек.'
      : 'Optional tab pinning. Unpinning does not remove the settings entry.';
  String get studioEmpty => this == ru ? 'Своих серверов пока нет' : 'No own servers yet';
  String get studioEmptyDesc => this == ru
      ? 'Добавьте свой сервер, чтобы управлять кодами доступа'
      : 'Add your own server to manage access codes';
  String get groupConnection => this == ru ? 'Соединение' : 'Connection';
  String get killSwitch => this == ru ? 'Kill switch' : 'Kill switch';
  String get killSwitchDesc => this == ru
      ? 'Блокировать трафик при обрыве туннеля'
      : 'Block traffic when the tunnel drops';
  String get autostart => this == ru ? 'Автозапуск' : 'Start on boot';
  String get autostartDesc => this == ru ? 'Запускать при включении устройства' : 'Launch when the device boots';
  String get alwaysOn => this == ru ? 'Always-on' : 'Always-on';
  String get alwaysOnDesc => this == ru ? 'Системный режим постоянного VPN' : 'System-level always-on VPN';
  String get dns => this == ru ? 'DNS' : 'DNS';
  String get dnsDesc => this == ru ? 'Резолвер, DoH/DoT и проверка утечек' : 'Resolver, DoH/DoT and leak check';
  String get groupPlugins => this == ru ? 'Плагины' : 'Plugins';
  String get pluginsDesc => this == ru ? 'Каталог, разрешения и обновления' : 'Catalog, permissions and updates';
  String get groupUpdates => this == ru ? 'Обновления' : 'Updates';
  String get updatesDesc => this == ru ? 'Канал и автоматическая проверка' : 'Channel and automatic checks';
  String get groupHaptics => this == ru ? 'Тактильная отдача' : 'Haptics';
  String get hapticsDesc => this == ru
      ? 'Навигация, переключатели и опасные действия'
      : 'Navigation, switches and destructive actions';
  String get groupPersonalization => this == ru ? 'Персонализация' : 'Personalization';
  String get theme => this == ru ? 'Тема' : 'Theme';
  String get glass => this == ru ? 'Стекло' : 'Glass';
  String get glassDesc => this == ru
      ? 'Материал навигационной капсулы и панелей'
      : 'Material of the navigation capsule and panels';
  String get light => this == ru ? 'Светлая' : 'Light';
  String get dark => this == ru ? 'Тёмная' : 'Dark';
  String get system => this == ru ? 'Системная' : 'System';
  String get groupApp => this == ru ? 'Приложение' : 'Application';
  String get language => this == ru ? 'Язык' : 'Language';
  String get screenshots => this == ru ? 'Скриншоты приложения' : 'App screenshots';
  String get screenshotsDesc => this == ru ? 'Разрешить делать скриншоты' : 'Allow taking screenshots';
  String get logging => this == ru ? 'Логирование' : 'Logging';
  String get loggingDesc => this == ru ? 'Локальные журналы отладки' : 'Local debug logs';
  String get resetAll => this == ru ? 'Сбросить настройки и удалить все данные' : 'Reset settings and delete all data';
  String get resetAllConfirm => this == ru
      ? 'Будут удалены все локальные конфигурации и настройки на этом устройстве. Отозванные сервером доступы это не вернёт.'
      : 'All local configurations and settings will be deleted on this device. This does not revoke server-side access.';
  String get groupAbout => this == ru ? 'О приложении' : 'About';
  String get aboutDesc => this == ru ? 'Версия, исходный код, лицензии' : 'Version, source code, licenses';
  String get version => this == ru ? 'Версия' : 'Version';
  String get sourceCode => this == ru ? 'Исходный код' : 'Source code';
  String get licenses => this == ru ? 'Лицензии' : 'Licenses';
  String get privacyPolicy => this == ru ? 'Политика конфиденциальности' : 'Privacy policy';
  String get checkUpdates => this == ru ? 'Проверить обновления' : 'Check for updates';
  String get updateAvailable => this == ru ? 'Доступно обновление' : 'Update available';
  String get updateNow => this == ru ? 'Обновить' : 'Update';
  String get later => this == ru ? 'Позже' : 'Later';
  String get stable => this == ru ? 'Стабильный' : 'Stable';
  String get beta => this == ru ? 'Beta' : 'Beta';
  String get minimal => this == ru ? 'Минимум' : 'Minimal';
  String get off => this == ru ? 'Выключено' : 'Off';

  // Прокси -------------------------------------------------------------
  String get proxyTab => this == ru ? 'Прокси' : 'Proxies';
  String get proxyForTelegram => this == ru ? 'Прокси для Telegram' : 'Proxies for Telegram';
  String get proxyPluginDesc => this == ru
      ? 'MTProto, WEB proxy и локальный TG WS Proxy в одном разделе'
      : 'MTProto, WEB proxy and local TG WS Proxy in one place';
  String get install => this == ru ? 'Установить' : 'Install';
  String get installed => this == ru ? 'Установлен' : 'Installed';
  String get openInTelegram => this == ru ? 'Открыть в Telegram' : 'Open in Telegram';
  String get checkProxy => this == ru ? 'Проверить' : 'Check';
  String get localService => this == ru ? 'Локальный сервис' : 'Local service';
  String get serviceOff => this == ru ? 'Выключен' : 'Off';
  String get serviceRunning => this == ru ? 'Работает' : 'Running';
  String get serviceStarting => this == ru ? 'Запускается' : 'Starting';
  String get serviceError => this == ru ? 'Ошибка' : 'Error';

  // Self-hosted --------------------------------------------------------
  String get selfHostedTitle => this == ru ? 'Настроить ваш сервер' : 'Set up your server';
  String get serverAddress => this == ru ? 'IP-адрес[:порт] сервера' : 'Server IP address[:port]';
  String get serverAddressHint => this == ru ? '255.255.255.255:22' : '255.255.255.255:22';
  String get sshUser => this == ru ? 'Имя пользователя SSH' : 'SSH username';
  String get sshUserHint => this == ru ? 'root' : 'root';
  String get sshPassword => this == ru ? 'Пароль или закрытый ключ SSH' : 'SSH password or private key';
  String get sshKeyNote => this == ru
      ? 'Поддерживаются ключи ED25519 и RSA в формате PEM. Вставьте закрытый ключ целиком, включая строки BEGIN/END.'
      : 'ED25519 and RSA keys in PEM format are supported. Paste the full private key, including BEGIN/END lines.';
  String get privacyNote => this == ru
      ? 'Все данные, которые вы вводите, остаются на устройстве и не передаются третьим лицам'
      : 'Everything you enter stays on the device and is never shared with third parties';
  String get howToVpn => this == ru ? 'Как создать VPN на собственном сервере' : 'How to set up VPN on your own server';
  String get installProgress => this == ru ? 'Идёт установка компонентов…' : 'Installing components…';
  String get installDone => this == ru ? 'Сервер настроен' : 'Server is ready';
  String get errorAddressUnreachable => this == ru ? 'Адрес недоступен' : 'Address is unreachable';
  String get errorCredentials => this == ru ? 'Неверные реквизиты' : 'Invalid credentials';
  String get errorUnsupportedSystem => this == ru ? 'Неподдерживаемая система' : 'Unsupported system';
  String get errorNotEnoughRights => this == ru ? 'Недостаточно прав' : 'Not enough rights';
}

extension SContext on BuildContext {
  S get s => S.of(this);
}

class AppStringsDelegate extends LocalizationsDelegate<S> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async =>
      locale.languageCode == 'en' ? S.en : S.ru;

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
