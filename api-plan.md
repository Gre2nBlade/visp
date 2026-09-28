# Visp API plan

## 1. Компоненты

- **Studio app (Flutter):** UI, локальное защищённое хранилище, вызовы Control Plane.
- **Control Plane API:** auth, RBAC, servers, agents, plugins, codes, limits, audit, releases.
- **Visp Agent:** локальная установка и обновление компонентов, health-check, метрики, выполнение подписанных команд.
- **Code resolver:** разрешение `VISP-...` и `visp.to/...`; не хранит секреты в логах.
- **Event worker:** лимиты, health events, rollout и уведомления.

Выбранный первый стек: Go + PostgreSQL, OpenAPI 3.1, Docker Compose на Linux VPS. Для очередей на первом этапе используется PostgreSQL outbox/worker; Redis добавляется при подтверждённой нагрузке. Агент также пишется на Go для общего toolchain.

## 2. Авторизация

- Пользователь: OIDC, access token 10–15 минут, refresh token с ротацией.
- Сервис: scoped API key или OIDC service account, срок и квота обязательны.
- Агент: mTLS после одноразового bootstrap-токена.
- Роли: owner, server_admin, code_manager, support_readonly, observer.
- Каждая мутация требует RBAC, tenant scope и audit event.

## 3. Ресурсы

`organizations`, `members`, `servers`, `agents`, `components`, `plugins`, `profiles`, `code_sets`, `codes`, `devices`, `sessions`, `limits`, `dns_routes`, `warp_routes`, `audit_events`, `release_channels`, `rollouts`.

Код хранится в виде `public_prefix + random_id`; секретная часть хранится только в хэшированном виде. На `organization_id + public_prefix` и `code_hash` есть уникальные индексы. Коллизия обрабатывается повторной генерацией и транзакцией.

## 4. Основные endpoints

```text
POST   /v1/agents/bootstrap
POST   /v1/agents/{id}/heartbeat
GET    /v1/servers
POST   /v1/servers
POST   /v1/servers/{id}/commands
GET    /v1/plugins/catalog
POST   /v1/plugins/{id}/install
POST   /v1/code-sets
POST   /v1/code-sets/{id}/codes
PATCH  /v1/codes/{id}/limits
POST   /v1/codes/{id}/revoke
POST   /v1/codes/{id}/rotate
GET    /v1/codes/{id}/usage
POST   /v1/resolve/{code}
POST   /v1/health-events
GET    /v1/audit-events
POST   /v1/releases/{channel}/rollouts
```

Для повторяемых POST используется `Idempotency-Key`. Ошибки имеют единый формат `code`, `message`, `details`, `request_id`. Пагинация — cursor based; даты — ISO 8601 UTC.

## 5. Выпуск кода

1. Studio отправляет состав профилей и политику лимитов.
2. API проверяет права, совместимость плагинов и лимиты серверов.
3. В транзакции создаются `code_set`, код, hash секрета и audit event.
4. Возвращается секрет один раз: текст, QR и короткая ссылка.
5. Resolver выдаёт только актуальную конфигурацию после проверки срока, отзыва, устройства и квоты.

## 6. Лимиты и события

Лимиты считаются на Control Plane; агент применяет локальную политику при временной потере связи. События `code.activated`, `device.registered`, `session.started`, `usage.reported`, `code.revoked`, `agent.unhealthy` доставляются через очередь с дедупликацией.

## 7. DNS и WARP

API хранит декларацию цепочки и фактический статус каждого hop. Для DNS: resolver type, адреса, DoH/DoT certificate policy, leak-test result. Для WARP: provider, tunnel id, route policy, fallback mode, last handshake. Секреты провайдера шифруются и не возвращаются GET-методами.

## 8. Минимальные этапы

1. Auth, organizations, servers, bootstrap агента.
2. Profiles, code sets, resolver, revoke и базовые лимиты.
3. Plugin catalog, signed bundles, health events.
4. DNS/WARP routes и rollout обновлений.
5. OIDC service accounts, usage analytics и multi-region.

## 9. Проверки перед production

Подпись пакетов и команд, replay protection, rate limits, tenant isolation, миграции с rollback, резервные копии PostgreSQL, журнал без секретов, интеграционные тесты агента и нагрузочный тест resolver.

