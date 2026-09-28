# Практические плагины Visp: zapret и Telegram WS Proxy

## 1. Важное разделение

`zapret-discord-youtube` — Windows-набор стратегий и WinDivert-компонентов. Его нельзя просто положить в Flutter-пакет и считать плагином: нужны лицензия, подпись бинарников, проверка прав администратора, установка драйвера и аккуратное удаление службы.

`tg-ws-proxy` — локальный MTProto proxy, который слушает localhost и соединяется с Telegram DC через WebSocket. Его естественная модель плагина — `proxy.provider` + sidecar, а не VPN-протокол.

## 2. Плагин zapret

Репозиторий плагина:

```text
visp-plugin-zapret/
  plugin.yaml
  lib/zapret_plugin.dart
  native/windows-x64/winws.exe
  native/windows-x64/WinDivert.dll
  native/windows-x64/WinDivert64.sys
  strategies/*.json
  test/contract_test.dart
```

Manifest:

```yaml
schema: visp.plugin/v1
id: com.visp.zapret
name: Visp zapret strategies
version: 0.1.0
api: ">=1.0.0 <2.0.0"
capabilities: [protocol.engine, diagnostics.health, ui.settings]
permissions:
  network: [intercept_local_traffic]
  system: [install_driver, administrator]
platforms: [windows]
entrypoint:
  dart: lib/zapret_plugin.dart
  sidecar:
    windows-x64: native/windows-x64/visp-zapret-sidecar.exe
```

Sidecar responsibilities:

- импортировать выбранную strategy;
- проверять наличие Windows и WinDivert;
- запускать `winws` с аргументами из allowlist, а не с произвольной командой;
- возвращать `status`, PID, выбранную стратегию и health-check;
- устанавливать/останавливать/удалять службу только после подтверждения;
- не менять hosts, firewall или DNS без отдельной permission.

В UI плагина: список стратегий, тест выбранной стратегии, запуск, остановка,
aвтозапуск и диагностика. В логах запрещены IP, ключи и содержимое трафика.


## 2.1. Как запускается zapret без переписывания исходников

Мы не переносим zapret в Dart и не переписываем его сетевую логику. Репозиторий
zapret остаётся upstream-источником; в Visp-плагине находится адаптер и пакет
собранных артефактов.

```text
Visp Flutter UI
  → plugin host
  → visp-zapret-sidecar.exe (адаптер)
  → исходный winws.exe + WinDivert из проверенного релиза
  → Windows Service / локальный трафик
```

Sidecar делает только пять вещей:

1. принимает от Visp выбранную стратегию из allowlist;
2. проверяет хэши `winws`, DLL, SYS и конфигурации;
3. запрашивает системное повышение прав через штатный UAC installer;
4. устанавливает или запускает службу с заранее сформированной командой;
5. возвращает в Visp состояние, ошибки и результат health-check.

Администраторские права нужны только для установки драйвера WinDivert, создания
службы и изменения системных параметров. Обычный запуск/остановка использует
зарегистрированную службу и не просит пароль внутри Visp. Visp никогда не
передаёт произвольную команду из UI в shell: стратегия выбирается по ID, а
sidecar подставляет только разрешённые аргументы.

### Обновление upstream

При обновлении zapret CI собирает отдельную версию плагина, проверяет лицензию,
хэши и contract tests. Рабочая предыдущая версия остаётся для rollback. Если
upstream изменяет формат аргументов или WinDivert API, меняется только адаптер,
а не Flutter-ядро Visp.

### Другие программы с правами администратора

Для любого такого компонента используется тот же контракт: sidecar + signed
installer + manifest permissions + UAC на конкретную операцию + rollback. Если
программа требует постоянного ядра/драйвера, это явно указывается в manifest.
Нельзя скрыто запускать elevated-процесс или сохранять пароль администратора.
## 3. Плагин Telegram-прокси

Базовый `com.visp.telegram-proxy` объявляет общий тип записи `telegram.mtproto` и экран списка прокси. `tg-ws-proxy` не дублирует вкладку: он объявляет зависимость и добавляет transport implementation.

```yaml
id: com.visp.tg-ws-proxy
name: Telegram WS transport
version: 0.1.0
api: ">=1.0.0 <2.0.0"
requires:
  - id: com.visp.telegram-proxy
    version: ">=1.0.0 <2.0.0"
capabilities: [proxy.provider, ui.settings, diagnostics.health]
permissions:
  network: [connect]
  system: [local_listener]
```

Поток работы:

```text
Telegram Desktop → 127.0.0.1:<port>
                 → tg-ws-proxy sidecar
                 → WebSocket/TLS или fallback
                 → Telegram DC
```

Базовый плагин отвечает за общую модель `Proxy`, импорт `tg://proxy`, проверку и вкладку. Дочерний плагин отвечает за sidecar, порт, запуск, остановку и health-check. Если базовый плагин удалён, Visp сначала останавливает дочерний и предлагает удалить его записи.

## 4. Зависимости и совместимость

Зависимости образуют DAG без циклов. Установка вычисляет порядок, проверяет диапазоны SemVer и показывает разрешения всех зависимостей. Обновление нельзя применить, если новая версия базового плагина несовместима. Каждый плагин получает отдельный storage namespace.

## 5. План первой реализации

1. Сделать plugin host и validator manifest.
2. Реализовать mock-плагин без сетевого движка.
3. Реализовать `com.visp.telegram-proxy` с локальными тестовыми данными.
4. Подключить `com.visp.tg-ws-proxy` как sidecar-зависимость.
5. После аудита Windows permissions реализовать `com.visp.zapret`.
6. Добавить каталог, подписи, rollout и rollback.

