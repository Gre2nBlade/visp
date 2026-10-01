import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Компилируем шейдеры стекла заранее, иначе первый кадр со стеклом
  // начнётся с матового заглушечного вида.
  await LiquidGlassShaders.ensureLoaded();
  runApp(const VispBootstrap());
}

class VispBootstrap extends StatelessWidget {
  const VispBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const VispApp(),
    );
  }
}
