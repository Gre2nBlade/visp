import 'package:flutter/material.dart';

import '../../../core/widgets/blup_action.dart';
import '../../../core/widgets/blup_visp.dart';
import '../../../core/widgets/visp_toast.dart';
import '../../../l10n/strings.dart';
import '../../../state/app_state.dart';
import '../screens/add_connection_screen.dart';

/// Слой Blup Visp с кнопкой подключения в центре фигуры.
///
/// Фигура занимает свободную область между статусом и селектором протокола.
/// Слой нарисован поверх колонки, поэтому нажатие по кнопке в центре не
/// перехватывается текстом статуса (раздел 4.1, 8.1).
class BlupLayer extends StatelessWidget {
  const BlupLayer({super.key, required this.state});

  final AppState state;

@override
  Widget build(BuildContext context) {
    // Размер считается от реально доступной высоты, а не от экрана: колонка
    // главного экрана отдаёт фигуре остаток после статуса, селектора и
    // карточки сервера. Иначе на низких экранах возникает переполнение.
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final byWidth = media.size.width - 104;
        final byHeight = constraints.maxHeight - 8;
        final size = (byWidth < byHeight ? byWidth : byHeight)
            .clamp(96.0, 236.0);

        return Center(
          child: BlupVisp(
            status: state.status,
            size: size,
            trafficPulse: state.trafficPulse,
            action: BlupAction(
              status: state.status,
              onCancel: state.cancelConnect,
              onTap: () => _onTap(context),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (state.status == BlupStatus.connected) {
      state.disconnect();
      return;
    }
    if (state.selectedProfile == null) {
      final s = context.s;
      VispToast.showError(
        context,
        s.notChosen,
        actionLabel: s.addConnection,
        onAction: () => AddConnectionScreen.open(context),
      );
      return;
    }
    await state.connect();
  }
}