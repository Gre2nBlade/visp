# Visp Plugin SDK

## 1. Зачем нужны плагины

Плагин добавляет capability к Visp без изменения ядра: протокол, импортёр ссылок, прокси, DNS-провайдер, WARP-интеграция, тема или интеграция Studio. Обычный пользователь видит только установленный capability и его настройки. Управление серверами, Control Plane и серверным агентом доступно только владельцу в Studio.

В первой версии SDK используется Dart/Flutter API для UI и native bridge для сетевого движка. Исполняемый компонент работает изолированно и общается с Visp через IPC. Если выбран другой runtime, контракт manifest и IPC остаётся тем же.

## 2. Границы плагина

Плагин не может читать произвольные файлы, VPN-ключи, секреты других плагинов, содержимое трафика или токены Studio. Доступ выдаётся только перечисленными permissions и показывается пользователю до установки.

Базовые capability:

- `protocol.import` — распознать ссылку или файл и вернуть профиль;
- `protocol.engine` — запустить/остановить собственный движок;
- `proxy.provider` — добавить записи прокси в общий каталог;
- `dns.provider` — объявить DNS-режим и проверку утечек;
- `route.warp` — объявить дополнительный tunnel hop;
- `studio.server_component` — компонент для сервера владельца;
- `ui.settings` — экран настроек плагина;
- `diagnostics.health` — обезличенный health-check.

`studio.server_component` не даёт доступа обычному пользователю к Control Plane. Такой capability появляется только внутри Studio после привязки сервера и проверки роли.

## 3. Структура репозитория

```text
visp-plugin-example/
  plugin.yaml              # обязательный manifest
  lib/                      # Dart API и экран настроек
  native/                   # sidecar/bridge для нужных платформ
  assets/                   # иконки и локализация
  test/                     # unit и contract tests
  CHANGELOG.md
  LICENSE
```

## 4. Manifest

```yaml
schema: visp.plugin/v1
id: com.example.hysteria2
name: Hysteria 2
version: 1.2.0
api: ">=1.4.0 <2.0.0"
author: Example Org
license: Apache-2.0
entrypoint:
  dart: lib/plugin.dart
  sidecar:
    windows: native/win-x64/hysteria2.exe
    linux: native/linux-x64/hysteria2
capabilities:
  - protocol.import
  - protocol.engine
permissions:
  network: [connect]
  storage: [plugin_data]
platforms: [android, ios, windows, macos, linux]
healthcheck:
  command: health
  timeout_ms: 5000
signature:
  key_id: example-release-2026
  artifact_sha256: <generated-by-ci>
```

`id` неизменяем после первой публикации. `version` — SemVer. `api` ограничивает совместимость с Visp. Любая новая permission требует отдельного объяснения и повторного подтверждения.

## 5. Контракт IPC

Сообщения — JSON Lines по stdin/stdout sidecar или эквивалентный platform channel:

```json
{"id":"42","method":"import","params":{"uri":"hysteria2://..."}}
{"id":"42","result":{"profiles":[{"name":"Demo","engine":"hysteria2","configRef":"secret://local/1"}]}}
```

Обязательные методы: `describe`, `configure`, `import`, `start`, `stop`, `status`, `health`, `dispose`. Ошибка имеет `code`, безопасное `message` и `retryable`; секреты нельзя помещать в message или logs.

Профиль возвращает ссылку на защищённое локальное хранилище, а не сам секрет в UI. Плагин обязан корректно отвечать `status` после перезапуска и обрабатывать отмену операции.

## 6. Жизненный цикл

1. **Resolve** — Visp проверяет manifest, платформу, диапазон API и подпись.
2. **Consent** — пользователь видит capability и permissions.
3. **Install** — пакет распаковывается в sandbox, хэши сверяются.
4. **Configure** — создаётся отдельное хранилище плагина.
5. **Run** — ядро вызывает `start`; UI показывает реальный статус.
6. **Update** — сначала health-check новой версии, затем поэтапная замена.
7. **Rollback** — возврат к последней рабочей версии при ошибке.
8. **Uninstall** — остановка, отзыв профилей и явное удаление данных.

Плагин не должен менять системный DNS, маршруты или firewall без capability и явного подтверждения. Удаление плагина не удаляет серверные коды владельца автоматически.

## 7. Как написать плагин

1. Скопировать шаблон SDK и выбрать уникальный reverse-DNS `id`.
2. Описать capability, permissions, платформы и ограничения в `plugin.yaml`.
3. Реализовать `describe`, `configure`, `import`, `start`, `stop`, `status`, `health`.
4. Добавить contract tests: импорт, неверная ссылка, повторный запуск, timeout,
   отсутствие сети, обновление и rollback.
5. Собрать sidecar для каждой платформы, сформировать SBOM и подписать bundle.
6. Запустить локальный validator: manifest, permissions, hash, API compatibility.
7. Создать release с `CHANGELOG.md`; CI проверит подпись и отправит пакет в каталог.

## 8. Публикация и доверие

CI подписывает bundle ключом издателя. Каталог проверяет подпись, SBOM, разрешения,
совместимость и автоматические тесты. Для beta используется отдельный канал и
отдельный version range. Плагин может распространяться через GitHub Releases,
но Visp устанавливает его только после той же проверки подписи и хэшей.

Публикация не даёт Visp права читать код или трафик владельца. Отзыв ключа
издателя блокирует новые установки и обновления; уже установленная версия
помечается как revoked и действует по политике владельца.

## 9. Единый каталог данных

Все плагины используют общие модели `Plugin`, `Profile`, `Proxy`, `HealthEvent`,
`Capability` и `Permission`. Поэтому Studio умеет искать и группировать записи
одинаково, даже если протокол добавлен сторонним разработчиком. Расширение
модели выполняется через `metadata` с namespace плагина; изменение базовых полей
проходит через новую версию API.

## 10. Минимальные правила качества

Плагин должен быть детерминированным при импорте, не отправлять телеметрию без
permission, не логировать секреты, иметь timeout для сети, поддерживать отмену,
возвращать понятные ошибки и проходить rollback. Любой capability, который
нельзя безопасно ограничить, не публикуется в общем каталоге.

## 11. Практические примеры

Пошаговые адаптации zapret, Telegram Proxy и tg-ws-proxy находятся в [PLUGIN_EXAMPLES.md](PLUGIN_EXAMPLES.md).

