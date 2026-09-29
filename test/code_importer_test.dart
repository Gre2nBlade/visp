import 'package:flutter_test/flutter_test.dart';

import 'package:visp/features/connection/models/connection_models.dart';
import 'package:visp/features/connection/services/code_importer.dart';

void main() {
  group('CodeImporter.parse', () {
    test('оффлайн-код visp:// даёт не более четырёх подключений', () {
      final preview = CodeImporter.parse(
        'visp://awg-hys-rtc-vless-ss-vmess?route=split',
      );
      expect(preview.kind, ImportKind.vispOffline);
      expect(preview.entries.length, lessThanOrEqualTo(4));
      expect(preview.entries.any((e) => e.protocol == Protocol.amneziaWG),
          isTrue);
      expect(preview.hasRoutingRules, isTrue);
    });

    test('серверный код VISP-****-**** распознаётся как управляемый', () {
      final preview = CodeImporter.parse('VISP-7F2A-9Q4M');
      expect(preview.kind, ImportKind.vispServer);
      expect(preview.entries.length, greaterThan(1));
      expect(preview.entries.any((e) => e.isProxy), isTrue);
    });

    test('ссылка протокола разбирается в один профиль', () {
      final preview = CodeImporter.parse(
        'vless://user@example.com:443?security=reality',
      );
      expect(preview.kind, ImportKind.protocolLink);
      expect(preview.entries, hasLength(1));
      expect(preview.entries.first.protocol, Protocol.xrayVless);
    });

    test('Telegram-прокси уходит в плагин «Прокси»', () {
      final preview = CodeImporter.parse(
        'https://t.me/webproxy?server=example.com&secret=abc',
      );
      expect(preview.kind, ImportKind.telegramProxy);
      expect(preview.entries.first.isProxy, isTrue);
      expect(preview.entries.first.proxyType, ProxyType.webProxy);
    });

    test('подписка распознаётся по схеме и по base64', () {
      expect(
        CodeImporter.parse('https://example.com/sub/token').kind,
        ImportKind.subscription,
      );
      expect(
        CodeImporter.parse('dmVzczovL3NvbWUtc2VydmVyLmNvbTo0NDM=').kind,
        ImportKind.subscription,
      );
    });

    test('неизвестный формат не угадывается', () {
      final preview = CodeImporter.parse('something-random-12345');
      expect(preview.kind, ImportKind.unknown);
      expect(preview.error, isNotNull);
    });

    test('код активации разработчика проходит отдельную проверку', () {
      expect(CodeImporter.isValidDevCode('VISPDV-AB12CD'), isTrue);
      expect(CodeImporter.isValidDevCode('VISP-7F2A-9Q4M'), isFalse);
    });
  });
}
