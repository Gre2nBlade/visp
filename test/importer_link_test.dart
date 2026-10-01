import 'package:flutter_test/flutter_test.dart';
import 'package:visp/features/connection/models/connection_models.dart';
import 'package:visp/features/connection/services/code_importer.dart';

void main() {
  test('имя из ссылки показывается как подпись, а не адрес', () {
    final p = CodeImporter.parse(
      'vless://uuid@a.com:443?security=reality&pbk=k&sid=s#Amnezia',
    );
    expect(p.entries.single.title, 'Amnezia');
    expect(p.entries.single.protocol, Protocol.xrayVless);
  });

  test('имя из ссылки работает и для hysteria2', () {
    final p = CodeImporter.parse('hysteria2://m.com:8443/?auth=t#Мой сервер');
    expect(p.entries.single.title, 'Мой сервер');
  });

  test('без фрагмента остаётся адрес', () {
    final p = CodeImporter.parse('vless://uuid@a.com:443?security=tls');
    expect(p.entries.single.title, 'a.com');
  });

  test('слово «amnezia» получает подсказку про конфиг, а не отказ', () {
    final p = CodeImporter.parse('amnezia');
    expect(p.kind, ImportKind.unknown);
    expect(p.error, contains('конфигурационным файлом'));
  });

  test('схема без адреса не создаёт профиль «сервер»', () {
    final p = CodeImporter.parse('vless://');
    expect(p.kind, ImportKind.unknown);
    expect(p.entries, isEmpty);
    expect(p.error, contains('нет адреса'));
  });

  test('совершенно непонятный ввод даёт общий список ожидаемого', () {
    final p = CodeImporter.parse('qwerty123');
    expect(p.error, contains('VISP-'));
  });
}