import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_state.dart';

void main() {
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
