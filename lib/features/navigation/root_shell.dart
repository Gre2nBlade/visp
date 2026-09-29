import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../connection/screens/add_connection_screen.dart';
import '../connection/screens/home_screen.dart';
import 'nav_destination.dart';
import 'visp_floating_nav.dart';
import '../proxy/proxy_screen.dart';
import '../servers/servers_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/studio_screen.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';

/// Корневой экран: плавающая навигация и переключение вкладок.
///
/// Состав вкладок зависит от плагина и закрепления Studio: после установки
/// «Прокси» появляется вкладка «Прокси», закрепление Studio добавляет
/// необязательную вкладку (раздел 4.6).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  List<NavDestination> get _destinations {
    final state = context.read<AppState>();
    final list = <NavDestination>[
      NavDestination.home,
      NavDestination.servers,
    ];
    if (state.proxyInstalled) {
      list.add(NavDestination.proxy);
    }
    if (state.studioPinned) {
      list.add(NavDestination.studio);
    }
    list.add(NavDestination.settings);
    return list;
  }

  void _onAdd() {
    AddConnectionScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final destinations = _destinations;
    if (_index >= destinations.length) _index = 0;

    final s = context.s;
    final current = destinations[_index];

    return Scaffold(
      extendBody: true,
      body: _screenFor(current),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (current == NavDestination.settings && !state.studioPinned)
            _StudioHint(s: s),
          VispFloatingNav(
            destinations: destinations,
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            onAdd: _onAdd,
            glass: state.glass,
          ),
        ],
      ),
    );
  }

  Widget _screenFor(NavDestination destination) {
    switch (destination) {
      case NavDestination.home:
        return const HomeScreen();
      case NavDestination.servers:
        return const ServersScreen();
      case NavDestination.proxy:
        return const ProxyScreen();
      case NavDestination.studio:
        return const StudioScreen();
      case NavDestination.settings:
        return const SettingsScreen();
    }
  }
}

/// Напоминание, что Studio доступна из настроек, даже если вкладка
/// не закреплена (раздел 4.6: открепление убирает только вкладку).
class _StudioHint extends StatelessWidget {
  const _StudioHint({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '${s.studio} — ${s.studioDesc}',
        textAlign: TextAlign.center,
        style: AppTextStyles.small.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
