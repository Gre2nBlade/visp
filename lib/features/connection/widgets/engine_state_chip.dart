import 'package:flutter/material.dart';

import '../../../../core/icons/visp_icon.dart';
import '../../../../core/widgets/visp_chip.dart';
import '../../../../l10n/strings.dart';
import '../models/connection_models.dart';

/// Чип состояния движка протокола на устройстве (раздел 3.4).
///
/// Три разных вещи не смешиваются: движок есть на устройстве, протокол
/// скачивается, протокол поддерживается. Цвет — не единственный носитель
/// статуса: всегда есть иконка и текст.
class EngineStateChip extends StatelessWidget {
  const EngineStateChip({super.key, required this.state});

  final EngineState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    switch (state) {
      case EngineState.ready:
        return VispChip(label: s.engineReady, tone: ChipTone.accent);
      case EngineState.notInstalled:
        return VispChip(label: s.engineNotInstalled, tone: ChipTone.warning);
      case EngineState.downloading:
        return VispChip(
          label: s.engineDownloading,
          tone: ChipTone.info,
          icon: VispIcons.download,
        );
      case EngineState.needsUpdate:
        return VispChip(
          label: s.engineNeedsUpdate,
          tone: ChipTone.info,
          icon: VispIcons.download,
        );
      case EngineState.unsupported:
        return VispChip(label: s.engineUnsupported, tone: ChipTone.danger);
    }
  }
}
