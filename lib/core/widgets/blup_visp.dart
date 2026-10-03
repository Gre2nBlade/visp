import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Состояния Blup Visp (раздел 4.1). Анимация не подменяет текстовый статус:
/// экран всегда сопровождает фигуру читаемой подписью.
enum BlupStatus {
  /// Низкая скорость деформации, приглушённый зелёно-графитовый цвет, дыхание.
  idle,

  /// Движение периметра ускоряется, по контуру идёт направленная волна.
  preparing,

  /// Проверка сервера: волна ярче, деформация активна.
  checking,

  /// Соединение: самая быстрая фаза.
  connecting,

  /// Форма сохраняется, скорость повышается плавно, без сброса в начальную фазу.
  reconnecting,

  /// Шалфейный #6FBF93 контур, спокойная заливка, лёгкая пульсация по трафику.
  connected,

  /// Замедление деформации, короткий терракотовый акцент #E57B6E.
  error,

  /// Почти статичная форма.
  blocked,
}

extension BlupStatusX on BlupStatus {
  bool get animates => this != BlupStatus.blocked;

  /// Переводит состояние в фазы подключения «Подготовка модуля» и т.д.
  String? get stageLabel {
    switch (this) {
      case BlupStatus.preparing:
        return 'Подготовка модуля';
      case BlupStatus.checking:
        return 'Проверка сервера';
      case BlupStatus.connecting:
        return 'Соединение';
      case BlupStatus.reconnecting:
        return 'Переподключение';
      default:
        return null;
    }
  }
}

/// Blup Visp — цельная плоская форма с тонким движущимся периметром.
///
/// Технические правила из раздела 4.1: запускается сразу после действия
/// пользователя, останавливается на скрытых экранах и учитывает reduced-motion
/// (на слабых устройствах остаётся статичный контур).
class BlupVisp extends StatefulWidget {
  const BlupVisp({
    super.key,
    required this.status,
    this.size = 240,
    this.compact = false,
    this.trafficPulse = false,
    this.motionReduced = false,
    this.action,
    this.pulseToken = 0,
    this.busy = false,
  });

  final BlupStatus status;
  final double size;
  final bool compact;

  /// Пульсация яркости только при подтверждённом обмене трафиком.
  final bool trafficPulse;

  /// Принудительная ститика для reduced-motion и слабых устройств.
  final bool motionReduced;

  /// Действие в центре фигуры (кнопка подключения).
  ///
  /// Кнопка живёт внутри блупа, а не под ним: центр экрана остаётся
  /// единым целым, и главное действие не уводит взгляд вниз.
  final Widget? action;

  /// Счётчик нажатий. Каждое увеличение отправляет по фигуре импульс.
  ///
  /// Отдельное значение вместо callback'а: фигура не знает, кто её трогает,
  /// а BlupLayer знает и про нажатие, и про отмену.
  final int pulseToken;

  /// Идёт установка: импульсы повторяются, показывая работу без спиннера.
  final bool busy;

  @override
  State<BlupVisp> createState() => _BlupVispState();
}

class _BlupVispState extends State<BlupVisp>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulse;
  late final math.Random _random;
  late final List<double> _seed;

  @override
  void initState() {
    super.initState();
    _random = math.Random(7);
    _seed = List.generate(12, (_) => 0.6 + _random.nextDouble() * 1.6);
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.status),
      value: 0,
    );
    // Импульс — отдельный контроллер: деформация контура идёт всегда, а
    // нажатия добавляют собственные волны и не сбивают её фазу.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: 1,
    );
    if (!_isStatic) {
      _controller.repeat();
    }
    _syncPulse();
  }

  /// Импульс повторяется, пока идёт установка, и одиночный — по нажатию.
  void _syncPulse() {
    if (widget.motionReduced) {
      _pulse.stop();
      _pulse.value = 1;
      return;
    }
    if (widget.busy) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  Duration _durationFor(BlupStatus status) {
    switch (status) {
      case BlupStatus.idle:
      case BlupStatus.error:
        return const Duration(seconds: 14);
      case BlupStatus.connected:
        return const Duration(seconds: 9);
      case BlupStatus.blocked:
        return const Duration(seconds: 60);
      case BlupStatus.preparing:
        return const Duration(seconds: 4);
      case BlupStatus.checking:
        return const Duration(seconds: 3);
      case BlupStatus.connecting:
      case BlupStatus.reconnecting:
        return const Duration(seconds: 2);
    }
  }

  bool get _isStatic =>
      widget.motionReduced || widget.status == BlupStatus.blocked;

  @override
  void didUpdateWidget(covariant BlupVisp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status ||
        oldWidget.motionReduced != widget.motionReduced) {
      _controller.duration = _durationFor(widget.status);
      if (_isStatic) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
    if (oldWidget.pulseToken != widget.pulseToken) {
      // Нажатие: один импульс от центра к контуру.
      _pulse.forward(from: 0);
    }
    if (oldWidget.busy != widget.busy ||
        oldWidget.motionReduced != widget.motionReduced) {
      _syncPulse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isStatic) {
      return _paint(const AlwaysStoppedAnimation(0.42), 1);
    }
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulse]),
      builder: (context, _) => _paint(_controller, _pulse.value),
    );
  }

  Widget _paint(Animation<double> animation, double pulse) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BlupPainter(
                  progress: animation.value,
                  pulse: pulse,
                  status: widget.status,
                  compact: widget.compact,
                  trafficPulse: widget.trafficPulse,
                  seed: _seed,
                  brightness: Theme.of(context).brightness,
                ),
              ),
            ),
            // Кнопка в центре фигуры: действие не уводит взгляд с блупа.
            if (widget.action != null) widget.action!,
          ],
        ),
      ),
    );
  }
}

class _BlupPainter extends CustomPainter {
  _BlupPainter({
    required this.progress,
    required this.pulse,
    required this.status,
    required this.compact,
    required this.trafficPulse,
    required this.seed,
    required this.brightness,
  });

  final double progress;

  /// Фаза импульса: 0 — только что поступило нажатие, 1 — импульс дошёл до
  /// контура и погас. Значения между 0 и 1 означают расходящееся кольцо.
  final double pulse;
  final BlupStatus status;
  final bool compact;
  final bool trafficPulse;
  final List<double> seed;
  final Brightness brightness;

  static const _pointCount = 14;

  /// Взаимно некратные частоты деформации.
  ///
  /// Раньше частоты были кратны друг другу, поэтому через несколько секунд
  /// форма возвращалась к исходной и цикл становился заметно механическим —
  /// это и читалось как дёрганье. Несократимые частоты не дают короткого
  /// периода: движение никогда не повторяется и выглядит случайным.
  static const _wobbleFrequencies = <double>[0.37, 0.53, 0.71, 0.29];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final baseRadius = math.min(size.width, size.height) * 0.36;

    final t = progress * 2 * math.pi;

    // Амплитуда дыхания подстраивается под состояние одной формулой, а не
    // переключением: смена состояния больше не меняет форму скачком.
    final breathAmplitude = switch (status) {
      BlupStatus.idle => 0.020,
      BlupStatus.connected => 0.014,
      _ => 0.008,
    };
    final breath = 1 + breathAmplitude * math.sin(t * 0.31);

    final pts = <Offset>[];
    for (var i = 0; i < _pointCount; i++) {
      final angle = (2 * math.pi * i) / _pointCount;
      // Фаза каждой точки выведена из seed и не делится на длину списка:
      // у соседних точек фазы не совпадают, поэтому контур не «дышит» целиком.
      final phase = seed[i % seed.length] + i * 1.7;
      var wobble = 0.0;
      for (var f = 0; f < _wobbleFrequencies.length; f++) {
        wobble += math.sin(t * _wobbleFrequencies[f] + phase + f * 2.1) *
            (0.055 / (f + 1));
      }
      final r = baseRadius * breath * (1 + wobble);
      pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    final path = _smoothClosed(pts);

    final colors = brightness == Brightness.dark
        ? SemanticColors.dark
        : SemanticColors.light;

    final isAccent = status == BlupStatus.connected ||
        status == BlupStatus.connecting ||
        status == BlupStatus.checking ||
        status == BlupStatus.preparing ||
        status == BlupStatus.reconnecting;
    final isError = status == BlupStatus.error;

    final perimeter = isAccent
        ? colors.primaryBright
        : isError
            ? colors.blupError
            : colors.blupIdle;

    final isConnected = status == BlupStatus.connected;

    // Заливка сплошная: градиент внутри фигуры читался как отдельный объект
    // и мешал форме быть знаком. Тон меняется по состоянию, а не переливается.
    // При подключении фигура просто становится ярче — без вращения и дуг.
    final fill = isConnected
        ? colors.blupConnected.withValues(alpha: 0.30)
        : isAccent
            ? colors.primary.withValues(alpha: 0.12)
            : isError
                ? colors.blupError.withValues(alpha: 0.12)
                : colors.blupIdle.withValues(
                    alpha: brightness == Brightness.dark ? 0.10 : 0.07,
                  );

    canvas.drawPath(path, Paint()..color = fill);

    // Периметр: тонкий движущийся контур.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.2 : (isConnected ? 2.2 : 1.8)
        ..color = perimeter.withValues(
          alpha: isConnected
              ? (trafficPulse ? 1 : 0.85)
              : status == BlupStatus.idle
                  ? 0.55
                  : 0.9,
        )
        ..strokeJoin = StrokeJoin.round,
    );

    // Импульс: расходящееся кольцо от центра к контуру. Он и есть признак
    // нажатия и установки — вместо крутящегося индикатора, который читался
    // как отдельный элемент и дублировал состояние.
    if (!compact && pulse < 1) {
      canvas.save();
      // Кольцо не выходит за фигуру: импульс должен казаться её внутренним
      // дыханием, а не расширяющимся кругом поверх экрана.
      canvas.clipPath(path);
      final t = Curves.easeOut.transform(pulse);
      final radius = baseRadius * (0.12 + 1.02 * t);
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = (isAccent || isConnected ? colors.primary : colors.mutedForeground)
              .withValues(alpha: 0.55 * (1 - t)),
      );
      canvas.restore();
    }

    // Дуга прогресса, бегущая волна и внутренняя окружность-скелет убраны
    // намеренно. Вместе с кольцом кнопки внутренний круг давал «мишень» из
    // трёх концентрических окружностей, а дуга и волна читались как
    // индикатор загрузки. Остаётся одна фигура и одна иконка в центре;
    // состояние видно по надписи, иконке и цвету периметра.
  }

  Path _smoothClosed(List<Offset> pts) {
    final path = Path();
    final n = pts.length;
    final mid = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % n];
      mid.add(Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2));
    }
    path.moveTo(mid[n - 1].dx, mid[n - 1].dy);
    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final m = mid[i];
      path.quadraticBezierTo(a.dx, a.dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlupPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.trafficPulse != trafficPulse ||
        oldDelegate.compact != compact;
  }
}
