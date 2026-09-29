import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:visp/main.dart';
import 'package:visp/core/widgets/blup_visp.dart';
import 'package:visp/features/navigation/visp_floating_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bootstrap(WidgetTester tester) async {
    // Русский язык, чтобы главная страница показывала русские подписи.
    SharedPreferences.setMockInitialValues({'visp.locale': 'ru'});
    await tester.pumpWidget(const VispBootstrap());
    // Настройки и стартовые данные грузятся асинхронно.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Visp запускается и показывает главный экран с навигацией',
      (tester) async {
    await bootstrap(tester);

    expect(find.byType(BlupVisp), findsWidgets);
    expect(find.byType(VispFloatingNav), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('VPN выключен'), findsOneWidget);
    expect(find.text('Подключиться'), findsOneWidget);
  });

  testWidgets('Кнопка «+» открывает экран добавления подключения',
      (tester) async {
    await bootstrap(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Добавить подключение'), findsOneWidget);
    expect(find.text('Self-hosted'), findsOneWidget);
    expect(find.text('QR-код'), findsOneWidget);
  });
}
