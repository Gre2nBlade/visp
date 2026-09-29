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

  group('Стартовые протоколы (раздел 3)', () {
    test('vless REALITY разбирает pbk, sid, fp, sni и flow', () {
      final preview = CodeImporter.parse(
        'vless://a3f1...uuid@vpn.example.com:443'
        '?encryption=none&security=reality&sni=www.microsoft.com&fp=chrome'
        '&pbk=ZmFrZVB1YmxpY0tleQ&sid=ab12cd34&flow=xtls-rprx-vision&type=tcp',
      );
      expect(preview.kind, ImportKind.protocolLink);
      final entry = preview.entries.single;
      expect(entry.protocol, Protocol.xrayVless);
      expect(entry.config, isNotNull);
      final config = entry.config!;
      expect(config.address, 'vpn.example.com');
      expect(config.port, 443);
      expect(config.publicKey, 'ZmFrZVB1YmxpY0tleQ');
      expect(config.shortId, 'ab12cd34');
      expect(config.fingerprint, 'chrome');
      expect(config.sni, 'www.microsoft.com');
      expect(config.flow, 'xtls-rprx-vision');
      expect(entry.subtitle, 'XRay VLESS/REALITY · vpn.example.com:443');
      // Движок XRay не входит в стартовый набор — профиль с «Нужен модуль».
      expect(entry.needsModule, isTrue);
    });

    test('hysteria2 разбирает auth, obfs и pinSHA256', () {
      final preview = CodeImporter.parse(
        'hysteria2://mobile.example.com:8443/?auth=secreTtoken'
        '&obfs=salamander&obfs-password=salt&sni=cdn.example.com&insecure=1',
      );
      final entry = preview.entries.single;
      expect(entry.protocol, Protocol.hysteria2);
      expect(entry.config!.address, 'mobile.example.com');
      expect(entry.config!.port, 8443);
      expect(entry.config!.auth, 'secreTtoken');
      expect(entry.config!.obfs, 'salamander');
      expect(entry.config!.obfsPassword, 'salt');
      expect(entry.config!.sni, 'cdn.example.com');
      expect(entry.needsModule, isFalse);
    });

    test('olcRTC распознаётся и помечается как требующий модуль', () {
      final preview = CodeImporter.parse(
        'olcrtc://restricted.example.com:443/?transport=webrtc&token=tok123',
      );
      final entry = preview.entries.single;
      expect(entry.protocol, Protocol.olcRtc);
      expect(entry.config!.address, 'restricted.example.com');
      expect(entry.config!.auth, 'tok123');
      expect(entry.needsModule, isTrue);
    });

    test('AmneziaWG .conf определяется по junk-параметрам', () {
      const conf = '''
[Interface]
PrivateKey = yAnz5TF+lXXJte4156dQ3XQ= =
Address = 10.8.0.2/24
Jc = 4
Jmin = 40
Jmax = 70
S1 = 104
S2 = 76
H1 = 867697069
H2 = 936790926
H3 = 825834851
H4 = 494689854

[Peer]
PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8czE
Endpoint = 203.0.113.5:51820
AllowedIPs = 0.0.0.0/0
''';
      final preview = CodeImporter.parseConfig(conf);
      final entry = preview.entries.single;
      expect(entry.protocol, Protocol.amneziaWG);
      expect(entry.config!.address, '203.0.113.5');
      expect(entry.config!.port, 51820);
      expect(entry.config!.publicKey, 'xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8czE');
      expect(entry.config!.extras, containsPair('JMIN', '40'));
      expect(entry.needsModule, isFalse);
    });

    test('обычный WireGuard .conf без junk-параметров остаётся WireGuard', () {
      const conf = '''
[Interface]
PrivateKey = aaa=
Address = 10.9.0.1/24

[Peer]
PublicKey = bbbPreshared=
Endpoint = 198.51.100.3:51820
AllowedIPs = 0.0.0.0/0
''';
      final preview = CodeImporter.parse(conf);
      final entry = preview.entries.single;
      expect(entry.protocol, Protocol.wireGuard);
      expect(entry.config!.address, '198.51.100.3');
      // Обычный WireGuard появляется по мере добавления движка.
      expect(entry.needsModule, isTrue);
    });
  });
}
