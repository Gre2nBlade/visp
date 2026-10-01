# Движки Visp

Слой движков разделён на две части: протокол в Go и платформа в Kotlin.
Интерфейс `VpnEngine` в Dart не знает, что под капотом.

## Граница доверия

Принцип: **каждая сторона владеет только своим слоем, наружу уходят примитивы.**

| Слой | Отвечает за | Никогда не делает |
|------|--------------|------------------|
| Go (`amneziawg-bridge`) | Криптография, туннель, разбор UAPI | Не знает об Android, не вызывает его API |
| Kotlin (`AmneziaWgVpnService`) | Разрешение ОС, tun-дескриптор, foreground-уведомление | Не занимается криптографией, не парсит конфиг |
| Dart (`VpnEngine`) | Состояние, UI, машина состояний движка | Не касается нативных указателей |

Через границу проходят только:

- `int` — дескриптор tun (валиден в пределах процесса);
- `String` — сериализованный конфиг в формате UAPI и JSON-статус;
- примитивы и `String[]` — параметры `VpnService.Builder`.

Указатели, Go-типы и структуры через границу не передаются. Секреты
(`private_key`, `preshared_key`) не попадают в лог и не возвращаются
в `DiagnosticsJSON` — только агрегированные счётчики.

## Сборка ядра

```bash
export ANDROID_HOME=/c/Android_SDK
export ANDROID_NDK_HOME=/c/Android_SDK/nd/28.2.13676358
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

cd engines/amneziawg-bridge
gomobile bind -androidapi 23 \
  -target=android/arm -target=android/arm64 \
  -target=android/amd64 -target=android/386 \
  -o out/amneziawg-bridge.aar ./amneziawg
```

Важные детали, найденные при сборке:

- **`-androidapi 23` обязателен.** По умолчанию gomobile берёт API 16,
  а NDK r28 его отвергает: «unsupported API version 16 (not in 21..35)».
- **`golang.org/x/mobile` должен быть в графе зависимостей модуля**, иначе
  `bind` отказывается работать. Добавляется как tool-зависимость:
  `go get -tool golang.org/x/mobile/cmd/gobind`.
- **Пакет не должен быть `main`.** gomobile биндит только обычные пакеты;
  код ядра лежит в `amneziawg/`, а не в корне модуля.
- **Повторяющиеся `-target` в одном вызове не накапливают ABI** — итоговый
  `.aar` содержит только последний. Собирать по одному ABI на файл и
  объединять содержимое в один архив.
- **Пути внутри `.aar` должны быть без ведущего слэша.** `ZipFile.CreateFromDirectory`
  даёт `/jni/...`, и Gradle падает с «> entry». Пересобирать через `jar --create`.
- **Готовый AAR лежит в `android/app/libs/amneziawg-bridge.aar`** и подключён
  в `build.gradle.kts` через `implementation(files(...))`.

Контракт, который генерируется в Java (проверено `javap`):

```java
public final class amneziawg.Bridge {
    public native void connect(long fd, String uapi) throws Exception;
    public native void disconnect();
    public native boolean isConnected();
    public native String statusJSON();
    public native String diagnosticsJSON();
    public native void free();
}
```

`connect` принимает `long`: Go `int` gomobile отображает в `long`,
а `ParcelFileDescriptor.detachFd()` в android-36 возвращает `int`,
поэтому в Kotlin нужен явный `.toLong()`.

## Протоколы

| Протокол | Движок | Состояние |
|----------|--------|-----------|
| XRay VLESS/REALITY | `flutter_vless` (Xray-core) | Настоящий туннель |
| Hysteria 2 | `flutter_vless` (Xray-core) | Настоящий туннель |
| AmneziaWG | `amneziawg-bridge` (amneziawg-go, gomobile) | Настоящий туннель |
| olcRTC | нет ядра | Честный статус «Нужен модуль» |

`flutter_vless` — MIT, верифицированный издатель, VLESS/REALITY и Hysteria 2.
Для olcRTC готового ядра нет: upstream помечен как EoL и переносится в другой
проект, поэтому профиль сохраняется, но туннель не поднимается.
