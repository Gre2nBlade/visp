import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../screens/add_connection_screen.dart';

/// Выбор конфигурационного файла (раздел 2.4: WireGuard/AmneziaWG — файлом).
///
/// Принимаются .conf и текстовые файлы. Содержимое читается целиком и сразу
/// уходит в предпросмотр импорта, чтобы пользователь видел, что именно
/// приложение поняло из файла.
Future<void> openConfigFileFlow(BuildContext context) async {
  if (!context.mounted) return;

  List<PlatformFile> picked;
  try {
    picked = await FilePicker.pickFiles(type: FileType.any);
  } catch (_) {
    // На некоторых устройствах системный выбор файла недоступен.
    return;
  }

  if (picked.isEmpty) return;

  // XFile читается одинаково на всех платформах, включая веб,
  // поэтому дисковые пути и dart:io здесь не нужны.
  String? content;
  try {
    content = await picked.first.xFile.readAsString();
  } catch (_) {
    content = null;
  }

  if (content == null || content.trim().isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось прочитать файл')),
    );
    return;
  }

  if (!context.mounted) return;
  await AddConnectionScreen.openWithPreview(context, content);
}