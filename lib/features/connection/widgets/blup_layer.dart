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
class BlupLayer extends StatefulWidget {
  const BlupLayer({super.key, required this.state});

  final AppState state;

  @override
  State<BlupLayer> createState() => _BlupLayerState();
}

class _BlupLayerState extends State<BlupLayer> {
  /// Растёт на каждое нажатие: BlupVisp по нему запускает импульс.
  int _pulseToken = 0;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    // Размер считается от реально доступной высоты, а не от экрана: колонка
    // главного экрана отдаёт фигуре остаток после статуса, селектора и
    // карточки сервера. Иначе на низких экранах возникает переполнение.
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final byWidth = media.size.width - 72;
        final byHeight = constraints.maxHeight - 8;
        // Верхняя граница поднята до 300: фигура — главный элемент экрана,
        // и на просторных телефонах она должна занимать центр, а не
        // упираться в потолок в 236 px.
        final size = (byWidth < byHeight ? byWidth : byHeight)
            .clamp(96.0, 300.0);

        return Center(
          child: BlupVisp(
            status: state.status,
            size: size,
            trafficPulse: state.trafficPulse,
            pulseToken: _pulseToken,
            busy: state.status == BlupStatus.preparing ||
                state.status == BlupStatus.checking ||
                state.status == BlupStatus.connecting ||
                state.status == BlupStatus.reconnecting,
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
    // Импульс отправляется до любой ветки: нажатие отзывается сразу, даже
    // если дальше будет ошибка «не выбрано» или отмена.
    setState(() => _pulseToken++);

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